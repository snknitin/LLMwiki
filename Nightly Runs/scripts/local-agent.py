"""Run Hermes against one local endpoint, isolated from subscription providers/plugins.

The isolated profile and transcript remain under the installed Hermes profiles/ for diagnosis.
No shared Hermes config, gateway, credentials or model service is changed.
"""
import argparse
import base64
import json
import os
import re
from pathlib import Path
import shutil
import signal
import subprocess
import sys
from urllib.parse import urlparse
from urllib.request import urlopen


def profile(url, model, edits_instructions=False):
    extra = {"chat_template_kwargs": {"enable_thinking": False}}
    route = {"provider": "custom:board-local", "model": model, "base_url": url,
             "api_key": "local-only", "extra_body": extra, "timeout": 120}
    return {
        "model": {"default": model, "provider": route["provider"], "base_url": url,
                  "api_mode": "chat_completions"},
        "custom_providers": [{"name": "board-local", "base_url": url,
                              "api_key": "local-only", "model": model, "extra_body": extra}],
        "fallback_providers": [],
        "agent": {"max_turns": 120, "api_max_retries": 1, "reasoning_effort": "none"},
        "auxiliary": {**{name: dict(route) for name in
                         ("compression", "vision", "goal_judge", "background_review", "review",
                          "approval", "skills_hub", "mcp", "web_extract")},
                      "title_generation": {"enabled": False}},
        "delegation": {**route, "default_model": model, "fallback_providers": [],
                       "request_overrides": {"extra_body": extra}},
        "memory": {"memory_enabled": False, "user_profile_enabled": False},
        # Prep's job is rewriting each project's target lines in CLAUDE.md/AGENTS.md; Hermes' guard asks a person
        # for every such write, and unattended nobody answers (2026-10-23 lost 20 min and every target). Prep only.
        **({"security": {"protected_instruction_files": False}} if edits_instructions else {}),
    }


def matches_profile(text, expected):
    """Allow formatting and Hermes' custom_providers -> providers migration only."""
    try:
        actual = json.loads(text)
    except (ValueError, TypeError):
        return False
    if not isinstance(actual, dict):
        return False
    version = actual.pop("_config_version", None)
    if version is not None and (not isinstance(version, int) or isinstance(version, bool)):
        return False
    if actual == expected:
        return True
    migrated = dict(expected)
    providers = migrated.pop("custom_providers")
    migrated["providers"] = {
        item["name"]: {"api": item["base_url"], "name": item["name"],
                       "api_key": item["api_key"], "extra_body": item["extra_body"],
                       "default_model": item["model"]} for item in providers
    }
    return actual == migrated


def read_profile(path, hermes_root):
    text = path.read_text(encoding="utf-8")
    try:
        json.loads(text)
        return text
    except ValueError:
        # Hermes may serialize its migrated config as YAML. Reuse its installed
        # parser instead of installing dependencies in the system Python.
        runtime = hermes_root / "hermes-agent" / ".venv" / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
        parser = ("import json,sys\ntry:\n import hermes_yaml as yaml\nexcept ImportError:\n import yaml\n"
                  "print(json.dumps(yaml.safe_load(open(sys.argv[1],encoding='utf-8'))))")
        if runtime.exists():
            command = [str(runtime), "-c", parser, str(path)]
        else:
            # New Hermes installs select dependency generations via their published launcher.
            executable = shutil.which("hermes") or str(hermes_root / "bin" / "hermes")
            resolved = subprocess.run([executable, "--print-runtime-command", "--module", "json.tool"],
                                      capture_output=True, text=True, timeout=15, check=True)
            command = json.loads(resolved.stdout)
            entry = "runpy.run_module('json.tool', run_name='__main__', alter_sys=True)"
            if len(command) != 4 or command[1:3] != ["-I", "-c"] or not command[3].endswith(entry):
                raise ValueError("Unsupported Hermes runtime command; refusing to guess the parser runtime")
            encoded = base64.b64encode(parser.encode()).decode("ascii")
            command[3] = command[3][:-len(entry)] + "exec(__import__('base64').b64decode('" + encoded + "'))"
            command.append(str(path))
        parsed = subprocess.run(command, capture_output=True, text=True, timeout=15)
        if parsed.returncode:
            raise ValueError(f"Cannot validate local profile format at {path}")
        return parsed.stdout


