---
title: "cuTile is a new DSL in Python"
saved: "April 17, 2025 11:00 PM"
date: "2025-04-17"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7308290939939172354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7308290939939172354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7308290939939172354"
notion_tags: "MLE"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, mle]
---

# cuTile is a new DSL in Python

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7308290939939172354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7308290939939172354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 17, 2025 11:00 PM · tags: MLE

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7308290939939172354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7308290939939172354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Yesterday we announced the largest addition to the CUDA programming model since its introduction back in 2007 in the form of cuTile and Tile IR.

cuTile is a new DSL in Python for writing programs that target our foundational programming model extension: Tile IR. Tile IR is an effort I have had the pleasure to join last year & collaborate with dozens of folks on. Tile IR extends the lowest level of the stacks to natively support users programming over tiles directly.

You might ask what is is programming with tiles?

GPUs have been built around a SIMT programming model where large data parallel operations are broken up into tiny pieces each carried out by threads either executing in lock-step or as in the last few years using more and more advanced cooperative computations.

In the last two decades there has been significant innovation on top of this powerful core primitive programming model, both in software and hardware but they require increasing sophistication from programmers and deep understanding of hardware details. 

There has been much experimentation and evolution in the DSL and compiler space both inside and outside of NVIDIA including the work we did in Apache TVM and at OctoAI.

Tile IR makes a flexible abstraction for dense linear algebra first class in the CUDA platform where users can simply split up their data and let a compiler figure out the low level thread and memory mappings. 

We believe elevating the programming abstraction will continue to allow more developers to access accelerated computing directly with the performance it used to take experts to achieve.

Check out Stephen Jones talk for more details: 
https://lnkd.in/gWabUehG

Stay tuned for further updates later this calendar year!

#GTC25 #gtc #gtc2025 #tileir #cutile #nvidia #nvidiagtc
