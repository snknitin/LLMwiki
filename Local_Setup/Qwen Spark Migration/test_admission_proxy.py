"""Run with Hermes' Python venv. Uses ephemeral loopback fake servers only."""
import asyncio
import contextlib
import unittest
import admission_proxy as proxy


class CoreTests(unittest.IsolatedAsyncioTestCase):
    def test_reservation(self):
        self.assertEqual(proxy.reservation(1000, None), 262144)
        self.assertEqual(proxy.reservation(1000, 32768), 34024)
        self.assertEqual(proxy.reservation(262000, 144), 262144)
        for count, cap in [(262144, None), (262000, 145), (-1, 10), (True, 10)]:
            with self.assertRaises(proxy.Rejected):
                proxy.reservation(count, cap)

    def test_validation(self):
        body = {"messages": [{"role": "assistant", "content": None,
                  "tool_calls": [{"id": "a", "function": {"name": "test", "arguments": "{}"}}]}],
                "tools": [{"type": "function", "function": {"name": "test"}}],
                "max_tokens": 32768}
        self.assertEqual(proxy.validate(body), 32768)
        for patch in [{"n": 2}, {"n_predict": -1}, {"max_tokens": -1},
                      {"max_tokens": True}, {"max_completion_tokens": 50},
                      {"stream_options": {"resumable": True}},
                      {"messages": [{"content": [{"type": "image_url"}]}]}]:
            with self.assertRaises(proxy.Rejected):
                proxy.validate({**body, **patch})

    async def test_fifo_and_cancelled_waiter(self):
        gate = proxy.Admission(pool=100, slots=4, waiting=3, initially_frozen=False)
        first = await gate.acquire(80)
        big = asyncio.create_task(gate.acquire(80))
        await asyncio.sleep(0)
        small = asyncio.create_task(gate.acquire(10))
        await asyncio.sleep(0.01)
        self.assertFalse(big.done())
        self.assertFalse(small.done())  # no bypassing the FIFO head
        big.cancel()
        with self.assertRaises(asyncio.CancelledError):
            await big
        second = await asyncio.wait_for(small, 1)
        self.assertEqual(gate.stats()["reserved_tokens"], 90)
        await gate.finish(first, True)
        await gate.finish(second, True)
        self.assertEqual(gate.stats()["reserved_tokens"], 0)

    async def test_queue_bound_and_timeout(self):
        gate = proxy.Admission(pool=100, slots=1, waiting=1,
                               timeout=0.04, initially_frozen=False)
        lease = await gate.acquire(100)
        waiter = asyncio.create_task(gate.acquire(100))
        await asyncio.sleep(0)
        with self.assertRaises(proxy.Rejected):
            await gate.acquire(1)
        with self.assertRaises(proxy.Rejected):
            await waiter
        self.assertEqual(len(gate.queue), 0)
        await gate.finish(lease, True)

    async def test_uncertain_holds_budget_and_live_lease_blocks_recovery(self):
        gate = proxy.Admission(pool=100, initially_frozen=False)
        a, b = await gate.acquire(30), await gate.acquire(40)
        await gate.finish(a, False)
        self.assertEqual(gate.stats()["reserved_tokens"], 70)
        with self.assertRaises(proxy.Rejected):
            await gate.acquire(1)
        self.assertFalse(await gate.recover())
        await gate.finish(b, True)
        self.assertTrue(await gate.recover())
        self.assertEqual(gate.stats()["reserved_tokens"], 0)


try:
    from aiohttp import web
    from aiohttp.test_utils import TestClient, TestServer

    class DrainTestServer(TestServer):
        async def _make_runner(self, **kwargs):
            kwargs["handler_cancellation"] = False
            return await super()._make_runner(**kwargs)
except ImportError:
    web = None


