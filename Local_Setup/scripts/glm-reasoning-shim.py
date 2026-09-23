#!/usr/bin/env python3
"""Translate vLLM ``reasoning`` fields for LiteLLM's OpenAI adapter.

The pinned GLM vLLM build emits reasoning deltas as ``delta.reasoning``.
LiteLLM 1.81.3 expects ``delta.reasoning_content`` and otherwise emits empty
stream chunks. This private bridge rewrites only that field and proxies every
other request and response unchanged.
"""

from __future__ import annotations

import argparse
import http.client
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any


HOP_BY_HOP = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailer",
    "transfer-encoding",
    "upgrade",
}


def rewrite_reasoning(value: Any) -> Any:
    """Rename vLLM's response field recursively without changing its value."""
    if isinstance(value, dict):
        if "reasoning" in value and "reasoning_content" not in value:
            value["reasoning_content"] = value.pop("reasoning")
        for item in value.values():
            rewrite_reasoning(item)
    elif isinstance(value, list):
        for item in value:
            rewrite_reasoning(item)
    return value


class ReasoningBridge(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "glm-reasoning-shim/1"

    def log_message(self, fmt: str, *args: Any) -> None:
        # Never log request bodies or Authorization headers.
        super().log_message(fmt, *args)

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/_shim/health":
            body = b'{"status":"ok"}'
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        self._proxy()

    def do_POST(self) -> None:  # noqa: N802
        self._proxy()

    def _proxy(self) -> None:
        content_length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(content_length) if content_length else None
        headers = {
            name: value
            for name, value in self.headers.items()
            if name.lower() not in HOP_BY_HOP | {"host", "content-length"}
        }
        headers["Host"] = f"{self.server.upstream_host}:{self.server.upstream_port}"
        if body is not None:
            headers["Content-Length"] = str(len(body))

        upstream = http.client.HTTPConnection(
            self.server.upstream_host,
            self.server.upstream_port,
            timeout=self.server.upstream_timeout,
        )
        try:
            upstream.request(self.command, self.path, body=body, headers=headers)
            response = upstream.getresponse()
            content_type = response.getheader("Content-Type", "")
            if "text/event-stream" in content_type:
                self._stream_sse(response)
            else:
                self._send_buffered(response)
        except (BrokenPipeError, ConnectionResetError):
            return
        except (OSError, TimeoutError, http.client.HTTPException) as exc:
            self._send_upstream_error(type(exc).__name__)
        finally:
            upstream.close()

    def _response_headers(self, response: http.client.HTTPResponse) -> None:
        for name, value in response.getheaders():
            if name.lower() not in HOP_BY_HOP | {"content-length"}:
                self.send_header(name, value)

    def _stream_sse(self, response: http.client.HTTPResponse) -> None:
        self.send_response(response.status, response.reason)
        self._response_headers(response)
        self.send_header("Connection", "close")
        self.end_headers()
        self.close_connection = True

        while True:
            line = response.readline()
            if not line:
                break
            if line.startswith(b"data: ") and line.strip() != b"data: [DONE]":
                try:
                    payload = json.loads(line[6:])
                    rewrite_reasoning(payload)
                    line = b"data: " + json.dumps(
                        payload, ensure_ascii=False, separators=(",", ":")
                    ).encode("utf-8") + b"\n"
                except (json.JSONDecodeError, UnicodeDecodeError):
                    pass
            self.wfile.write(line)
            self.wfile.flush()

    def _send_buffered(self, response: http.client.HTTPResponse) -> None:
        data = response.read()
        content_type = response.getheader("Content-Type", "")
        if "application/json" in content_type and data:
            try:
                payload = json.loads(data)
                rewrite_reasoning(payload)
                data = json.dumps(
                    payload, ensure_ascii=False, separators=(",", ":")
                ).encode("utf-8")
            except (json.JSONDecodeError, UnicodeDecodeError):
                pass
        self.send_response(response.status, response.reason)
        self._response_headers(response)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_upstream_error(self, error_type: str) -> None:
        data = json.dumps(
            {"error": {"message": "GLM upstream unavailable", "type": error_type}},
            separators=(",", ":"),
        ).encode("utf-8")
        self.send_response(502)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


class BridgeServer(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True

    def __init__(
        self,
        address: tuple[str, int],
        handler: type[BaseHTTPRequestHandler],
        upstream_host: str,
        upstream_port: int,
        upstream_timeout: int,
    ) -> None:
        self.upstream_host = upstream_host
        self.upstream_port = upstream_port
        self.upstream_timeout = upstream_timeout
        super().__init__(address, handler)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--listen-host", required=True)
    parser.add_argument("--listen-port", type=int, default=8101)
    parser.add_argument("--upstream-host", default="127.0.0.1")
    parser.add_argument("--upstream-port", type=int, default=8100)
    parser.add_argument("--upstream-timeout", type=int, default=3600)
    args = parser.parse_args()

    server = BridgeServer(
        (args.listen_host, args.listen_port),
        ReasoningBridge,
        args.upstream_host,
        args.upstream_port,
        args.upstream_timeout,
    )
    server.serve_forever()


if __name__ == "__main__":
    main()
