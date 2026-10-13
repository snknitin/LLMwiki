"""Finite read-only thermal telemetry for the currently running qualification."""
import json
from pathlib import Path
import subprocess
import time

state_path=Path('/home/snknitin/runs/qwen38-native/installation-status.json')
state=json.loads(state_path.read_text())
directory=Path(state['evidence_directory'])
started=time.monotonic()
samples=0
maximum=None
thermal_active=0
errors=0
with (directory/'thermal-samples.jsonl').open('x') as log:
    while time.monotonic()-started<7200:
        try:
            raw=subprocess.check_output(['nvidia-smi','--query-gpu=temperature.gpu,utilization.gpu,power.draw,clocks_event_reasons.sw_thermal_slowdown,clocks_event_reasons.hw_thermal_slowdown','--format=csv,noheader,nounits'],text=True,timeout=10).strip().split(', ')
            temperature=float(raw[0])
            row={'utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'temperature_c':temperature,'utilization_percent':raw[1],'power_w':raw[2],'sw_thermal':raw[3],'hw_thermal':raw[4]}
            maximum=temperature if maximum is None else max(maximum,temperature)
            thermal_active+=int(any(x.strip()=='Active' for x in raw[3:]))
            log.write(json.dumps(row)+'\n');log.flush();samples+=1
        except Exception:
            errors+=1
        state=json.loads(state_path.read_text())
        if state.get('stage') in ('qualified_and_published','stopped_for_review'):
            break
        time.sleep(15)
result={'samples':samples,'maximum_temperature_c':maximum,'samples_with_active_thermal_slowdown':thermal_active,'sampling_errors':errors,'final_installer_stage':state.get('stage'),'scope':'15-second snapshots during this qualification only; not a 24-hour soak or proof of no unsampled throttling.'}
(directory/'thermal-summary.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result),flush=True)
