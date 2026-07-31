---
title: "Accelerating Pandas library speed by upto 150x with Nvidia's RAPIDS cuDF library"
saved: "April 19, 2025 2:51 PM"
date: "2025-04-19"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7196649723104030722/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7196649723104030722%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7196649723104030722"
notion_tags: "GPU"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, gpu]
---

# Accelerating Pandas library speed by upto 150x with Nvidia's RAPIDS cuDF library

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7196649723104030722/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7196649723104030722%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 19, 2025 2:51 PM · tags: GPU

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7196649723104030722/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7196649723104030722%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Accelerating Pandas library speed by upto 150x with Nvidia's RAPIDS cuDF library

RAPIDS cuDF is a GPU DataFrame library that accelerates the data processing tool pandas with zero code changes. It recently has also been integrated into Google Colab.

𝗛𝗼𝘄 𝗰𝘂𝗗𝗙 𝗮𝗰𝗰𝗲𝗹𝗲𝗿𝗮𝘁𝗲𝘀 𝗣𝗮𝗻𝗱𝗮𝘀
- When cuDF accelerates pandas, operations will run on the GPU if possible, and on the CPU (using pandas) ,otherwise, cuDF synchronizes between the GPU and CPU under the hood as needed. 
- This enables a unified CPU/GPU experience bringing best-in-class performance to your pandas workflows. 

𝗨𝘀𝗮𝗴𝗲
load the cudf.pandas extension in your notebook with the code snippet mentioned below :
%load_ext cudf.pandas
import pandas as pd

𝗕𝗲𝗻𝗰𝗵𝗺𝗮𝗿𝗸 𝘂𝘀𝗲𝗱 𝗳𝗼𝗿 𝗲𝘃𝗮𝗹𝘂𝗮𝘁𝗶𝗼𝗻
-  DuckDB benchmark used, which is as setup that compares popular CPU-based DataFrame and SQL engines on a series of common analytics tasks, such as joining data together or computing statistical measures per group.

𝗕𝗲𝗻𝗰𝗵𝗺𝗮𝗿𝗸𝗶𝗻𝗴 𝗣𝗲𝗿𝗳𝗼𝗿𝗺𝗮𝗻𝗰𝗲
Using DuckDB Database-like Ops Benchmark at 5 GB scale
- it provides 150x faster processing times on standard pandas, with NVIDIA Grace Hopper GPU used.
- it provides 50x speedups over standard pandas , when using NVIDIA L4 Tensor Core GPUs( also available on Google Colab)

𝗧𝘂𝘁𝗼𝗿𝗶𝗮𝗹 𝗻𝗼𝘁𝗲𝗯𝗼𝗼𝗸:
- https://lnkd.in/eZA5z2HG

𝗕𝗹𝗼𝗴𝘀 𝗿𝗲𝗳𝗲𝗿𝗲𝗻𝗰𝗲𝗱 :
- https://lnkd.in/eJD67qqy
- https://lnkd.in/ecTnWT7p
