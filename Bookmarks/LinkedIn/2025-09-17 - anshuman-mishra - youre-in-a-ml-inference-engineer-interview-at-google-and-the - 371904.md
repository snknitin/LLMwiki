---
title: "You're in a ML Inference engineer interview at Google, and the interviewer asks:"
author: "Anshuman Mishra"
author_url: "https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs"
headline: "ML @ Zomato"
date: "2025-09-17"
posted_relative: "11mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7374072530405371904/"
activity_id: "7374072530405371904"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, career, ml, prompting]
---

# You're in a ML Inference engineer interview at Google, and the interviewer asks:

> **Source:** [Anshuman Mishra](https://www.linkedin.com/in/ACoAAC2-APcBUA8wEb4O_Qzw4FB95OyQg4qL4zs) · ML @ Zomato · 11mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7374072530405371904/)

## Post

You're in a ML Inference engineer interview at Google, and the interviewer asks: 

"What's the real bottleneck in LLM serving throughput? How can PagedAttention help?" 

Here's how you can answer:

A. Traditional LLM serving hits a memory wall fast. The problem isn't compute - it's how we manage the KV cache. 

65% model weights
30% KV cache
5% activations. 

When KV cache is managed poorly, you're wasting 60-80% of your GPU memory.

B. The PagedAttention Breakthrough: 

vLLM's PagedAttention solves this by borrowing from operating systems. 
Just like OS uses virtual memory with paging, PagedAttention splits KV cache into blocks that don't need to be contiguous. 
Memory fragmentation drops to near zero

C. How PagedAttention Works? 

Instead of pre-allocating huge contiguous chunks, you divide KV cache into fixed-size blocks (like pages in virtual memory). 

Attention computation becomes block-wise: 
Query × Key blocks → Attention scores → Weighted Value blocks.

D. The magic is in the block table mapping. 

Logical KV blocks map to physical GPU blocks dynamically. 
Need more tokens? Allocate one more block. 
Request finished? Free all blocks instantly. 

No more internal fragmentation from over-provisioning.

E. Today's serving systems waste memory in three ways 

1) Reserved slots for future tokens 
2) Internal fragmentation (allocate 2048, use 200) 
3) External fragmentation from buddy allocators 

Only 20-38% of KV memory stores actual token states!

F. The performance gains are substantial 

2-4× throughput improvement over state-of-the-art systems like FasterTransformer and Orca. 
The improvement is more pronounced with longer sequences and complex decoding algorithms like beam search.

G. Memory sharing becomes trivial with PagedAttention. 

Parallel sampling? Share prompt blocks via copy-on-write. 
Beam search? Share common prefixes naturally. 
Shared system prompts? Cache them once, reference everywhere.

H. The implementation details matter: 

Custom CUDA kernels for block-wise attention, fused reshape and block write operations, GPU warp-level block reading. 

The 20-26% kernel overhead is worth it for the massive memory savings enabling larger batches.

I. Block size is critical. 

Too small = poor GPU utilization. 
Too large = internal fragmentation returns. 

The sweet spot is typically 16 tokens per block, balancing parallelism with memory efficiency across different workload patterns.

J. The preemption story is elegant. 

When GPU memory is full, vLLM can swap entire sequences to CPU memory or recompute them later. 

All-or-nothing eviction policy exploits the fact that all KV blocks of a sequence are needed together.

That's it for today folks! 

This thread is inspired by the brilliant PagedAttention paper.

#machinelearning #datascience #inference vLLM