@unittest.skipIf(web is None, "aiohttp is required for HTTP integration tests")
class HttpTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.input_count = 1000
        self.count_status = 200
        self.sent = []
        self.started = 0
        self.finished = asyncio.Event()
        self.finished.set()
        self.slots_idle = True
        self.counted = None

        async def count(request):
            self.counted = await request.json()
            return web.json_response({"input_tokens": self.input_count}, status=self.count_status)

        async def generate(request):
            self.sent.append(await request.json())
            self.started += 1
            self.slots_idle = False
            response = web.StreamResponse(headers={"Content-Type": "text/event-stream"})
            await response.prepare(request)
            await response.write(b'data: {"choices": []}\n\n')
            try:
                await self.finished.wait()
                with contextlib.suppress(ConnectionError):
                    await response.write(b'data: [DONE]\n\n')
                    await response.write_eof()
            finally:
                self.slots_idle = True
            return response

        async def slots(_request):
            return web.json_response([{"n_ctx": proxy.PER_REQUEST,
                "is_processing": not self.slots_idle} for _ in range(4)])

        backend = web.Application()
        backend.router.add_post("/v1/chat/completions/input_tokens", count)
        backend.router.add_post("/v1/chat/completions", generate)
        backend.router.add_get("/slots", slots)
        backend.router.add_get("/health", lambda _: web.json_response({"status": "ok"}))
        backend.router.add_get("/v1/models", lambda _: web.json_response({"data": [{"id": "qwen38-27b-spark"}]}))
        self.backend = TestServer(backend)
        await self.backend.start_server()
        self.gate = proxy.Admission(initially_frozen=False, timeout=0.3)
        app = proxy.create_app(str(self.backend.make_url("")).rstrip("/"), admission=self.gate,
            backend_seconds=1, recovery_interval=0.03, recovery_grace=0.05)
        self.client = TestClient(DrainTestServer(app))
        await self.client.start_server()

    async def asyncTearDown(self):
        self.finished.set()
        await self.client.close()
        await self.backend.close()

    def body(self, **extras):
        return {"model": "qwen38-27b-spark", "messages": [{"role": "user", "content": "test"}],
                "stream": True, **extras}

    async def test_body_tools_and_limits_are_not_rewritten(self):
        body = self.body(max_tokens=32768, tools=[{"type": "function", "function": {"name": "x"}}])
        response = await self.client.post("/v1/chat/completions", json=body)
        self.assertEqual(response.status, 200)
        self.assertIn(b"[DONE]", await response.read())
        self.assertEqual(self.sent, [body])
        self.assertEqual(self.counted, body)
        self.assertEqual(self.gate.stats()["active"], 0)

    async def test_fail_closed_counting_and_context_overflow(self):
        self.count_status = 503
        r = await self.client.post("/v1/chat/completions", json=self.body())
        self.assertEqual(r.status, 503)
        self.count_status, self.input_count = 200, 262140
        r = await self.client.post("/v1/chat/completions", json=self.body(max_tokens=100))
        self.assertEqual(r.status, 400)
        self.assertEqual(self.started, 0)
        r = await self.client.post("/models/load", json={})
        self.assertEqual(r.status, 404)

    async def test_missing_limits_reserve_full_slots_and_disconnect_drains(self):
        self.finished.clear()
        active = [await self.client.post("/v1/chat/completions", json=self.body()) for _ in range(4)]
        active[0].close()
        fifth = asyncio.create_task(self.client.post("/v1/chat/completions", json=self.body()))
        await asyncio.sleep(0.08)
        self.assertEqual(self.started, 4)
        self.assertEqual(self.gate.stats()["reserved_tokens"], 1048576)
        if fifth.done():
            early = await fifth
            self.fail(f"Fifth request returned early: {early.status} {await early.text()}; {self.gate.stats()}")
        self.finished.set()
        for response in active[1:]:
            await response.read()
        last = await fifth
        await last.read()
        await asyncio.sleep(0.03)
        self.assertEqual(self.started, 5)
        self.assertEqual(self.gate.stats()["reserved_tokens"], 0)

    async def test_timeout_quarantines_then_requires_idle_recovery(self):
        self.finished.clear()
        response = await self.client.post("/v1/chat/completions", json=self.body(max_tokens=10))
        with contextlib.suppress(Exception):
            await response.read()
        self.assertTrue(self.gate.frozen)
        self.assertGreater(self.gate.stats()["reserved_tokens"], 0)
        self.finished.set()
        await asyncio.sleep(0.2)
        self.assertFalse(self.gate.frozen)
        self.assertEqual(self.gate.stats()["reserved_tokens"], 0)


if __name__ == "__main__":
    unittest.main()
