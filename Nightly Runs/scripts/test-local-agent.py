"""Offline invariant check for the isolated local route. No model or private config is read."""
import importlib.util
from pathlib import Path
import sys

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
print("LOCAL ROUTE INVARIANTS OK: main, auxiliary and delegation pinned; thinking off; no cloud fallback")
