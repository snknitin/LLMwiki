---
title: "'should I learn CUDA?' is a question i, everyone and their mother is faced with today (yes, even me)..."
author: "Elliot Arledge"
username: "@elliotarledge"
date: "2025-12-20"
tweet_url: "https://x.com/elliotarledge/status/2002372651168453056"
tweet_type: "original"
likes: 430
retweets: 24
replies: 22
bookmarks: 536
views: 48223
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "llm"]
---

# "should I learn CUDA?" is a question i, everyone and their mother is faced with today (yes, even me)...

> **Source:** [@elliotarledge](https://x.com/elliotarledge) · 2025-12-20 · 👍 430 · 💬 22 · 🔖 536 · 👁 48223

> 🔗 [View tweet on X](https://x.com/elliotarledge/status/2002372651168453056)

## Tweet Content

"should I learn CUDA?" is a question i, everyone and their mother is faced with today (yes, even me). heres my most down to earth answer which considers my experience, and what it has vs has NOT brought me success in. ill also talk about where the ecosystem is going and how to play strategically around that.

i was just through the pytorch and nanoGPT phase of my journey and got pumped up when karpathy released llm.c. it looked cool (and fast) with such absurd complexity to a complete beginner (me). just wanted to understand a little bit more and quickly realized i would have to further rewire my brain (again). decided to go document my learnings on what a kernel was after prompting GPT-4 about how the whole repo was structured. ended up thinking the same thing to myself about the previous course I built about llms (published before my cuda course) which was that this stuff wasnt easy for me and wont be easy for anyone else. so i kept going, prompting my way through every detail, piece of text in the kernels i saw, looking at all the videos on explaining kernels i could find. eventually figured out the way gpu programming was done (init data on cpu and gpu, move it to gpu, define kernel params like grid/blocks/threads, launch kernel on gpu, get results, move back to cpu, print and visualize stuff).

i want to quickly remind you this is all curiousity, eventually seeing stuff isn't taught well enough, and wanting to do it myself. this was never about getting a job (even though i expected some offers to emerge as a results of making a free course on it). there are many rabbitholes to go down, and if you have the time to spare as well as curiousity and fire in you, i fully encourage you to go all in.

if you made it this far, ask yourself the following:
- am I currently in uni or college? how much do I care about grades?
- am I comfortable with one of pytorch or JAX?
- am I just in this for the money?
- am I looking to get a job somehow as quick as possible in the field?
- do I care simply about having an impact on the world potentially at a frontier lab?
- am I (be honest with yourself) just utterly lost and need something to learn?
- am I just seeing CUDA is a cool buzzword people are posting about and I want a part of it?
- am I simply curious and CANNOT help myself since this shit is so cool? (the answer is easy for you but with some nuance)

these are designed to give you some clarity if you are able to truly reflect on each of them deeply. getting back to it, in dec 2025 (or 2026 if you're reading this later), the ecosystem is evolving so rapidly that it feels like you can't keep up, even when learning at full speed. ill inform you that some concept but not ALL all important. understanding how a server/PC is built is an important skill that i think is very fun (but potentially expensive) to know better. if you stick in the software realm only, knowing what ram, vram, cpu vs gpu, and these basic terms are essential. going a level deeper, knowing what the computations look like for a neural net (CNN or transformer) is going to serve you very well and is one of the most magic parts of your learning journey. when you get to how those computations are optimized on specific hardware like a hopper or blackwell gpu, it can get a bit scary. theres a lot of material to cover, and you may not know if it will remain relevant. the most concrete example i can give is when if and when you decide to pick up cuda or gpu progrmaming, you'll likely write a kernel in a .cu file with __global__ at the start. this is not how modern kernel writing is done anymore (for the most part). all the deep learning kernels are very optimized today, and techniques like RL training LLMs to speed them up even further is an area of research that's doing well. we also have abstractions like triton, but you'll still need to know cuda moderately well to understand how to get the best use of this since its tiled gpu programming that acts as a way to simplify the workflow for someone who may have come from cuda. nvidia has cutlass, cute, cuda-tile, cute-dsl and many other open source repos coming out which simplifies the kernel writing process further (cute-dsl being the source code of flash attention 4 and the fastest MoE implementation -- sonic MoE).

to answer the question "should I learn CUDA?", many of our abstractions today rely on first principles which emerge from cuda originally. theres simply no shortcutting it. if you are committing to kernels, you go all the way. its fine to dabble and explore around the corners a bit to know how deep you actually want to get, but making the fastest deep learning kernels faster is ambitious and unrealistic given that this process will likely be fully automated in a year or so. knowing how to use tools to generate the fastest kernels is a great skill, but optimizing them yourself may not be the best use of your time unless this is your true destiny in some way (idk who decides that lol)

i know you didn't ask, but i should mention here that im writing a cuda textbook for deep learning specifically. i chose to write this to give people a bigger piece that combines the essentials on the low level stack. i dont want to spoil it but it doesn't go into triton or any fancy stuff at all. its all the essentials that aren't going anywhere for a while, and are arguably needed even if you aren't working specifically on kernels all the time. there is still a point in learning some of these skills, but just enough so you can make the existing tools work for you. experts built these to solve their own pain points, and they knew it would help other engineers when they stumbled into such tools.

when u have a min, spin up a new llm conversation and get it to help you reach a personalized consensus point on if you should learn CUDA or not.

sources for stuff i talked about are in replies.

