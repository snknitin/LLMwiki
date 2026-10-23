"""Offline invariant check for the isolated local route. No model or private config is read."""
import importlib.util
from pathlib import Path
import sys
import json
from copy import deepcopy
from unittest.mock import patch
from types import SimpleNamespace

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("board_local_agent", Path(__file__).with_name("local-agent.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
for url, model in [("http://127.0.0.1:11435/v1", "qwen3.8-27b-desktop"),
                   ("http://127.0.0.1:8000/v1", "spark-fast")]:
    config = module.profile(url, model)
    assert config["model"]["provider"] == "custom:board-local"
    assert config["model"]["default"] == model
    assert config["fallback_providers"] == []
    assert config["delegation"]["fallback_providers"] == []
    for name, route in config["auxiliary"].items():
        if name == "title_generation":
            assert route["enabled"] is False
        else:
            assert route["provider"] == "custom:board-local"
            assert (route["base_url"], route["model"]) == (url, model)
            assert route["extra_body"]["chat_template_kwargs"]["enable_thinking"] is False
    assert config["custom_providers"][0]["extra_body"]["chat_template_kwargs"]["enable_thinking"] is False
    assert module.matches_profile(json.dumps(config, indent=2), config)
    migrated = deepcopy(config)
    provider = migrated.pop("custom_providers")[0]
    migrated["providers"] = {"board-local": {"api": url, "name": "board-local", "api_key": "local-only",
                                             "default_model": model, "extra_body": provider["extra_body"]}}
    migrated["_config_version"] = 51
    assert module.matches_profile(json.dumps(migrated), config)
    for mutate in (
        lambda c: c["model"].update(base_url="https://cloud.invalid/v1"),
        lambda c: c.update(fallback_providers=[{"provider": "anthropic"}]),
        lambda c: c["auxiliary"]["vision"].update(model="cloud-model"),
        lambda c: c["providers"]["board-local"].update(api="https://cloud.invalid/v1"),
        lambda c: c.update(plugins={"cloud": True}),
    ):
        changed = deepcopy(migrated); mutate(changed)
        assert not module.matches_profile(json.dumps(changed), config)
print("LOCAL ROUTE INVARIANTS OK: main, auxiliary and delegation pinned; thinking off; no cloud fallback")
for diff, wanted in (
    ("+### QA RESULT: findings=4\n", "QA RESULT: findings=4"),
    ("+QA RESULT: pass\n", "QA RESULT: pass"),
    (" QA RESULT: pass\n- QA RESULT: findings=2\n", None),
    ("+The build appears to pass\n", None),
):
    with patch.object(module.subprocess, "run", return_value=SimpleNamespace(stdout=diff)):
        assert module.committed_qa_result("fixture", "before") == wanted
print("COMMITTED QA VERDICT OK: new report verdict only; no inferred or stale pass")
