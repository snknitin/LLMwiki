"""One, two or four synchronized requests against an ALREADY RESIDENT native model.

No loading or config edits. Run only in an explicitly reserved qualification
window. Synthetic filler measures long input/KV handling, not real task quality.
Actual server usage must meet --min-prompt-tokens; repetitions are not a tokenizer.
Run on the model host. A 20 GiB pass target is separate from the 8 GiB immediate
abort floor. Sockets are interrupted independently of SSE during silent prefill.
Default: four independent 262K slots with Q4 KV; model weights remain Q5 XL.
The optional unified mode retains explicit shared-pool capacity accounting.
"""
import argparse
import concurrent.futures
import datetime
import http.client
import json
import os
from pathlib import Path
import socket
import threading
import time
import urllib.request
import urllib.parse
import uuid


def read_memory():
    mem = {line.split(':')[0]: int(line.split()[1]) for line in
           Path('/proc/meminfo').read_text().splitlines()
           if line.startswith(('MemAvailable:', 'SwapFree:'))}
    vm = {line.split()[0]: int(line.split()[1]) for line in
          Path('/proc/vmstat').read_text().splitlines()
          if line.startswith(('pswpin ', 'pswpout '))}
    if set(mem) != {'MemAvailable', 'SwapFree'} or set(vm) != {'pswpin', 'pswpout'}:
        raise ValueError('Incomplete memory telemetry')
    return {**mem, **vm}


def close_sockets(sockets):
    for sock in sockets:
        try: sock.shutdown(socket.SHUT_RDWR)
        except OSError: pass
        try: sock.close()
        except OSError: pass


def native_slots(base):
    with urllib.request.urlopen(base.rsplit('/v1',1)[0]+'/slots',timeout=2) as response:
        raw=response.read(1_000_001)
    if len(raw)>1_000_000: raise ValueError('Slot metadata exceeded bound')
    rows=json.loads(raw)
    if not isinstance(rows,list): raise ValueError('Native slot metadata is not a list')
    return [{k:r[k] for k in ('id','n_ctx','is_processing','n_prompt_tokens') if k in r} for r in rows]


def runtime_flags(pid):
    values=Path(f'/proc/{pid}/cmdline').read_bytes().decode().split('\0')
    allowed={'-c','--ctx-size','-np','--parallel','--kv-unified-per-slot','-ctk','--cache-type-k',
             '-ctv','--cache-type-v','-fa','--flash-attn','--spec-type','--spec-draft-n-max',
             '-b','--batch-size','-ub','--ubatch-size'}
    flags={}
    for i,value in enumerate(values):
        name,sep,inline=value.partition('=')
        if name in allowed: flags[name]=inline if sep else values[i+1]
        elif value in ('--kv-unified','--no-kv-unified','--no-context-shift'): flags[value]=True
    return flags