def committed_qa_result(workdir, before):
    """Recover a judge's new committed verdict when its chat omits the footer."""
    diff = subprocess.run(["git", "diff", "--unified=0", before, "HEAD", "--", "REPORT.md"],
                          cwd=workdir, capture_output=True, text=True, timeout=15, check=True).stdout
    verdicts = []
    for line in diff.splitlines():
        if not line.startswith("+") or line.startswith("+++"):
            continue
        match = re.fullmatch(r"\s*(?:#{1,6}\s+)?QA RESULT:\s*(pass|findings\s*=\s*\d+)\s*", line[1:])
        if match:
            verdicts.append(re.sub(r"\s+", "", match[1]))
    return "QA RESULT: " + verdicts[-1] if verdicts else None


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--base-url", required=True)
    p.add_argument("--model", required=True)
    p.add_argument("--workdir", required=True)
    p.add_argument("--budget", type=int, default=1800)
    p.add_argument("--prompt-file", help="UTF-8 prompt; otherwise read stdin")
    p.add_argument("--qa-result", action="store_true", help="Emit the new committed REPORT verdict after successful QA")
    a = p.parse_args()
    url = a.base_url.rstrip("/")
    if urlparse(url).hostname not in ("127.0.0.1", "localhost", "::1"):
        p.error("local-agent requires a loopback endpoint on the execution machine")
    # Fail before starting an agent when its local model is off. Never fall back to cloud.
    with urlopen(url + "/models", timeout=10) as response:
        json.load(response)
    executable = shutil.which("hermes") or str(Path.home() / ".local/bin/hermes")
    # Named profiles reuse the installed runtime; an unrelated HERMES_HOME bootstraps another runtime.
    hermes_root = Path(os.environ.get("LOCALAPPDATA", "")) / "hermes" if os.name == "nt" else Path.home() / ".hermes"
    # Reuse one service profile per host. Project/session identity belongs in the session and run log.
    home = hermes_root / "profiles" / ("agents-board-prep" if os.name == "nt" else "agents-board-qa")
    home.mkdir(parents=True, exist_ok=True)
    prep = home.name == "agents-board-prep"
    expected = profile(url, a.model, edits_instructions=prep)
    config = json.dumps(expected)
    path = home / "config.yaml"
    if path.exists() and not matches_profile(read_profile(path, hermes_root), expected):
        # The pin before the instruction-file setting existed is this script's own; upgrade it, refuse anything else.
        if not (prep and matches_profile(read_profile(path, hermes_root), profile(url, a.model))):
            raise ValueError(f"{path} differs from the pinned local route; refusing to overwrite an operator change")
        path.write_text(config, encoding="utf-8")
    if not path.exists():
        # Exclusive creation also makes simultaneous launches safe when they share this profile.
        try:
            with path.open("x", encoding="utf-8") as output:
                output.write(config)
        except FileExistsError:
            if not matches_profile(read_profile(path, hermes_root), expected):
                raise ValueError(f"Conflicting local profile creation at {path}")
    env = dict(os.environ)
    # User configuration is isolated; inherited cloud keys and provider hints cannot select a subscription.
    for key in list(env):
        if key.startswith(("ANTHROPIC_", "CLAUDE_", "CODEX_", "OPENAI_", "OPENROUTER_", "HERMES_")):
            env.pop(key)
    env.update(HERMES_HOME=str(home), HERMES_INFERENCE_PROVIDER="custom:board-local",
               PYTHONIOENCODING="utf-8", PYTHONUTF8="1")
    if os.name == "nt":
        # Hermes' portable git uses credential.helper=helper-selector, a picker window that hangs unattended
        # (/dev/tty). Use Git Credential Manager (the owner's saved GitHub login) and fail fast, never prompt.
        env.update(GIT_TERMINAL_PROMPT="0", GCM_INTERACTIVE="never", GIT_CONFIG_COUNT="2",
                   GIT_CONFIG_KEY_0="credential.helper", GIT_CONFIG_VALUE_0="",
                   GIT_CONFIG_KEY_1="credential.helper", GIT_CONFIG_VALUE_1="manager")
    prompt = Path(a.prompt_file).read_text(encoding="utf-8-sig") if a.prompt_file else sys.stdin.buffer.read().decode("utf-8-sig")
    prompt += f"\nInstalled skills can be read from {hermes_root / 'skills'}; read the appropriate SKILL.md when the task names a skill. Never call a subscription model or change the pinned local route.\n"
    if not a.qa_result:
        prompt += ("\nPREP RULES: You may edit a project's CLAUDE.md or AGENTS.md, but only the target, scope, "
                   "order-of-work and stop-condition lines the advance-slice or make-overnight-ready skill names; never "
                   "its rules, permissions, owner gates or security text. Work one project at a time, yourself (no "
                   "delegation). Report only what happened: name a commit hash only after `git log -1` in that project "
                   "shows it, and say plainly when an edit, verify, commit or push failed. The runner checks every "
                   "claim against git and reports the difference.\n")
    print(f"LOCAL ROUTE: {a.model} at {url}; profile={home}", flush=True)
    command = [executable, "chat", "--provider", "custom:board-local", "--base-url", url,
               "--api-key", "local-only", "-m", a.model, "--query-file", "-", "-Q", "--yolo",
               "--in", str(Path(a.workdir).resolve()), "--max-turns", "120", "--run-budget", str(a.budget)]
    before = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=a.workdir, text=True).strip() if a.qa_result else None
    child = subprocess.Popen(command, stdin=subprocess.PIPE, encoding="utf-8", env=env,
                             cwd=a.workdir, start_new_session=os.name != "nt")
    try:
        child.communicate(prompt, timeout=a.budget + 60)
        if child.returncode == 0 and a.qa_result:
            verdict = committed_qa_result(a.workdir, before)
            if verdict:
                print(verdict, flush=True)
        return child.returncode
    except subprocess.TimeoutExpired:
        if os.name == "nt":
            subprocess.run(["taskkill.exe", "/PID", str(child.pid), "/T", "/F"], capture_output=True)
        else:
            os.killpg(child.pid, signal.SIGTERM)
        child.wait(timeout=15)
        raise


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        print(f"LOCAL AGENT FAILED: {error}", file=sys.stderr)
        sys.exit(1)
