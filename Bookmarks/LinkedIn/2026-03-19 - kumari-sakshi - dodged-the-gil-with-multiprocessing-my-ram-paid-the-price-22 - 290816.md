---
title: "Dodged the GIL with multiprocessing. My RAM paid the price: 22.4 GB. Free-threading changed the trad..."
author: "Kumari Sakshi"
author_url: "https://www.linkedin.com/in/ACoAADB0ZRgBfbPFY2ligfnzcfVYAP2ol0Vc8HQ"
headline: "Applied Scientist @ Oracle | IIT Bombay 2023 | Deutsche India | Building AI for Healthcare"
date: "2026-03-19"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7440486682560290816/"
activity_id: "7440486682560290816"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, python, ml]
---

# Dodged the GIL with multiprocessing. My RAM paid the price: 22.4 GB. Free-threading changed the trad...

> **Source:** [Kumari Sakshi](https://www.linkedin.com/in/ACoAADB0ZRgBfbPFY2ligfnzcfVYAP2ol0Vc8HQ) · Applied Scientist @ Oracle | IIT Bombay 2023 | Deutsche India | Building AI for Healthcare · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7440486682560290816/)

## Post

Dodged the GIL with multiprocessing. My RAM paid the price: 22.4 GB. Free-threading changed the tradeoff entirely. 💥

The GIL has been debated for years. I finally tested what removing it actually changes in practice.

I hit a bottleneck chunking large unstructured text for a local multi-agent workflow on an M4 Pro. Multiprocessing bypassed the GIL but created a bigger problem.

😐 Python 3.13 (multiprocessing, default spawn): Fresh interpreter per worker, so large objects get serialized across processes. RAM peaked at 22.4 GB, triggering memory pressure, compression, and SSD paging. Runtime: 14m 30s. The slowdown was not compute. It was data movement.
I switched to the free-threaded CPython build (PEP 703, tested on 3.14t) using a ThreadPoolExecutor.

🫡 Free-threaded Python: Shared heap, no serialization overhead. RAM peaked at ~2.9 GB. Runtime dropped to 3m 15s. Roughly 4 to 5 times faster, though not linear - memory bandwidth and allocator contention start to show up.

Not a controlled benchmark. Just one real workload. Results will depend heavily on data size and how CPU-bound things actually are.
What changed is the tradeoff. Before, scaling meant more processes and paying in memory. Now that cost moves somewhere else - concurrency complexity.

Race conditions, lock contention, memory bugs that are harder to reproduce. The kind of issues that were easier to ignore when the GIL was serializing execution for you. Single-thread performance can also dip, and a lot of the scientific Python stack is still catching up.

4 to 5 times speedup at roughly one-eighth of the memory. For a local workflow, that changes what is even practical to run on a single machine.
If you are working in ML or data engineering - would you test this in staging today, or is it still a year out?

#Python #Python314 #AgentOps #Concurrency #Multiprocessing #MachineLearning #DataEngineering #GIL #OpenSource

## Images

![](https://media.licdn.com/dms/image/v2/D4D22AQGhNC9_MtOyiw/feedshare-shrink_480/B4DZ0HrNZ8IcAo-/0/1773950261189?e=1787184000&v=beta&t=U-GIqs38AWIsg1db5__enZT-7YjUvohI0MdMMbyMjAQ)

