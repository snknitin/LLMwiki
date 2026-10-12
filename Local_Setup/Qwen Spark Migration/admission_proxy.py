#!/usr/bin/env python3
"""Private, text-chat-only admission for one dedicated llama.cpp b11429 server.

No model fallback, output-cap rewriting, prompt logging, or external dependencies
beyond aiohttp (already present in Hermes' venv). Client disconnects are drained
to backend EOF while retaining their reservation. Ambiguous upstream failures
freeze new admissions until every backend slot is confirmed idle repeatedly.
"""
from __future__ import annotations

import asyncio
from collections import deque
import contextlib
from dataclasses import dataclass
import json
import logging
import os
import time

LOG = logging.getLogger("qwen-admission")
PER_REQUEST = 262144
POOL = 1048576  # Four independently allocated 262144-token native slots (Q4 KV).
MAX_ACTIVE = 4
MAX_WAITING = 8
QUEUE_SECONDS = 120
MARGIN = 256


class Rejected(Exception):
    def __init__(self, message, status=503):
        self.message, self.status = message, status


@dataclass(eq=False)
class Lease:
    tokens: int
    uncertain: bool = False


class Admission:
    def __init__(self, pool=POOL, slots=MAX_ACTIVE, waiting=MAX_WAITING,
                 timeout=QUEUE_SECONDS, initially_frozen=True):
        self.pool, self.slots, self.waiting, self.timeout = pool, slots, waiting, timeout
        self.condition = asyncio.Condition()
        self.queue, self.active = deque(), set()
        self.frozen = initially_frozen
        self.uncertain_since = time.monotonic() if initially_frozen else 0

    def stats(self):
        return {"active": len(self.active), "queued": len(self.queue),
                "reserved_tokens": sum(x.tokens for x in self.active),
                "pool_tokens": self.pool, "max_active": self.slots,
                "per_request_tokens": PER_REQUEST, "accepting": not self.frozen}

    async def acquire(self, tokens):
        if not 0 < tokens <= self.pool:
            raise Rejected("Request cannot fit the configured token pool.", 400)
        marker = object()
        async with self.condition:
            if self.frozen:
                raise Rejected("Backend state is being verified; retry later.")
            if len(self.queue) >= self.waiting:
                raise Rejected("Admission queue is full; retry later.")
            self.queue.append(marker)
            deadline = time.monotonic() + self.timeout
            try:
                while True:
                    if self.frozen:
                        raise Rejected("Backend state is uncertain; retry later.")
                    fits = (len(self.active) < self.slots and
                            sum(x.tokens for x in self.active) + tokens <= self.pool)
                    if self.queue[0] is marker and fits:
                        self.queue.popleft()
                        lease = Lease(tokens)
                        self.active.add(lease)
                        self.condition.notify_all()
                        return lease
                    remaining = deadline - time.monotonic()
                    if remaining <= 0:
                        raise Rejected("Admission queue timed out; retry later.")
                    try:
                        await asyncio.wait_for(self.condition.wait(), remaining)
                    except asyncio.TimeoutError:
                        raise Rejected("Admission queue timed out; retry later.") from None
            finally:
                if marker in self.queue:
                    self.queue.remove(marker)
                self.condition.notify_all()

    async def finish(self, lease, certain):
        async with self.condition:
            if certain:
                self.active.discard(lease)
            else:
                lease.uncertain = True
                self.frozen = True
                self.uncertain_since = time.monotonic()
            self.condition.notify_all()

    async def recover(self):
        async with self.condition:
            # Never release another live HTTP request's reservation.
            if any(not lease.uncertain for lease in self.active):
                return False
            self.active.clear()
            self.frozen = False
            self.condition.notify_all()
            return True


def validate(body):
    if not isinstance(body, dict) or not isinstance(body.get("messages"), list):
        raise Rejected("A chat messages array is required.", 400)
    if body.get("n", 1) != 1:
        raise Rejected("Only n=1 is supported by this admission route.", 400)
    # Native aliases can override OpenAI limits or create extra inference jobs.
    unsupported = {"n_predict", "prompt", "id_slot", "n_ctx", "n_parallel",
                   "context_shift", "n_keep", "cache_prompt", "stream_id",
                   "resumable", "background", "lora", "mirostat"}
    if unsupported.intersection(body):
        raise Rejected("Unsupported native routing or execution override.", 400)
    opts = body.get("stream_options")
    if opts is not None and (not isinstance(opts, dict) or
                            set(opts) - {"include_usage"}):
        raise Rejected("Only stream_options.include_usage is supported.", 400)
    for msg in body["messages"]:
        if not isinstance(msg, dict):
            raise Rejected("Every message must be an object.", 400)
        content = msg.get("content")
        if isinstance(content, list):
            if any(not isinstance(part, dict) or part.get("type") != "text"
                   or not isinstance(part.get("text"), str) for part in content):
                raise Rejected("This route accepts text and tool messages only.", 400)
        elif content is not None and not isinstance(content, str):
            raise Rejected("Unsupported message content.", 400)
    caps = [body[key] for key in ("max_tokens", "max_completion_tokens")
            if key in body and body[key] is not None]
    if any(type(cap) is not int or cap <= 0 for cap in caps):
        raise Rejected("Output token limits must be positive integers.", 400)
    if len(set(caps)) > 1:
        raise Rejected("Conflicting output token limits.", 400)
    return caps[0] if caps else None


def reservation(input_tokens, output_cap):
    if type(input_tokens) is not int or input_tokens < 0:
        raise Rejected("Backend token-count response is invalid.")
    if input_tokens >= PER_REQUEST:
        raise Rejected("Prompt leaves no room within the 262144-token context.", 400)
    if output_cap is None:
        return PER_REQUEST
    if input_tokens + output_cap > PER_REQUEST:
        raise Rejected("Prompt plus requested output exceeds 262144 tokens.", 400)
    return min(PER_REQUEST, input_tokens + output_cap + MARGIN)


