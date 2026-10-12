"""No model requests: fake HTTP connections and local socketpair guard checks."""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import re
import socket
import sys
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

spec=importlib.util.spec_from_file_location('probe',Path(__file__).with_name('probe_qwen_long.py'))
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe)


class ProbeTests(unittest.TestCase):
    def run_fake(self,parallel=4,tokens=100000,pressure='none',mode='separate',bad_flags=None):
        waiting=threading.Event()
        payloads=[]
        connections=[]
        mem_calls=0
        class Connection:
            def __init__(self,*args,**kwargs):
                self.sock,self.peer=socket.socketpair();self.status=200;connections.append(self)
            def connect(self): pass
            def request(self,method,path,data,headers):
                body=json.loads(data);payloads.append(body)
                markers=re.findall(r'CHECKPOINT_\d_\d_[0-9a-f]+',body['messages'][0]['content'])
                event={'choices':[{'delta':{'content':' '.join(markers)},'finish_reason':'stop'}],
                       'usage':{'prompt_tokens':tokens,'completion_tokens':80}}
                self.output=io.BytesIO(b'data: '+json.dumps(event).encode()+b'\n\ndata: [DONE]\n\n')
            def getresponse(self): return self
            def readline(self,limit):
                waiting.set()
                if pressure in ('hard','swap'):
                    return self.sock.recv(1)  # No SSE arrives: only independent shutdown can release it.
                if not getattr(self,'delayed',False): self.delayed=True;time.sleep(0.7)
                return self.output.readline(limit)
            def __enter__(self): return self
            def __exit__(self,*args): pass
            def close(self): self.sock.close();self.peer.close()
        def memory():
            nonlocal mem_calls
            mem_calls+=1
            available=7 if pressure=='hard' and waiting.is_set() else 19 if pressure=='target' else 30
            swap=mem_calls*100000 if pressure=='swap' and waiting.is_set() else 0
            return {'MemAvailable':available*1024**2,'SwapFree':1000000,'pswpin':0,'pswpout':swap}
        def slots(base):
            return [{'id':i,'n_ctx':262144,'is_processing':waiting.is_set()} for i in range(4)]
        flags=({'-c':'1048576','-np':'4','--no-kv-unified':True,'--cache-type-k':'q4_0','--cache-type-v':'q4_0'}
               if mode=='separate' else
               {'-c':'524288','-np':'4','--kv-unified-per-slot':'262144','--cache-type-k':'q8_0','--cache-type-v':'q8_0'})
        if bad_flags: flags.update(bad_flags)
        with tempfile.TemporaryDirectory() as tmp:
            out=Path(tmp)/'receipt.json'
            argv=['probe','--server-pid','123','--kv-mode',mode,'--parallel',str(parallel),'--repetitions',str(tokens),
                  '--min-prompt-tokens',str(tokens),'--output',str(out),'--timeout','5',
                  '--swap-out-sustain-seconds','0.1']
            model_metadata=io.BytesIO(json.dumps({'data':[{'id':'qwen38-27b-spark'}]}).encode())
            started=time.monotonic()
            with patch.object(sys,'argv',argv),patch.object(probe,'read_memory',memory),\
                 patch.object(probe,'native_slots',slots),patch.object(probe,'runtime_flags',return_value=flags),\
                 patch.object(probe.urllib.request,'urlopen',return_value=model_metadata),\
                 patch.object(probe.http.client,'HTTPConnection',Connection),contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(SystemExit): probe.main()
            return json.loads(out.read_text()),payloads,time.monotonic()-started

    def test_four_100k_requests_keep_four_independent_262k_slots(self):
        result,payloads,_=self.run_fake()
        self.assertTrue(result['passed'])
        self.assertEqual(len(payloads),4)
        self.assertEqual(result['configured_slots'],4)
        self.assertEqual(result['requested_context'],262144)
        self.assertEqual(result['total_kv_capacity_tokens'],1048576)
        self.assertIsNone(result['shared_kv_capacity_tokens'])
        self.assertEqual(result['independent_slot_capacity_tokens'],262144)
        self.assertEqual(result['cache_k'],'q4_0')
        self.assertEqual(result['actual_aggregate_tokens'],400320)
        self.assertEqual(result['maximum_observed_busy_slots'],4)

    def test_two_240k_requests_still_verify_four_server_slots(self):
        result,payloads,_=self.run_fake(parallel=2,tokens=240000)
        self.assertTrue(result['passed'])
        self.assertEqual(result['configured_slots'],4)
        self.assertEqual(len(payloads),2)
        self.assertEqual(result['actual_aggregate_tokens'],480160)

    def test_four_240k_is_accepted_only_with_full_independent_capacity(self):
        result,payloads,_=self.run_fake(parallel=4,tokens=240000)
        self.assertTrue(result['passed'])
        self.assertEqual(len(payloads),4)
        self.assertEqual(result['actual_aggregate_tokens'],960320)
        self.assertEqual(result['kv_mode'],'separate')

    def test_unified_option_retains_two_240k_shared_pool_qualification(self):
        result,_,_=self.run_fake(parallel=2,tokens=240000,mode='unified')
        self.assertTrue(result['passed'])
        self.assertEqual(result['shared_kv_capacity_tokens'],524288)
        self.assertIsNone(result['independent_slot_capacity_tokens'])
        self.assertEqual(result['cache_v'],'q8_0')

    def test_wrong_cache_type_or_shared_override_prevents_inference(self):
        for flags in ({'--cache-type-k':'q8_0'},{'--kv-unified':True},{'--kv-unified-per-slot':'262144'}):
            with self.subTest(flags=flags):
                result,payloads,_=self.run_fake(bad_flags=flags)
                self.assertFalse(result['passed'])
                self.assertEqual(payloads,[])

    def test_hard_floor_interrupts_silent_prefill_socket(self):
        result,_,elapsed=self.run_fake(pressure='hard')
        self.assertFalse(result['passed'])
        self.assertIn('MemAvailable crossed hard abort floor',result['cancellation_reasons'])
        self.assertLess(elapsed,3)

    def test_target_is_failed_gate_without_hard_abort(self):
        result,_,_=self.run_fake(pressure='target')
        self.assertFalse(result['passed'])
        self.assertTrue(result['response_gate_passed'])
        self.assertFalse(result['memory_gate_passed'])
        self.assertEqual(result['cancellation_reasons'],[])

    def test_sustained_swap_interrupts_silent_prefill_socket(self):
        result,_,elapsed=self.run_fake(pressure='swap')
        self.assertFalse(result['passed'])
        self.assertIn('Sustained swap-out',result['cancellation_reasons'])
        self.assertLess(elapsed,3)

    def test_four_240k_shared_pool_is_rejected_before_metadata(self):
        with patch.object(sys,'argv',['probe','--server-pid','123','--kv-mode','unified','--parallel','4']),\
             patch.object(probe,'read_memory') as memory,contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as exit: probe.main()
        self.assertEqual(exit.exception.code,2)
        memory.assert_not_called()

    def test_separate_capacity_cannot_be_silently_reduced(self):
        with patch.object(sys,'argv',['probe','--server-pid','123','--kv-mode','separate','--kv-capacity-tokens','524288']),\
             patch.object(probe,'read_memory') as memory,contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as exit: probe.main()
        self.assertEqual(exit.exception.code,2)
        memory.assert_not_called()

    def test_flags_do_not_capture_credentials_or_unrelated_arguments(self):
        # Explicit join avoids Python octal-escape ambiguity around numeric values.
        command='\0'.join(['llama-server','--api-key','secret','-c','524288','--parallel=4','--kv-unified-per-slot','262144','']).encode()
        with patch.object(Path,'read_bytes',return_value=command): flags=probe.runtime_flags(123)
        self.assertEqual(flags,{'-c':'524288','--parallel':'4','--kv-unified-per-slot':'262144'})
        self.assertNotIn('secret',json.dumps(flags))


if __name__=='__main__': unittest.main()
