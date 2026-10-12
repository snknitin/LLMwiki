#!/usr/bin/env python3
"""Preview/apply a bounded Hermes provider migration; never contacts a model server.

Requires ruamel.yaml (preferred) or PyYAML from the existing Hermes Python runtime.
Default is a sanitized plan. --apply writes backups first. --rollback BACKUP is
also a preview unless --apply is supplied. No process is restarted by this tool.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import io
import json
import os
from pathlib import Path
import tempfile
from datetime import datetime, timezone

GEMMAS = ("gemma4:31b-it-qat", "gemma4:26b-a4b-it-qat", "gemma3:4b")
ALIAS = "qwen38-27b-spark"
CONTEXT = 262144


def yaml_codec():
    try:
        from ruamel.yaml import YAML
        codec = YAML()
        codec.preserve_quotes = True
        def dump(data):
            output = io.StringIO()
            codec.dump(data, output)
            return output.getvalue()
        return codec.load, dump
    except ImportError:
        import yaml
        return yaml.safe_load, lambda data: yaml.safe_dump(data, sort_keys=False, allow_unicode=True)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def inside(home, relative):
    path = (home / relative).resolve()
    if not path.is_relative_to(home) or path == home:
        raise ValueError("Backup path escapes the selected Hermes home")
    return path


def atomic_write(path, data, mode=None):
    fd, temporary = tempfile.mkstemp(prefix=".qwen-migration-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        if mode is not None:
            os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def qwen_desktop(selection):
    return (isinstance(selection, dict)
            and str(selection.get("provider", "")) in ("desktop-ollama", "custom:desktop-ollama")
            and str(selection.get("model", selection.get("default", ""))).lower().startswith("qwen"))


def explicit_desktop_references(data):
    refs = []
    for index, entry in enumerate(data.get("fallback_providers", []) or []):
        if qwen_desktop(entry):
            refs.append(f"fallback_providers[{index}]")
    for name, entry in (data.get("auxiliary", {}) or {}).items():
        if qwen_desktop(entry):
            refs.append(f"auxiliary.{name}")
    return refs


def transform(data, migrate_default, template=None):
    if not isinstance(data, dict):
        raise ValueError("Configuration must be a mapping")
    output = copy.deepcopy(data)
    providers = output.get("providers")
    if providers is None:
        providers = output["providers"] = {}
    if not isinstance(providers, dict):
        raise ValueError("Providers must be a mapping")
    if "desktop-ollama" not in providers and "spark-lmstudio" not in providers:
        if template is None or not all(isinstance(template.get(name), dict) for name in ("desktop-ollama", "spark-lmstudio")):
            raise ValueError("No existing provider endpoints available in the selected home's main config")
        # Profiles own separate configs. Copy only these two already established
        # local-provider blocks from this machine's main config, never other settings.
        for name in ("desktop-ollama", "spark-lmstudio"):
            providers[name] = copy.deepcopy(template[name])
    if not all(isinstance(providers.get(name), dict) for name in ("desktop-ollama", "spark-lmstudio")):
        raise ValueError("Expected both existing desktop-ollama and spark-lmstudio providers; refusing to invent an endpoint")
    desktop = providers["desktop-ollama"]
    spark = providers["spark-lmstudio"]
    refs = explicit_desktop_references(output)
    if refs:
        raise ValueError("Resolve desktop Qwen fallback/auxiliary references explicitly before migration: " + ", ".join(refs))
    if qwen_desktop(output.get("model")):
        if not migrate_default:
            raise ValueError("Saved default uses desktop Qwen; review it and rerun with --migrate-desktop-qwen-defaults if desired")
        selection = output["model"]
        selection["provider"] = "custom:spark-lmstudio"
        selection["default"] = ALIAS
        if "model" in selection:
            selection["model"] = ALIAS
        selection["base_url"] = spark.get("api") or spark.get("base_url") or spark.get("url")
        if not selection["base_url"]:
            raise ValueError("Existing spark-lmstudio endpoint is missing")
        selection["context_length"] = CONTEXT
        selection["api_mode"] = "chat_completions"
    old_models = desktop.get("models")
    if not isinstance(old_models, dict):
        raise ValueError("Expected desktop model metadata mapping")
    missing = [model for model in GEMMAS if not isinstance(old_models.get(model), dict)]
    if missing:
        raise ValueError("Missing existing Gemma metadata: " + ", ".join(missing))
    desktop["models"] = {model: copy.deepcopy(old_models[model]) for model in GEMMAS}
    desktop["discover_models"] = False
    desktop.pop("models_discovered", None)
    for name in ("model", "default_model"):
        if name in desktop and desktop[name] not in GEMMAS:
            # A provider-local selection can reinsert a removed ID into the picker.
            desktop.pop(name)
    spark_models = spark.get("models")
    if not isinstance(spark_models, dict):
        raise ValueError("Expected Spark LM Studio model metadata mapping")
    spark_models.pop("__discovered_model_catalog__", None)
    # Preserve existing Nemotron and other catalog metadata; residency is managed separately.
    spark_models[ALIAS] = {"context_length": CONTEXT}
    spark["discover_models"] = False
    spark.pop("models_discovered", None)
    # A second provider aimed at the same endpoint might re-expose desktop Qwen.
    desktop_url = (desktop.get("api") or desktop.get("base_url") or desktop.get("url") or "").rstrip("/")
    for name, entry in providers.items():
        if name == "desktop-ollama" or not isinstance(entry, dict):
            continue
        url = (entry.get("api") or entry.get("base_url") or entry.get("url") or "").rstrip("/")
        if desktop_url and url == desktop_url:
            raise ValueError("Another provider targets the desktop Ollama endpoint: " + str(name))
    for entry in output.get("custom_providers", []) or []:
        if not isinstance(entry, dict):
            continue
        url = (entry.get("base_url") or entry.get("api") or entry.get("url") or "").rstrip("/")
        if desktop_url and url == desktop_url:
            raise ValueError("custom_providers contains another desktop endpoint; consolidate it explicitly")
    return output, {
        "desktop_models": list(GEMMAS), "desktop_discovery": False,
        "spark_models": list(spark_models), "spark_discovery": False,
        "qwen_context": CONTEXT, "default_changed": output.get("model") != data.get("model"),
    }


def rollback(args, home):
    backup = Path(args.rollback).expanduser().resolve()
    if not backup.is_relative_to(home / "backups"):
        raise ValueError("Rollback directory must be inside this Hermes home's backups directory")
    manifest = json.loads((backup / "manifest.json").read_text(encoding="utf-8"))
    if manifest.get("home") != str(home):
        raise ValueError("Backup belongs to another Hermes home")
    changes = []
    for item in manifest["files"]:
        target = inside(home, item["path"])
        saved = inside(backup, item["path"])
        original = saved.read_bytes()
        if digest(original) != item["before_sha256"]:
            raise ValueError("Backup hash mismatch: " + item["path"])
        if digest(target.read_bytes()) != item["after_sha256"]:
            raise ValueError("Config changed since migration; refusing to overwrite: " + item["path"])
        changes.append((target, original, target.stat().st_mode & 0o777))
    print(json.dumps({"mode": "rollback-apply" if args.apply else "rollback-preview", "files": [str(p.relative_to(home)) for p, _, _ in changes]}, indent=2))
    if args.apply:
        for target, original, mode in changes:
            atomic_write(target, original, mode)
        print("Rollback complete. Restart affected Hermes backends when no turns are running.")


def main():
    global CONTEXT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", required=True, help="Actual Hermes home, not the source-code directory")
    parser.add_argument("--context", type=int, choices=(65536, 131072, 262144), default=262144, help="Use only the context already qualified on Spark")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--migrate-desktop-qwen-defaults", action="store_true", help="Explicitly convert only saved defaults selecting desktop Qwen")
    parser.add_argument("--rollback", metavar="BACKUP_DIRECTORY")
    args = parser.parse_args()
    CONTEXT = args.context
    home = Path(args.home).expanduser().resolve()
    if not (home / "config.yaml").is_file():
        raise ValueError("Selected Hermes home has no config.yaml")
    if args.rollback:
        return rollback(args, home)
    load, dump = yaml_codec()
    root_data = load((home / "config.yaml").read_text(encoding="utf-8-sig")) or {}
    template = root_data.get("providers", {})
    configs = [home / "config.yaml", *sorted((home / "profiles").glob("*/config.yaml"))]
    pending = []
    for path in configs:
        original = path.read_bytes()
        data = load(original.decode("utf-8-sig")) or {}
        try:
            updated, summary = transform(data, args.migrate_desktop_qwen_defaults, template)
        except ValueError as exc:
            raise ValueError(f"{path.relative_to(home)}: {exc}") from None
        changed = updated != data
        print(json.dumps({"file": str(path.relative_to(home)), "changed": changed, "plan": summary}, ensure_ascii=False))
        if changed:
            encoded = dump(updated).encode("utf-8")
            if load(encoded.decode("utf-8")) != updated:
                raise ValueError("YAML round-trip verification failed")
            pending.append((path, original, encoded, path.stat().st_mode & 0o777))
    if not args.apply:
        print("Preview only. Qualify the Spark alias and finish active Hermes turns before --apply.")
        return
    if not pending:
        print("No changes required.")
        return
    for path, original, _, _ in pending:
        if path.read_bytes() != original:
            raise ValueError("Config changed while planning; rerun: " + str(path.relative_to(home)))
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    backup = home / "backups" / ("qwen-spark-migration-" + stamp)
    backup.mkdir(parents=True, mode=0o700)
    manifest = {"home": str(home), "files": []}
    for path, original, encoded, mode in pending:
        relative = path.relative_to(home)
        saved = backup / relative
        saved.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        saved.write_bytes(original)
        os.chmod(saved, 0o600)
        manifest["files"].append({"path": str(relative), "before_sha256": digest(original), "after_sha256": digest(encoded)})
    manifest_path = backup / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    os.chmod(manifest_path, 0o600)
    written = []
    try:
        for path, original, encoded, mode in pending:
            if path.read_bytes() != original:
                raise ValueError("Config changed before write: " + str(path.relative_to(home)))
            atomic_write(path, encoded, mode)
            written.append((path, original, encoded, mode))
    except Exception:
        for path, original, encoded, mode in reversed(written):
            if path.read_bytes() == encoded:
                atomic_write(path, original, mode)
        raise
    print("Applied. Backup: " + str(backup))
    print("No services restarted. Restart affected backends when no turns are running, then /model --refresh.")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError) as error:
        raise SystemExit(str(error))