def make_prompt(repetitions, index):
    nonce = uuid.uuid4().hex[:12]
    markers = [f'CHECKPOINT_{index}_{position}_{nonce}' for position in range(4)]
    segment = ' x' * (repetitions // 4)
    prompt = ('Read the entire input. Ignore filler x tokens. At the end, return the four '
              'CHECKPOINT identifiers in their original order, verbatim, and nothing else.\n')
    for marker in markers:
        prompt += segment + '\n' + marker + '\n'
    prompt += '\nReturn the four CHECKPOINT identifiers now. Do not explain.'
    return prompt, markers


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', default='http://127.0.0.1:1236/v1')
    parser.add_argument('--model', default='qwen38-27b-spark')
    parser.add_argument('--context', type=int, default=262144)
    parser.add_argument('--repetitions', type=int, default=240000)
    parser.add_argument('--min-prompt-tokens', type=int, default=240000)
    parser.add_argument('--parallel', type=int, choices=(1, 2, 4), default=4)
    parser.add_argument('--max-tokens', type=int, default=2048)
    parser.add_argument('--timeout', type=int, default=1800)
    parser.add_argument('--min-memory-gib', type=float, default=20.0)
    parser.add_argument('--abort-memory-gib', type=float, default=8.0)
    parser.add_argument('--swap-out-mib-per-second', type=float, default=8.0)
    parser.add_argument('--swap-out-sustain-seconds', type=float, default=5.0)
    parser.add_argument('--kv-mode', choices=('separate','unified'), default='separate')
    parser.add_argument('--kv-capacity-tokens', type=int, help='Default: per-session context times slots for separate mode; 524288 for unified')
    parser.add_argument('--cache-k', help='Expected launch cache type; separate default q4_0, unified default q8_0')
    parser.add_argument('--cache-v', help='Expected launch cache type; separate default q4_0, unified default q8_0')
    parser.add_argument('--server-slots', type=int, default=4)
    parser.add_argument('--server-pid', type=int, required=True, help='Read-only launch-flag verification on the model host')
    parser.add_argument('--output', default='qwen-long-probe.json')
    args = parser.parse_args()
    if args.kv_capacity_tokens is None:
        args.kv_capacity_tokens=args.context*args.server_slots if args.kv_mode=='separate' else 524288
    args.cache_k=args.cache_k or ('q4_0' if args.kv_mode=='separate' else 'q8_0')
    args.cache_v=args.cache_v or ('q4_0' if args.kv_mode=='separate' else 'q8_0')
    if not 1 <= args.repetitions <= 1000000 or not 1 <= args.min_prompt_tokens < args.context - args.max_tokens:
        parser.error('Bound repetitions and leave output headroom within the requested context')
    if not 0 < args.abort_memory_gib <= args.min_memory_gib or args.timeout < 1 or args.max_tokens < 1:
        parser.error('Require positive abort/pass thresholds, deadline and output budget')
    if args.swap_out_mib_per_second <= 0 or args.swap_out_sustain_seconds <= 0 or args.server_slots < args.parallel:
        parser.error('Invalid swap guard or configured slot count')
    if args.kv_mode=='separate' and args.kv_capacity_tokens!=args.context*args.server_slots:
        parser.error('Separate mode requires aggregate context = per-session context times server slots')
    if max(args.repetitions,args.min_prompt_tokens)+args.max_tokens+1024>args.context:
        parser.error('Input plus output/template reserve exceeds one session context')
    if args.parallel*(max(args.repetitions,args.min_prompt_tokens)+args.max_tokens+1024) > args.kv_capacity_tokens:
        parser.error('Requested inputs plus output/template reserve exceed declared total KV capacity; no inference sent')
    endpoint=urllib.parse.urlsplit(args.base.rstrip('/'))
    if endpoint.scheme not in ('http','https') or endpoint.hostname not in ('127.0.0.1','localhost','::1') or endpoint.path!='/v1' or endpoint.query or endpoint.fragment or endpoint.username:
        parser.error('Run on the model host with its loopback URL ending /v1; client-host memory is not valid evidence')
    samples, receipts = [], []
    stop = threading.Event()
    pressure = threading.Event()
    target_breached = threading.Event()
    reasons, active_sockets, slot_samples = [], set(), []
    socket_lock = threading.Lock()
    deadline = None
    flags = {}
    page_bytes = os.sysconf('SC_PAGE_SIZE') if hasattr(os,'sysconf') else 4096
    barrier = threading.Barrier(args.parallel)
    epoch = time.monotonic()

    def cancel(reason):
        with socket_lock:
            if reason not in reasons: reasons.append(reason)
            pressure.set()
            sockets=list(active_sockets)
        close_sockets(sockets)

    def monitor():
        failures, swap_since = 0, None
        while not stop.is_set():
            try:
                sample = {'elapsed': round(time.monotonic()-epoch, 3), **read_memory()}
                failures = 0
                previous=samples[-1] if samples else None
                rate=0.0
                if previous and sample['elapsed']>previous['elapsed']:
                    delta=sample['pswpout']-previous['pswpout']
                    if delta<0: cancel('Swap counter reset; telemetry is not comparable')
                    rate=max(0,delta)*page_bytes/1024**2/(sample['elapsed']-previous['elapsed'])
                sample['swap_out_mib_per_second']=round(rate,3)
                samples.append(sample)
                available=sample['MemAvailable']/1024**2
                if available<args.min_memory_gib: target_breached.set()
                if available<args.abort_memory_gib: cancel('MemAvailable crossed hard abort floor')
                if rate>=args.swap_out_mib_per_second:
                    if swap_since is None: swap_since=previous['elapsed'] if previous else sample['elapsed']
                    if sample['elapsed']-swap_since>=args.swap_out_sustain_seconds: cancel('Sustained swap-out')
                else: swap_since=None
                if deadline is not None and time.monotonic()>=deadline: cancel('Overall request deadline exceeded')
                if pressure.is_set(): return
                stop.wait(0.1 if available<args.min_memory_gib else 0.5)
            except (OSError, ValueError, KeyError):
                failures+=1
                if failures>=3: cancel('Memory telemetry unavailable'); return
                stop.wait(0.25)

    def observe_slots():
        while not stop.is_set():
            try: slot_samples.append({'elapsed':round(time.monotonic()-epoch,3),'slots':native_slots(args.base)})
            except Exception: slot_samples.append({'elapsed':round(time.monotonic()-epoch,3),'metadata_error':True})
            stop.wait(0.5)

    def request(index):
        prompt, markers = make_prompt(args.repetitions, index)
        result = {'request': index, 'passed': False, 'input_characters': len(prompt)}
        connection = sock = None
        started = None
        try:
            barrier.wait(timeout=20)
            if pressure.is_set():
                raise RuntimeError('Available memory already below safety floor')
            started = time.monotonic()
            result['started_offset_seconds'] = round(started-epoch, 3)
            payload = {'model': args.model, 'messages': [{'role': 'user', 'content': prompt}],
                       'stream': True, 'stream_options': {'include_usage': True},
                       'temperature': 0, 'max_tokens': args.max_tokens}
            output, usage, finish, first_output, first_visible, done = '', None, None, None, None, False
            cls=http.client.HTTPSConnection if endpoint.scheme=='https' else http.client.HTTPConnection
            connection=cls(endpoint.hostname,endpoint.port,timeout=min(args.timeout,10))
            connection.connect()
            sock=connection.sock
            with socket_lock: active_sockets.add(sock)
            if pressure.is_set(): close_sockets([sock]); raise RuntimeError('Qualification already canceled')
            sock.settimeout(args.timeout)
            connection.request('POST','/v1/chat/completions',json.dumps(payload).encode(),{'Content-Type':'application/json'})
            with connection.getresponse() as response:
                if response.status!=200: raise RuntimeError(f'Inference HTTP {response.status}')
                while True:
                    raw=response.readline(1_000_001)
                    if not raw: break
                    if len(raw)>1_000_000: raise ValueError('SSE line exceeds size bound')
                    elapsed = time.monotonic()-started
                    if pressure.is_set():
                        raise RuntimeError('Memory safety floor breached; stream closed')
                    if elapsed > args.timeout:
                        raise TimeoutError('Overall request budget exceeded')
                    if not raw.startswith(b'data:'):
                        continue
                    data = raw[5:].strip()
                    if data == b'[DONE]':
                        done = True
                        break
                    event = json.loads(data)
                    usage = event.get('usage') or usage
                    for choice in event.get('choices', []):
                        finish = choice.get('finish_reason') or finish
                        delta = choice.get('delta', {})
                        text = delta.get('content') or ''
                        if text or delta.get('reasoning_content') or delta.get('reasoning'):
                            if first_output is None:
                                first_output = elapsed
                        if text:
                            if first_visible is None:
                                first_visible = elapsed
                            output += text
                            if len(output)>1_000_000: raise ValueError('Visible output exceeds size bound')
            result.update(seconds=round(time.monotonic()-started, 3),
                          first_output_seconds=first_output, first_visible_seconds=first_visible,
                          usage=usage, finish_reason=finish,
                          finished_offset_seconds=round(time.monotonic()-epoch, 3))
            if not done or finish != 'stop' or not output.strip():
                raise ValueError('Missing final visible answer, stream terminator, or normal completion')
            positions = [output.find(marker) for marker in markers]
            if any(position < 0 for position in positions) or positions != sorted(positions):
                raise ValueError('Long-input checkpoint retrieval failed')
            if not usage or usage.get('prompt_tokens', 0) < args.min_prompt_tokens:
                raise ValueError('Actual prompt-token usage absent or below the required qualification target')
            if usage['prompt_tokens'] + usage.get('completion_tokens', 0) > args.context:
                raise ValueError('Reported total tokens exceed requested context; investigate runtime semantics')
            result['passed'] = True
        except Exception as error:
            result.update(error_type=type(error).__name__, error=str(error)[:240])
        finally:
            if started is not None:
                result.setdefault('seconds',round(time.monotonic()-started,3))
                result.setdefault('finished_offset_seconds',round(time.monotonic()-epoch,3))
            result['safety_cancellation_observed']=pressure.is_set()
            if sock is not None:
                with socket_lock: active_sockets.discard(sock)
            if connection is not None: connection.close()
        return result

    worker = threading.Thread(target=monitor, daemon=True)
    observer = None
    try:
        initial={'elapsed':round(time.monotonic()-epoch,3),**read_memory()}
        samples.append(initial)
        if initial['MemAvailable']/1024**2<args.min_memory_gib: target_breached.set()
        if initial['MemAvailable']/1024**2<args.abort_memory_gib: raise RuntimeError('Insufficient memory before any inference')
        flags=runtime_flags(args.server_pid)
        if int(flags.get('-c',flags.get('--ctx-size',0)))!=args.kv_capacity_tokens:
            raise ValueError('Launch flags do not match declared total KV context')
        if int(flags.get('-np',flags.get('--parallel',0)))!=args.server_slots:
            raise ValueError('Launch flags do not match declared server slot count')
        if args.kv_mode=='separate':
            if '--no-kv-unified' not in flags or '--kv-unified' in flags or '--kv-unified-per-slot' in flags:
                raise ValueError('Separate mode requires explicit --no-kv-unified and no shared-pool override')
        else:
            if int(flags.get('--kv-unified-per-slot',0))!=args.context or '--no-kv-unified' in flags:
                raise ValueError('Unified mode requires matching --kv-unified-per-slot and enabled shared KV')
        if flags.get('-ctk',flags.get('--cache-type-k'))!=args.cache_k or flags.get('-ctv',flags.get('--cache-type-v'))!=args.cache_v:
            raise ValueError('Launch cache quantization differs from requested qualification')
        slots=native_slots(args.base)
        if len(slots)!=args.server_slots or any(s.get('n_ctx')!=args.context for s in slots):
            raise ValueError('Actual native slot count/context does not match requested configuration')
        if any(s.get('is_processing') is not False for s in slots):
            raise ValueError('Native slots busy or state unknown; reserve the qualification window')
        slot_samples.append({'elapsed':round(time.monotonic()-epoch,3),'slots':slots})
        with urllib.request.urlopen(args.base.rstrip('/')+'/models', timeout=15) as response:
            models = json.load(response)
        if args.model not in {item['id'] for item in models['data']}:
            raise ValueError('Exact alias absent; no request sent')
        deadline=time.monotonic()+args.timeout
        worker.start()
        observer=threading.Thread(target=observe_slots,daemon=True);observer.start()
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as pool:
            receipts = list(pool.map(request, range(args.parallel)))
        result = {'passed': all(row['passed'] for row in receipts) and not pressure.is_set() and not target_breached.is_set(),
                  'requests': receipts}
    except Exception as error:
        result = {'passed': False, 'requests': receipts, 'error': str(error)[:240]}
    finally:
        stop.set()
        if worker.ident is not None: worker.join(timeout=2)
        if observer: observer.join(timeout=3)
    max_busy=max((sum(s.get('is_processing') is True for s in sample.get('slots',[])) for sample in slot_samples),default=0)
    actual_sum=sum((row.get('usage') or {}).get('prompt_tokens',0)+(row.get('usage') or {}).get('completion_tokens',0) for row in receipts)
    swap_delta=samples[-1]['pswpout']-samples[0]['pswpout'] if samples else None
    result['response_gate_passed']=len(receipts)==args.parallel and all(row['passed'] for row in receipts)
    result['memory_gate_passed']=bool(samples) and not pressure.is_set() and not target_breached.is_set() and swap_delta==0
    result['observed_concurrency_gate_passed']=max_busy>=args.parallel
    result['aggregate_token_gate_passed']=0<actual_sum<=args.kv_capacity_tokens
    result['passed']=all(result[k] for k in ('response_gate_passed','memory_gate_passed','observed_concurrency_gate_passed','aggregate_token_gate_passed'))
    result.update(timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  model=args.model, requested_context=args.context,
                  minimum_required_prompt_tokens_per_request=args.min_prompt_tokens,
                  parallel_requests=args.parallel, memory_floor_gib=args.min_memory_gib,
                  memory_floor_breached=target_breached.is_set(), hard_abort_memory_gib=args.abort_memory_gib,
                  cancellation_reasons=reasons, runtime_flags=flags, configured_slots=args.server_slots,
                  swap_out_guard_mib_per_second=args.swap_out_mib_per_second,
                  swap_out_guard_sustain_seconds=args.swap_out_sustain_seconds,
                  kv_mode=args.kv_mode,cache_k=args.cache_k,cache_v=args.cache_v,
                  total_kv_capacity_tokens=args.kv_capacity_tokens,
                  shared_kv_capacity_tokens=args.kv_capacity_tokens if args.kv_mode=='unified' else None,
                  independent_slot_capacity_tokens=args.context if args.kv_mode=='separate' else None,
                  actual_aggregate_tokens=actual_sum,
                  maximum_observed_busy_slots=max_busy, memory_samples=samples, slot_samples=slot_samples,
                  scope='Synthetic actual-token retrieval with observed native busy slots and explicitly verified KV mode/cache type. Does not prove research, reasoning, citation quality or thermal stability. Q4 KV is distinct from Q5 model-weight quantization. Confirm canceled slots drain in server logs.')
    if samples:
        result['minimum_mem_available_gib'] = round(min(s['MemAvailable'] for s in samples)/1024**2, 3)
        result['swap_out_pages_delta'] = samples[-1]['pswpout']-samples[0]['pswpout']
        result['swap_in_pages_delta'] = samples[-1]['pswpin']-samples[0]['pswpin']
    path = Path(args.output)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({key:value for key,value in result.items() if key not in ('memory_samples','slot_samples')}, indent=2))
    raise SystemExit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
