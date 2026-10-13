"""Bounded local allocation trace; no inference, routing changes or downloads."""
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import time
import urllib.request
from run_native_qwen import command

root = Path(__file__).resolve().parent
config = json.loads((root / 'native-config.json').read_text())
if socket.gethostname().split('.')[0] != 'spark-07a8':
    raise SystemExit('FirstSpark only')
with socket.socket() as s:
    if s.connect_ex(('127.0.0.1',1236)) == 0:
        raise SystemExit('Refusing an occupied worker port')
def available():
    return next(int(x.split()[1])/1024**2 for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:'))
if available()<52:
    raise SystemExit('Insufficient pre-load memory')
args=command(config)
args[args.index('--log-verbosity')+1]='5'
directory=Path('/home/snknitin/runs/qwen38-native') / ('allocation-trace-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()))
directory.mkdir()
minimum=available()
started=time.monotonic()
ready=False
with (directory/'native.log').open('w') as log:
    worker=subprocess.Popen(args,stdout=log,stderr=subprocess.STDOUT,env={**os.environ,'GGML_SCHED_DEBUG':'2'},start_new_session=True)
    try:
        while time.monotonic()-started<90:
            minimum=min(minimum,available())
            if minimum<8:raise RuntimeError('Emergency memory floor')
            if worker.poll() is not None:raise RuntimeError('Worker exited')
            try:
                with urllib.request.urlopen('http://127.0.0.1:1236/health',timeout=1) as r:
                    ready=r.status==200
                if ready:break
            except Exception:pass
            time.sleep(.5)
    finally:
        try:os.killpg(worker.pid,signal.SIGINT)
        except ProcessLookupError:pass
        try:worker.wait(timeout=15)
        except subprocess.TimeoutExpired:
            os.killpg(worker.pid,signal.SIGKILL);worker.wait(timeout=5)
        result={'ready':ready,'minimum_available_gib':minimum,'seconds':time.monotonic()-started,'directory':str(directory),'config':config}
        (directory/'receipt.json').write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(result),flush=True)
