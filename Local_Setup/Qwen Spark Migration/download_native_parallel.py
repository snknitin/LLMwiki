#!/usr/bin/env python3
"""Pinned Qwen downloads: bounded HTTP ranges, durable resume, verified publication.

Stop the old curl/HF downloader FIRST. --seed-http-partial copies full chunks only
when creating a new range manifest; the old file is retained. No model is loaded.
--probe-only measures 16 MiB, without touching model files. --self-test is local.
"""
import argparse
import concurrent.futures
import hashlib
import json
import math
import os
from pathlib import Path
import re
import signal
import threading
import time
import urllib.error
import urllib.request

ROOT=Path('/home/snknitin/ai/stores/models/unsloth-Qwen3.8-27B-UD-Q5_K_XL')
REPO='unsloth/Qwen3.8-27B-GGUF'
REV='4ca720788d1e01f1bff70c033e0d0028fd02e502'
FILES=[('Qwen3.8-27B-UD-Q5_K_XL.gguf',20876938144,'8601193d3d5760c37fb8ce1b43afebc69df5fb24e1fbc5a547c32e2200305276')]
CHUNK=32*1024**2


class TransferError(RuntimeError): pass
class Canceled(TransferError): pass


def digest(path):
    h=hashlib.sha256()
    with path.open('rb') as source:
        for block in iter(lambda:source.read(16*1024**2),b''): h.update(block)
    return h.hexdigest()


def atomic_json(path,value):
    temp=path.with_name(path.name+'.tmp')
    with temp.open('w',encoding='utf8') as out:
        json.dump(value,out,indent=2);out.write('\n');out.flush();os.fsync(out.fileno())
    os.replace(temp,path)
    if hasattr(os,'O_DIRECTORY'):
        fd=os.open(path.parent,os.O_RDONLY|os.O_DIRECTORY)
        try: os.fsync(fd)
        finally: os.close(fd)


def fetch_range(url,start,end,size,stop,timeout=20,retries=3):
    """No headers, signed redirect URLs, response bodies or exception URLs are logged."""
    for attempt in range(retries):
        if stop.is_set(): raise Canceled('Transfer canceled; complete chunks retained')
        try:
            request=urllib.request.Request(url,headers={'Range':f'bytes={start}-{end}',
                'Accept-Encoding':'identity','User-Agent':'QwenPinnedRangeDownloader/1.0'})
            with urllib.request.urlopen(request,timeout=timeout) as response:
                if response.status!=206: raise TransferError('Server ignored the requested range (expected HTTP 206)')
                expected=f'bytes {start}-{end}/{size}'
                if response.headers.get('Content-Range')!=expected:
                    raise TransferError('Content-Range does not match pinned size and requested offsets')
                if response.headers.get('Content-Encoding','identity').lower() not in ('','identity'):
                    raise TransferError('Compressed range transfer is not accepted')
                if response.headers.get('Content-Length') not in (None,str(end-start+1)):
                    raise TransferError('Range Content-Length mismatch')
                body=bytearray()
                while len(body)<end-start+1:
                    if stop.is_set(): raise Canceled('Transfer canceled; complete chunks retained')
                    part=response.read(min(256*1024,end-start+1-len(body)))
                    if not part: raise OSError('Truncated range')
                    body.extend(part)
                if response.read(1): raise TransferError('Range body exceeds requested length')
                return body
        except (Canceled,TransferError): raise
        except (OSError,urllib.error.URLError):
            if attempt+1==retries: raise TransferError('Range transfer failed after bounded retries') from None
            if stop.wait(min(2**attempt,4)): raise Canceled('Transfer canceled; complete chunks retained')


def write_at(fd,data,offset,lock):
    view=memoryview(data)
    if hasattr(os,'pwrite'):
        while view:
            written=os.pwrite(fd,view,offset)
            if written<=0: raise TransferError('Unable to write range')
            offset+=written;view=view[written:]
    else:  # The production host uses pwrite; this allows Windows-only mock tests.
        with lock:
            os.lseek(fd,offset,os.SEEK_SET)
            while view:
                written=os.write(fd,view)
                if written<=0: raise TransferError('Unable to write range')
                view=view[written:]


