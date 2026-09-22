#!/usr/bin/env python3
"""Comparable, persistent qualification probes for the dual-Spark frontier lanes."""

from __future__ import annotations

import argparse
import base64
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import time
import urllib.request


DEFAULT_ENDPOINT = "http://127.0.0.1:8100"
DEFAULT_ROOT = Path.home() / "frontier-results"
DEFAULT_KEY_FILE = Path.home() / ".config/frontier/api-key"
VISION_SHA256 = "0c0b5e38998befd2f98802175ace84ca1a879c2e5835ea0f28dc56b555a9c297"
QUALITY_MARKER = "QUALITY_TEST_COMPLETE"
VISION_MARKER = (
    "VISION_COUNTS red_triangle=1 blue_circles=2 "
    "green_squares=3 yellow_star=1 total=7"
)


def now_utc() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


def atomic_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    temporary.replace(path)


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def result_root(value: str | None) -> Path:
    return Path(value).expanduser().resolve() if value else DEFAULT_ROOT


def latest_dir(root: Path, profile: str) -> Path:
    latest = root / profile / "latest"
    if not latest.exists():
        raise SystemExit(f"No active result run for {profile}. Run the init command first.")
    resolved = latest.resolve()
    if not resolved.is_dir():
        raise SystemExit(f"Latest result target is not a directory: {resolved}")
    return resolved


def metadata_for(root: Path, profile: str) -> tuple[Path, dict]:
    run_dir = latest_dir(root, profile)
    metadata_path = run_dir / "metadata.json"
    if not metadata_path.is_file():
        raise SystemExit(f"Missing {metadata_path}")
    return run_dir, read_json(metadata_path)


def key_from(path_value: str | None) -> str:
    path = Path(path_value).expanduser() if path_value else DEFAULT_KEY_FILE
    if not path.is_file():
        raise SystemExit(f"API key file is missing: {path}")
    key = path.read_text(encoding="utf-8").strip()
    if not key:
        raise SystemExit(f"API key file is empty: {path}")
    return key


def json_request(url: str, key: str, body: dict | None = None, timeout: int = 600) -> tuple[dict, float]:
    data = None if body is None else json.dumps(body).encode("utf-8")
    headers = {"Authorization": f"Bearer {key}"}
    if data is not None:
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=data, headers=headers)
    started = time.perf_counter()
    with urllib.request.urlopen(request, timeout=timeout) as response:
        payload = json.load(response)
    return payload, time.perf_counter() - started


def chat_content(response: dict) -> str:
    try:
        return response["choices"][0]["message"].get("content") or ""
    except (KeyError, IndexError, TypeError, AttributeError):
        return ""


def completion_tokens(response: dict) -> int:
    try:
        return int(response.get("usage", {}).get("completion_tokens") or 0)
    except (TypeError, ValueError):
        return 0


def common_body(model: str, prompt: str, max_tokens: int) -> dict:
    return {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0,
        "max_tokens": max_tokens,
        "chat_template_kwargs": {"enable_thinking": False},
    }


def capture_record(response: dict, elapsed: float, passed: bool, **extra: object) -> dict:
    tokens = completion_tokens(response)
    return {
        "captured_at": now_utc(),
        "passed": passed,
        "elapsed_seconds": round(elapsed, 3),
        "completion_tokens": tokens,
        "end_to_end_output_tok_s": round(tokens / elapsed, 3) if tokens and elapsed else None,
        **extra,
        "response": response,
    }


