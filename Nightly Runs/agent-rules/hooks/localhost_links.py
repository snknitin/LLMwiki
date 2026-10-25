"""Claude Code Stop hook: a reply that hands the owner a localhost link is sent back once to use the tailnet link.

The rule lives in agent-rules/AGENTS.md ("Links for the owner"); this makes it deterministic instead of remembered.
Links inside code (backticks or fenced blocks) are ignored: those are code, not links for the owner.
Run `python -I localhost_links.py --test` for the self-check.
"""
import json
import re
import subprocess
import sys

LINK = re.compile(r"\b(?:https?://)?(?:localhost|127\.0\.0\.1|0\.0\.0\.0)(?::(\d+))?(?:/\S*)?", re.I)
CODE = re.compile(r"```.*?```|`[^`\n]*`", re.S)


def local_links(text):
    return [m.group(0) for m in LINK.finditer(CODE.sub("", text)) if m.group(1) or m.group(0).lower().startswith("http")]


def last_reply(payload):
    if payload.get("last_assistant_message"):
        return payload["last_assistant_message"]
    texts = []
    try:
        with open(payload["transcript_path"], encoding="utf-8") as f:
            for line in f:
                entry = json.loads(line)
                content = (entry.get("message") or {}).get("content")
                if entry.get("type") == "user" and not (isinstance(content, list) and all(c.get("type") == "tool_result" for c in content)):
                    texts = []  # a real prompt starts a new turn
                elif entry.get("type") == "assistant" and isinstance(content, list):
                    texts += [c.get("text", "") for c in content if c.get("type") == "text"]
    except (KeyError, OSError, ValueError):
        return ""
    return "\n".join(texts)


def tailnet_host():
    try:
        out = subprocess.run(["tailscale", "status", "--json"], capture_output=True, text=True, timeout=5).stdout
        return json.loads(out)["Self"]["DNSName"].rstrip(".")
    except Exception:
        return "<host>.tail4a1242.ts.net"


def main():
    payload = json.load(sys.stdin)
    if payload.get("stop_hook_active"):
        return  # already sent back once this turn; never loop
    links = local_links(last_reply(payload))
    if not links:
        return
    host = tailnet_host()
    print(json.dumps({"decision": "block", "reason": (
        f"Your reply gives the owner a localhost link ({', '.join(sorted(set(links)))}), which won't open on their other machines or phone. "
        f"Publish the port with `tailscale serve --bg --https=<port> http://127.0.0.1:<port>`, open https://{host}:<port>/ yourself, "
        "then rewrite the reply with that link. If Tailscale isn't working, say so instead. If the address was only an example, put it in backticks.")}))


def test():
    assert local_links("open http://localhost:5173/app now") == ["http://localhost:5173/app"]
    assert local_links("it is on 127.0.0.1:8787") == ["127.0.0.1:8787"]
    assert local_links("serve on `127.0.0.1` and `http://localhost:3000`") == []
    assert local_links("```\ncurl http://localhost:8080\n```") == []
    assert local_links("bind to localhost only") == []
    print("ok")


if __name__ == "__main__":
    test() if "--test" in sys.argv else main()