def download_file(root,spec,stop,workers=8,chunk=CHUNK,seed=False,url=None,progress=True):
    name,size,sha=spec
    root=root.resolve();dest=(root/name).resolve()
    if not dest.is_relative_to(root): raise TransferError('Destination escapes model directory')
    dest.parent.mkdir(parents=True,exist_ok=True)
    if dest.exists():
        if dest.stat().st_size!=size or digest(dest)!=sha:
            raise TransferError('Existing final file fails pinned verification; retained without overwrite')
        return sha
    part=dest.with_name(dest.name+'.ranges-partial')
    manifest=dest.with_name(dest.name+'.ranges.json')
    identity={'version':1,'repo':REPO,'revision':REV,'name':name,'size':size,'sha256':sha,'chunk_bytes':chunk}
    count=math.ceil(size/chunk)
    lock=threading.Lock()
    url=url or f'https://huggingface.co/{REPO}/resolve/{REV}/{name}?download=true'
    fresh=not manifest.exists()
    if not fresh:
        state=json.loads(manifest.read_text(encoding='utf8'))
        if state.get('identity')!=identity or not isinstance(state.get('complete'),dict):
            raise TransferError('Resume manifest identity mismatch; existing files retained')
        if not part.exists() or part.stat().st_size!=size:
            raise TransferError('Resume partial missing or wrong size; existing files retained')
    else:
        if part.exists(): raise TransferError('Untracked ranges-partial exists; inspect it before creating a new manifest')
        state={'identity':identity,'complete':{},'seed_source':None,'seed_bytes':0}
    fd=os.open(part,os.O_RDWR|getattr(os,'O_BINARY',0)|(os.O_CREAT|os.O_EXCL if fresh else 0),0o600)
    try:
        if fresh:
            os.ftruncate(fd,size)  # Sparse on the Linux target; does not claim downloaded bytes.
            os.fsync(fd)
            atomic_json(manifest,state)
            old=dest.with_name(dest.name+'.http-partial')
            if seed and old.exists():
                before=old.stat()
                if before.st_size>size: raise TransferError('HTTP seed exceeds pinned file size')
                seed_chunks=before.st_size//chunk
                if before.st_size==size: seed_chunks=count
                with old.open('rb') as source:
                    for index in range(seed_chunks):
                        if stop.is_set(): raise Canceled('Seed interrupted; completed chunks retained')
                        data=source.read(min(chunk,size-index*chunk))
                        if len(data)!=min(chunk,size-index*chunk): raise TransferError('HTTP seed changed during copy')
                        write_at(fd,data,index*chunk,lock)
                        os.fsync(fd)
                        state['complete'][str(index)]=hashlib.sha256(data).hexdigest()
                        state['seed_source']=old.name;state['seed_bytes']+=len(data)
                        atomic_json(manifest,state)
                after=old.stat()
                if (before.st_size,before.st_mtime_ns)!=(after.st_size,after.st_mtime_ns):
                    raise TransferError('HTTP seed was modified; stop the other downloader before resuming')
        # Re-read completed chunks rather than trusting stale/corrupt manifest claims.
        with part.open('rb') as source:
            for key,expected in list(state['complete'].items()):
                if not key.isdigit() or not 0<=int(key)<count or not re.fullmatch('[0-9a-f]{64}',expected):
                    raise TransferError('Invalid completed-chunk manifest entry')
                index=int(key);source.seek(index*chunk);data=source.read(min(chunk,size-index*chunk))
                if hashlib.sha256(data).hexdigest()!=expected: del state['complete'][key]
        atomic_json(manifest,state)
        def transfer(index):
            start=index*chunk;end=min(size,start+chunk)-1
            data=fetch_range(url,start,end,size,stop)
            if stop.is_set(): raise Canceled('Transfer canceled before committing chunk')
            write_at(fd,data,start,lock)
            with lock:
                os.fsync(fd)  # Durable bytes before durable manifest completion.
                state['complete'][str(index)]=hashlib.sha256(data).hexdigest()
                atomic_json(manifest,state)
            return len(data)
        missing=[i for i in range(count) if str(i) not in state['complete']]
        started=time.monotonic();downloaded=0;last=started
        with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
            futures=[pool.submit(transfer,i) for i in missing]
            try:
                for future in concurrent.futures.as_completed(futures):
                    downloaded+=future.result()
                    now=time.monotonic()
                    if progress and now-last>=10:
                        with lock: completed=list(state['complete'])
                        done=sum(min(chunk,size-int(i)*chunk) for i in completed)
                        print(f'{name}: {done/size:.1%}; {downloaded/1024**2/max(now-started,.001):.2f} MiB/s; chunks {len(completed)}/{count}',flush=True)
                        last=now
            except BaseException:
                stop.set()
                for future in futures: future.cancel()
                raise
        if stop.is_set(): raise Canceled('Transfer canceled; completed chunks retained')
        if len(state['complete'])!=count: raise TransferError('Not all chunks completed')
        os.fsync(fd)
    finally: os.close(fd)
    if part.stat().st_size!=size or digest(part)!=sha:
        raise TransferError('Whole-file SHA256 mismatch; partial and manifest retained, final file not published')
    if stop.is_set(): raise Canceled('Canceled after verification; partial retained')
    if dest.exists(): raise TransferError('Final destination appeared during transfer; refusing overwrite')
    os.replace(part,dest)
    state['verified_sha256']=sha;state['published']=True
    atomic_json(manifest,state)
    return sha