def cmd_init(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    profile_root = root / args.profile
    profile_root.mkdir(parents=True, exist_ok=True, mode=0o700)
    stamp = time.strftime("%Y%m%d-%H%M%S", time.localtime())
    run_dir = profile_root / stamp
    suffix = 1
    while run_dir.exists():
        run_dir = profile_root / f"{stamp}-{suffix}"
        suffix += 1
    run_dir.mkdir(mode=0o700)
    metadata = {
        "profile": args.profile,
        "model": args.model,
        "endpoint": args.endpoint.rstrip("/"),
        "max_context": args.max_context,
        "created_at": now_utc(),
    }
    atomic_json(run_dir / "metadata.json", metadata)
    latest = profile_root / "latest"
    if latest.is_symlink() or latest.exists():
        latest.unlink()
    latest.symlink_to(run_dir.name, target_is_directory=True)
    print(f"RESULTS_DIR={run_dir}")


def cmd_identity(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    endpoint = metadata["endpoint"].rstrip("/")
    response, elapsed = json_request(f"{endpoint}/v1/models", key, timeout=args.timeout)
    ids = [item.get("id") for item in response.get("data", []) if isinstance(item, dict)]
    passed = metadata["model"] in ids
    record = capture_record(response, elapsed, passed, expected_model=metadata["model"], returned_ids=ids)
    atomic_json(run_dir / "identity.json", record)
    print(json.dumps(record, indent=2, ensure_ascii=False))
    if not passed:
        raise SystemExit("IDENTITY_TEST_FAILED")
    print("IDENTITY_TEST_OK")


def cmd_chat(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    prompt = (
        "Compare speculative decoding with conventional autoregressive decoding for a local "
        "LLM operator. Give a two-sentence summary, exactly five substantive bullet points, "
        "and a Markdown table with columns Aspect, Speculative, Conventional and rows Latency, "
        "Throughput, and Correctness. End with the exact line QUALITY_TEST_COMPLETE."
    )
    body = common_body(metadata["model"], prompt, args.max_tokens)
    response, elapsed = json_request(
        f"{metadata['endpoint'].rstrip('/')}/v1/chat/completions", key, body, args.timeout
    )
    content = chat_content(response)
    passed = QUALITY_MARKER in content and len(content.split()) >= 120
    record = capture_record(
        response,
        elapsed,
        passed,
        max_tokens=args.max_tokens,
        minimum_words=120,
        observed_words=len(content.split()),
        required_marker=QUALITY_MARKER,
    )
    atomic_json(run_dir / "chat-quality.json", record)
    print(json.dumps(record, indent=2, ensure_ascii=False))
    if not passed:
        raise SystemExit("QUALITY_TEST_FAILED")
    print("QUALITY_TEST_OK")


def cmd_tool(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    body = common_body(metadata["model"], "Use the weather tool for Bengaluru.", args.max_tokens)
    body.update(
        {
            "tools": [
                {
                    "type": "function",
                    "function": {
                        "name": "get_weather",
                        "description": "Return weather for a city",
                        "parameters": {
                            "type": "object",
                            "properties": {"city": {"type": "string"}},
                            "required": ["city"],
                        },
                    },
                }
            ],
            "tool_choice": "auto",
        }
    )
    response, elapsed = json_request(
        f"{metadata['endpoint'].rstrip('/')}/v1/chat/completions", key, body, args.timeout
    )
    try:
        calls = response["choices"][0]["message"].get("tool_calls") or []
        function = calls[0]["function"]
        arguments = function.get("arguments") or ""
        parsed = json.loads(arguments) if isinstance(arguments, str) else arguments
        passed = function.get("name") == "get_weather" and str(parsed.get("city", "")).lower() == "bengaluru"
    except (KeyError, IndexError, TypeError, json.JSONDecodeError, AttributeError):
        passed = False
    record = capture_record(response, elapsed, passed, max_tokens=args.max_tokens)
    atomic_json(run_dir / "tool-call.json", record)
    print(json.dumps(record, indent=2, ensure_ascii=False))
    if not passed:
        raise SystemExit("TOOL_CALL_FAILED")
    print("TOOL_CALL_OK")


def cmd_vision(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    image_path = Path(args.image).expanduser().resolve()
    if not image_path.is_file():
        raise SystemExit(f"Vision fixture is missing: {image_path}")
    digest = hashlib.sha256(image_path.read_bytes()).hexdigest()
    if digest != VISION_SHA256:
        raise SystemExit(f"Vision fixture hash mismatch: expected {VISION_SHA256}, got {digest}")
    mime = "image/png" if image_path.suffix.lower() == ".png" else "image/jpeg"
    prompt = (
        "List every visible shape with its color and count, then state the total number of "
        "objects. Do not infer from the filename or metadata. End with exactly one machine-readable "
        "line in this format, replacing each placeholder with the count you actually observe: "
        "VISION_COUNTS red_triangle=<integer> blue_circles=<integer> "
        "green_squares=<integer> yellow_star=<integer> total=<integer>"
    )
    body = {
        "model": metadata["model"],
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{mime};base64,{base64.b64encode(image_path.read_bytes()).decode('ascii')}"
                        },
                    },
                ],
            }
        ],
        "temperature": 0,
        "max_tokens": args.max_tokens,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    response, elapsed = json_request(
        f"{metadata['endpoint'].rstrip('/')}/v1/chat/completions", key, body, args.timeout
    )
    content = chat_content(response)
    passed = VISION_MARKER in content
    record = capture_record(
        response,
        elapsed,
        passed,
        max_tokens=args.max_tokens,
        image=str(image_path),
        image_sha256=digest,
        required_marker=VISION_MARKER,
    )
    atomic_json(run_dir / "vision.json", record)
    print(json.dumps(record, indent=2, ensure_ascii=False))
    if not passed:
        raise SystemExit("VISION_TEST_FAILED")
    print("VISION_TEST_OK")


def cmd_context(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    marker = "ORANGE-427"
    counts = [int(item) for item in args.filler_counts.split(",") if item.strip()]
    for count in counts:
        prompt = f"Remember this marker: {marker}. " + ("x " * count) + "Reply with only the marker."
        body = common_body(metadata["model"], prompt, args.max_tokens)
        response, elapsed = json_request(
            f"{metadata['endpoint'].rstrip('/')}/v1/chat/completions", key, body, args.timeout
        )
        content = chat_content(response).strip()
        prompt_tokens = int(response.get("usage", {}).get("prompt_tokens") or 0)
        passed = 0 < prompt_tokens <= int(metadata["max_context"]) and marker in content
        record = capture_record(
            response,
            elapsed,
            passed,
            filler_count=count,
            prompt_tokens=prompt_tokens,
            max_context=int(metadata["max_context"]),
            expected_marker=marker,
            observed_answer=content,
            note="Output is intentionally short; this probe measures long-context retrieval and TTFT.",
        )
        label = args.label.strip().lower().replace(" ", "-")
        path = run_dir / f"context-{label}-{count}.json"
        atomic_json(path, record)
        print(json.dumps(record, indent=2, ensure_ascii=False))
        if not passed:
            raise SystemExit(f"CONTEXT_TEST_FAILED at filler_count={count}")
    print("CONTEXT_LADDER_OK")


def one_concurrency_request(endpoint: str, key: str, model: str, max_tokens: int, timeout: int) -> dict:
    prompt = (
        "Write a detailed implementation plan for an offline-first job queue. Cover persistence, "
        "idempotency, retries, backpressure, observability, recovery, and testing. Use clear "
        "headings and concrete technical details. Continue until every section is complete."
    )
    response, elapsed = json_request(
        f"{endpoint.rstrip('/')}/v1/chat/completions",
        key,
        common_body(model, prompt, max_tokens),
        timeout,
    )
    tokens = completion_tokens(response)
    return {
        "elapsed_seconds": round(elapsed, 3),
        "completion_tokens": tokens,
        "output_tok_s": round(tokens / elapsed, 3) if tokens and elapsed else None,
        "finish_reason": (response.get("choices") or [{}])[0].get("finish_reason"),
        "response": response,
    }


def cmd_concurrency(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    run_dir, metadata = metadata_for(root, args.profile)
    key = key_from(args.key_file)
    levels = [int(item) for item in args.levels.split(",") if item.strip()]
    rows = []
    label = args.label.strip().lower().replace(" ", "-")
    output_name = "concurrency.json" if label == "raw" else f"concurrency-{label}.json"
    for level in levels:
        started = time.perf_counter()
        with concurrent.futures.ThreadPoolExecutor(max_workers=level) as executor:
            futures = [
                executor.submit(
                    one_concurrency_request,
                    metadata["endpoint"],
                    key,
                    metadata["model"],
                    args.max_tokens,
                    args.timeout,
                )
                for _ in range(level)
            ]
            requests = [future.result() for future in futures]
        wall = time.perf_counter() - started
        total = sum(item["completion_tokens"] for item in requests)
        passed = all(item["completion_tokens"] >= args.minimum_tokens for item in requests)
        row = {
            "concurrency": level,
            "passed": passed,
            "wall_seconds": round(wall, 3),
            "completion_tokens_total": total,
            "aggregate_output_tok_s": round(total / wall, 3) if total and wall else None,
            "per_request_output_tok_s": [item["output_tok_s"] for item in requests],
            "requests": requests,
        }
        rows.append(row)
        print(json.dumps(row, indent=2, ensure_ascii=False))
        if not passed:
            atomic_json(
                run_dir / output_name,
                {"captured_at": now_utc(), "layer": label, "levels": rows},
            )
            raise SystemExit(f"CONCURRENCY_TEST_FAILED at level={level}")
    atomic_json(
        run_dir / output_name,
        {
            "captured_at": now_utc(),
            "layer": label,
            "max_tokens": args.max_tokens,
            "minimum_tokens_per_request": args.minimum_tokens,
            "levels": rows,
        },
    )
    print("CONCURRENCY_LADDER_OK")


def status_word(path: Path) -> str:
    if not path.is_file():
        return "not run"
    try:
        return "pass" if read_json(path).get("passed") else "fail"
    except (OSError, ValueError, TypeError):
        return "invalid"


def cmd_compare(args: argparse.Namespace) -> None:
    root = result_root(args.root)
    profiles = args.profiles.split(",")
    rows = []
    for profile in profiles:
        profile = profile.strip()
        if not profile:
            continue
        try:
            run_dir, metadata = metadata_for(root, profile)
        except SystemExit:
            rows.append([profile, "not run", "—", "—", "—", "—", "—", "—", "—", "—"])
            continue
        chat_path = run_dir / "chat-quality.json"
        chat = read_json(chat_path) if chat_path.is_file() else {}
        contexts = []
        for path in run_dir.glob("context-*.json"):
            try:
                record = read_json(path)
                if record.get("passed"):
                    contexts.append(int(record.get("prompt_tokens") or 0))
            except (OSError, ValueError, TypeError):
                pass
        conc = {}
        conc_path = run_dir / "concurrency.json"
        if conc_path.is_file():
            for item in read_json(conc_path).get("levels", []):
                conc[int(item["concurrency"])] = item.get("aggregate_output_tok_s")
        rows.append(
            [
                profile,
                run_dir.name,
                "pass" if chat.get("passed") else ("fail" if chat else "not run"),
                str(chat.get("end_to_end_output_tok_s") or "—"),
                status_word(run_dir / "tool-call.json"),
                status_word(run_dir / "vision.json"),
                f"{max(contexts):,}" if contexts else "—",
                str(conc.get(1, "—")),
                str(conc.get(2, "—")),
                str(conc.get(4, "—")),
            ]
        )
    header = [
        "Profile",
        "Run",
        "Quality",
        "Quality tok/s",
        "Tools",
        "Vision",
        "Max passing prompt tokens",
        "C1 aggregate tok/s",
        "C2 aggregate tok/s",
        "C4 aggregate tok/s",
    ]
    lines = [
        "# Frontier Model Comparison",
        "",
        f"Generated: {now_utc()}",
        "",
        "| " + " | ".join(header) + " |",
        "|" + "|".join(["---"] * len(header)) + "|",
    ]
    lines.extend("| " + " | ".join(row) + " |" for row in rows)
    lines.extend(
        [
            "",
            "> Output rates are end-to-end measurements from the standardized local probe. "
            "They are not interchangeable with pure decode or prefill benchmarks.",
            "",
        ]
    )
    output = Path(args.output).expanduser().resolve() if args.output else root / "comparison.md"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")
    print(output.read_text(encoding="utf-8"))
    print(f"COMPARISON_WRITTEN={output}")


def parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--profile", required=True)
    common.add_argument("--root")
    common.add_argument("--key-file")
    common.add_argument("--timeout", type=int, default=1800)

    root = argparse.ArgumentParser(description=__doc__)
    commands = root.add_subparsers(dest="command", required=True)

    init = commands.add_parser("init")
    init.add_argument("--profile", required=True)
    init.add_argument("--model", required=True)
    init.add_argument("--endpoint", default=DEFAULT_ENDPOINT)
    init.add_argument("--max-context", type=int, required=True)
    init.add_argument("--root")
    init.set_defaults(func=cmd_init)

    identity = commands.add_parser("identity", parents=[common])
    identity.set_defaults(func=cmd_identity)

    chat = commands.add_parser("chat", parents=[common])
    chat.add_argument("--max-tokens", type=int, default=1024)
    chat.set_defaults(func=cmd_chat)

    tool = commands.add_parser("tool", parents=[common])
    tool.add_argument("--max-tokens", type=int, default=512)
    tool.set_defaults(func=cmd_tool)

    vision = commands.add_parser("vision", parents=[common])
    vision.add_argument("--image", default="~/test-assets/frontier-vision-test.png")
    vision.add_argument("--max-tokens", type=int, default=768)
    vision.set_defaults(func=cmd_vision)

    context = commands.add_parser("context", parents=[common])
    context.add_argument("--filler-counts", required=True)
    context.add_argument("--max-tokens", type=int, default=64)
    context.add_argument("--label", default="raw")
    context.set_defaults(func=cmd_context)

    concurrency = commands.add_parser("concurrency", parents=[common])
    concurrency.add_argument("--levels", required=True)
    concurrency.add_argument("--max-tokens", type=int, default=512)
    concurrency.add_argument("--minimum-tokens", type=int, default=128)
    concurrency.add_argument("--label", default="raw")
    concurrency.set_defaults(func=cmd_concurrency)

    compare = commands.add_parser("compare")
    compare.add_argument("--root")
    compare.add_argument(
        "--profiles",
        default="qwen38-nvfp4,qwen38-fp8,glm53-flash,deepseek41-flash",
    )
    compare.add_argument("--output")
    compare.set_defaults(func=cmd_compare)
    return root


def main() -> None:
    args = parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
