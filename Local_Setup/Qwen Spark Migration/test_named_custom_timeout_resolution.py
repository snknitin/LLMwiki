"""Real config/resolver/agent integration; no endpoint calls or live Hermes home."""
from __future__ import annotations

import socket

import pytest


@pytest.fixture
def configured_home(tmp_path, monkeypatch):
    monkeypatch.setenv("HERMES_HOME", str(tmp_path))
    monkeypatch.delenv("HERMES_PROFILE", raising=False)
    (tmp_path / ".env").write_text("", encoding="utf-8")
    from hermes_cli.config import atomic_config_replace

    atomic_config_replace(tmp_path / "config.yaml", {"providers": {
        "local-timeout-test": {
            "base_url": "http://127.0.0.1:1235/v1", "api_key": "local-test",
            "request_timeout_seconds": 7200, "stale_timeout_seconds": 7200,
            "models": {"test-model": {"context_length": 262144},
                       "special": {"timeout_seconds": 111, "stale_timeout_seconds": 222}},
        },
        "other-local": {"base_url": "http://127.0.0.1:1236/v1"},
        "custom": {"request_timeout_seconds": 80},
        "openrouter": {"request_timeout_seconds": 45, "stale_timeout_seconds": 60},
    }})

    def deny_connection(*_args, **_kwargs):
        raise AssertionError("Integration test must not connect to any endpoint")

    monkeypatch.setattr(socket.socket, "connect", deny_connection)
    monkeypatch.setattr(socket.socket, "connect_ex", deny_connection)
    return tmp_path


def test_named_custom_runtime_agent_and_stream_timeouts(configured_home):
    from hermes_cli.runtime_provider import resolve_runtime_provider
    from run_agent import AIAgent
    from agent.chat_completion_helpers import _StreamingCall

    requested = "custom:local-timeout-test"
    runtime = resolve_runtime_provider(requested=requested, target_model="test-model")
    assert runtime["provider"] == "custom"
    assert runtime["base_url"].rstrip("/") == "http://127.0.0.1:1235/v1"
    agent = AIAgent(
        model="test-model", provider=runtime["provider"], requested_provider=requested,
        api_key=runtime["api_key"], base_url=runtime["base_url"], api_mode=runtime["api_mode"],
        enabled_toolsets=[], fallback_model=[], credential_pool=None,
        skip_memory=True, skip_background_review=True, skip_context_files=True,
        load_soul_identity=False, session_db=None, save_trajectories=False, quiet_mode=True,
    )
    try:
        assert agent._resolved_api_call_timeout() == 7200
        assert agent._resolved_api_call_stale_timeout_base() == (7200, False)
        timeout = agent.client.timeout
        assert (timeout.read if hasattr(timeout, "read") else timeout) == 7200
        stream = object.__new__(_StreamingCall)
        stream.agent = agent
        stream.api_kwargs = {"model": "test-model", "messages": []}
        stream._resolve_stale_timeout()
        assert stream._stream_stale_timeout == 7200
        assert stream._stream_timeouts() == (7200, 7200, 60)
    finally:
        agent.close()


def test_named_override_precedence_and_legacy_fallback(configured_home):
    from hermes_cli.timeouts import get_provider_request_timeout, get_provider_stale_timeout

    request = get_provider_request_timeout
    stale = get_provider_stale_timeout
    named = {"requested_provider": "custom:local-timeout-test"}
    assert request("custom", "special", **named) == 111
    assert stale("custom", "special", **named) == 222
    assert request("custom", "test-model", **named) == 7200
    assert request("custom", requested_provider="custom:other-local") == 80
    assert stale("custom", requested_provider="custom:other-local") is None
    assert request("custom") == 80
    assert request("absent") is None
    assert request("openrouter", **named) == 45
    assert stale("openrouter", **named) == 60