def probe_ranges(stop):
    name,size,_=FILES[0]
    url=f'https://huggingface.co/{REPO}/resolve/{REV}/{name}?download=true'
    head={'available':False}
    try:
        with urllib.request.urlopen(urllib.request.Request(url,method='HEAD',headers={'Accept-Encoding':'identity'}),timeout=20) as response:
            head={'available':True,'status':response.status,'content_length':response.headers.get('Content-Length'),
                  'accept_ranges':response.headers.get('Accept-Ranges')}
            if head['content_length'] is not None and int(head['content_length'])!=size:
                raise TransferError('HEAD size differs from pinned artifact')
    except (OSError,urllib.error.URLError): pass
    started=time.monotonic();length=2*1024**2
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        values=list(pool.map(lambda i:len(fetch_range(url,i*CHUNK,i*CHUNK+length-1,size,stop)),range(8)))
    elapsed=time.monotonic()-started
    print(json.dumps({'head':head,'validated_http_206_ranges':len(values),'bytes':sum(values),
                      'seconds':round(elapsed,3),'aggregate_mib_per_second':round(sum(values)/1024**2/elapsed,3)},indent=2))


def self_test():
    import http.server
    import tempfile
    import unittest
    from unittest.mock import patch
    data=bytes(range(251))*1000
    control={'ignore':False,'bad_range':False,'seen':[]}
    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self,*args): pass
        def do_GET(self):
            if control['ignore']:
                self.send_response(200);self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data);return
            start,end=map(int,re.fullmatch(r'bytes=(\d+)-(\d+)',self.headers['Range']).groups())
            control['seen'].append((start,end));body=data[start:end+1]
            self.send_response(206);self.send_header('Content-Length',str(len(body)))
            self.send_header('Content-Range',f'bytes {start}-{end}/{len(data)+(1 if control["bad_range"] else 0)}')
            self.end_headers();self.wfile.write(body)
    server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
    thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
    url=f'http://127.0.0.1:{server.server_port}/test'
    spec=('test.gguf',len(data),hashlib.sha256(data).hexdigest())
    class Tests(unittest.TestCase):
        def setUp(self): control.update(ignore=False,bad_range=False,seen=[])
        def test_ranges_and_verified_rename(self):
            with tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp);download_file(root,spec,threading.Event(),4,8192,url=url,progress=False)
                self.assertEqual((root/'test.gguf').read_bytes(),data)
                self.assertFalse((root/'test.gguf.ranges-partial').exists())
        def test_ignored_range_200_rejected(self):
            control['ignore']=True
            with self.assertRaises(TransferError): fetch_range(url,0,100,len(data),threading.Event())
        def test_wrong_content_range_rejected(self):
            control['bad_range']=True
            with self.assertRaises(TransferError): fetch_range(url,0,100,len(data),threading.Event())
        def test_hash_mismatch_never_publishes(self):
            with tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp)
                with self.assertRaises(TransferError): download_file(root,('test.gguf',len(data),'0'*64),threading.Event(),4,8192,url=url,progress=False)
                self.assertFalse((root/'test.gguf').exists());self.assertTrue((root/'test.gguf.ranges-partial').exists())
        def test_interrupt_resume_and_seed_only_once(self):
            with tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp);old=root/'test.gguf.http-partial';old.write_bytes(data[:20000])
                real=fetch_range
                def interrupted(*args,**kwargs):
                    if args[1]>=32768: raise Canceled('Simulated interrupt')
                    return real(*args,**kwargs)
                with patch.dict(download_file.__globals__,fetch_range=interrupted):
                    with self.assertRaises(Canceled): download_file(root,spec,threading.Event(),1,8192,True,url,False)
                state=json.loads((root/'test.gguf.ranges.json').read_text())
                self.assertEqual(state['seed_bytes'],16384)
                self.assertGreaterEqual(len(state['complete']),3)
                old.write_bytes(b'changed seed must not be used on resume')
                control['seen']=[]
                download_file(root,spec,threading.Event(),4,8192,True,url,False)
                self.assertEqual((root/'test.gguf').read_bytes(),data)
                self.assertTrue(old.exists())
                self.assertTrue(all(start>=24576 for start,end in control['seen']))
        def test_corrupt_completed_chunk_is_repaired(self):
            with tempfile.TemporaryDirectory() as tmp:
                root=Path(tmp);stop=threading.Event();old=root/'test.gguf.http-partial';old.write_bytes(data[:16384])
                with patch.dict(download_file.__globals__,fetch_range=lambda *a,**k:(_ for _ in ()).throw(Canceled('stop'))):
                    with self.assertRaises(Canceled): download_file(root,spec,stop,1,8192,True,url,False)
                with (root/'test.gguf.ranges-partial').open('r+b') as out: out.write(b'bad')
                control['seen']=[];download_file(root,spec,threading.Event(),4,8192,True,url,False)
                self.assertTrue(any(start==0 for start,end in control['seen']))
                self.assertFalse(any(start==8192 for start,end in control['seen']))
    try: return unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(Tests)).wasSuccessful()
    finally: server.shutdown();server.server_close();thread.join(timeout=2)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--workers',type=int,default=8,choices=range(1,17))
    parser.add_argument('--seed-http-partial',action='store_true')
    parser.add_argument('--probe-only',action='store_true')
    parser.add_argument('--self-test',action='store_true')
    args=parser.parse_args()
    if args.self_test: return 0 if self_test() else 1
    stop=threading.Event()
    for signum in (signal.SIGINT,signal.SIGTERM): signal.signal(signum,lambda *_:stop.set())
    if args.probe_only:
        probe_ranges(stop);return 0
    import fcntl  # Linux production host; advisory lock releases automatically on exit/crash.
    args.root.mkdir(parents=True,exist_ok=True)
    with (args.root/'.parallel-download.lock').open('a') as lease:
        try: fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: raise TransferError('Another range downloader already owns this directory') from None
        verified={}
        for spec in FILES:
            print(f'Pinned download: {spec[0]} ({spec[1]} bytes); workers={args.workers}',flush=True)
            verified[spec[0]]=download_file(args.root,spec,stop,args.workers,seed=args.seed_http_partial)
            print(f'Verified {spec[0]}: {spec[2]}',flush=True)
        atomic_json(args.root/'verified-sha256.json',verified)
    print('All pinned files verified. No model load or service change performed.',flush=True)
    return 0


if __name__=='__main__':
    try: raise SystemExit(main())
    except Canceled: print('Canceled. Completed range chunks and original partials retained.',flush=True);raise SystemExit(130)
    except Exception as error:
        # Avoid leaking urllib's final signed redirect URL or authentication details.
        print(f'STOP: {str(error) if isinstance(error,TransferError) else type(error).__name__}; artifacts retained.',flush=True)
        raise SystemExit(1)