def create_app(backend="http://127.0.0.1:1236", model="qwen38-27b-spark",
               admission=None, backend_seconds=7200, recovery_interval=2,
               recovery_grace=10):
    from aiohttp import ClientSession, ClientTimeout, web
    gate = admission or Admission()
    app = web.Application(client_max_size=8 * 1024 * 1024)
    ingress = 0

    def error(message, status=503):
        headers = {"Retry-After": "5"} if status == 503 else {}
        return web.json_response({"error": {"message": message,
            "type": "admission_error"}}, status=status, headers=headers)

    async def json_call(path, body=None):
        async with app["session"].request("GET" if body is None else "POST",
                backend + path, json=body, timeout=ClientTimeout(total=120)) as response:
            if response.status != 200:
                raise Rejected("Backend is unavailable or rejected token counting.")
            return await response.json()

    async def recover_loop():
        idle_samples = 0
        while True:
            await asyncio.sleep(recovery_interval)
            if not gate.frozen:
                idle_samples = 0
                continue
            try:
                slots = await json_call("/slots")
                valid = (isinstance(slots, list) and len(slots) == gate.slots and
                         all(type(s.get("is_processing")) is bool and
                             not s["is_processing"] and s.get("n_ctx") == PER_REQUEST
                             for s in slots))
                old_enough = time.monotonic() - gate.uncertain_since >= recovery_grace
                idle_samples = idle_samples + 1 if valid and old_enough else 0
                if idle_samples >= 3 and await gate.recover():
                    LOG.info("admission_recovered %s", json.dumps(gate.stats()))
            except Exception:
                idle_samples = 0

    async def startup(_app):
        headers = {}
        if os.environ.get("QWEN_BACKEND_API_KEY"):
            headers["Authorization"] = "Bearer " + os.environ["QWEN_BACKEND_API_KEY"]
        app["session"] = ClientSession(headers=headers,
            timeout=ClientTimeout(total=backend_seconds, sock_connect=10))
        app["recovery"] = asyncio.create_task(recover_loop())

    async def cleanup(_app):
        app["recovery"].cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await app["recovery"]
        await app["session"].close()

    async def health(_request):
        try:
            await json_call("/health")
        except Exception:
            return error("Backend unavailable.")
        return web.json_response(gate.stats(), status=503 if gate.frozen else 200)

    async def models(_request):
        try:
            return web.json_response(await json_call("/v1/models"))
        except Exception:
            return error("Backend unavailable.")

    async def chat(request):
        nonlocal ingress
        if ingress >= gate.slots + gate.waiting:
            return error("Admission queue is full; retry later.")
        ingress += 1
        lease, certain, outgoing = None, True, None
        try:
            try:
                body = await request.json()
            except (ValueError, UnicodeError):
                raise Rejected("Invalid JSON request.", 400) from None
            cap = validate(body)
            if body.get("model") != model:
                raise Rejected("This route serves only its configured Spark model.", 400)
            if gate.frozen:
                raise Rejected("Backend state is being verified; retry later.")
            counted = await json_call("/v1/chat/completions/input_tokens", body)
            tokens = reservation(counted.get("input_tokens"), cap)
            lease = await gate.acquire(tokens)
            # A disconnected queued caller must not start new inference.
            if request.transport is None or request.transport.is_closing():
                return error("Client disconnected before admission.", 499)
            LOG.info("admitted %s", json.dumps(gate.stats()))
            certain = False
            async with app["session"].post(backend + "/v1/chat/completions", json=body) as upstream:
                outgoing = web.StreamResponse(status=upstream.status,
                    headers={"Content-Type": upstream.headers.get("Content-Type", "application/json"),
                             "Cache-Control": "no-cache"})
                connected = True
                try:
                    await outgoing.prepare(request)
                except (ConnectionError, RuntimeError):
                    connected = False
                async for chunk in upstream.content.iter_chunked(32768):
                    if connected:
                        try:
                            await asyncio.wait_for(outgoing.write(chunk), timeout=30)
                        except (ConnectionError, RuntimeError, asyncio.TimeoutError):
                            connected = False
                    # Otherwise drain without forwarding; keep reservation to EOF.
                certain = True
                if connected:
                    with contextlib.suppress(ConnectionError, RuntimeError):
                        await outgoing.write_eof()
                return outgoing
        except Rejected as exc:
            return error(exc.message, exc.status)
        except web.HTTPRequestEntityTooLarge:
            return error("Request body exceeds 8 MiB.", 413)
        except asyncio.CancelledError:
            raise
        except Exception:
            # Never log exceptions: upstream error details can contain user text.
            LOG.warning("upstream_interrupted")
            if outgoing is not None and outgoing.prepared:
                outgoing.force_close()
                return outgoing
            return error("Backend interrupted; admission paused pending idle verification.")
        finally:
            if lease is not None:
                await asyncio.shield(gate.finish(lease, certain))
                LOG.info("finished %s", json.dumps(gate.stats()))
            ingress -= 1

    app.on_startup.append(startup)
    app.on_cleanup.append(cleanup)
    app.router.add_get("/health", health)
    app.router.add_get("/v1/health", health)
    app.router.add_get("/v1/models", models)
    app.router.add_post("/v1/chat/completions", chat)
    app["gate"] = gate
    return app


if __name__ == "__main__":
    from aiohttp import web
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
    logging.getLogger("aiohttp").setLevel(logging.CRITICAL)
    web.run_app(create_app(), host="127.0.0.1", port=1235,
                access_log=None, print=None, handler_cancellation=False)
