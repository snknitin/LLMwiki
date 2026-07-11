---
title: "X"
author: "Ahmad"
username: "@TheAhmadOsman"
date: "2025-06-23"
tweet_url: "https://x.com/TheAhmadOsman/status/1937209604552741152"
tweet_type: "original"
likes: 656
retweets: 84
replies: 18
bookmarks: 1920
views: 136394
has_media: false
article_id: "1937207829422841856"
tags: ["twitter-bookmark", "llm"]
---

# X

> **Source:** [@TheAhmadOsman](https://x.com/TheAhmadOsman) · 2025-06-23 · 👍 656 · 💬 18 · 🔖 1920 · 👁 136394

> 🔗 [View tweet on X](https://x.com/TheAhmadOsman/status/1937209604552741152)

## Article Content

https://x.com/TheAhmadOsman/article/1937209604552741152/media/1937793855203471360~$ ./learn_llms.sh

****Welcome to the "how do I actually learn how LLMs work" guide. If you've got a CS background and you're tired of the endless machine learning prerequisites, this is for you. I built this with past me in mind, I wish I had it all drawn out like this. This roadmap should have you comfortable with building, training, and exploring and researching.****

****🔁******** This article has been republished on my personal site for a better reading experience.**** It features improved formatting, easier navigation, and updated content. ****Read it here: ****[ahmadosman.com/blog/learn-llms-roadmap/](https://ahmadosman.com/blog/learn-llms-roadmap/)

The links at the end let you go as deep as you want. If you're stuck, rewatch or reread. If you already know something, skip ahead. The phases are your guardrails, not handcuffs. By the end, you'll have actually built the skills. Every resource, every project, every link is there for a reason. Use it, adapt it, and make it your own. I hope you don't just use this as a collection of bookmarks.

Remember, you can always use [DeepResearch](https://x.com/TheAhmadOsman/status/1935972463868801239)

 when you're stuck, need something broken down to first principles, want material tailored to your level, need to identify gaps, or just want to explore deeper.

This is blogpost #4 in my [101 Days of Blogging](https://x.com/TheAhmadOsman/status/1935548839559037002)

. If it sparks anything; ideas, questions, or critique, my DMs are open. Hope it gives you something useful to walk away with.

### TL;DR – What Are We Doing?

****The short version:****

- 5 phases.
- No detours into generic ML unless it's absolutely necessary.
- Focused on the fundamentals that would get you to comfortably be able to build, fine-tune, and ship LLMs.

You will:

- Build an autograd engine by hand
- Build a mini-GPT from scratch
- Fine-tune a model using PEFT like LoRA/QLoRA

### How This Works

The approach here is simple.

****Learn by Layering:**** Build Intuition ➡️ Strengthen Theory ➡️ More Hands-on ➡️ Paper Deep Dives ➡️ Build Something Real.

You're going to use four kinds of resources:

1. ****Visual Intuition**** (3Blue1Brown, Karpathy) – get the why and how well.
2. ****Formal Theory**** (Stanford/MIT lectures, open courseware) – unfortunately, sometimes you do need the math.
3. ****Papers**** ("Attention Is All You Need", BERT, LoRA, etc) – get used to reading papers.
4. ****Coding Projects.****

****Concepts first, then the breakdown, then the tools to go do it.****

The ****Roadmap Overview**** section is there to give you the conceptual big picture, it tells you what you'll need to understand, at a high level. After that, the ****How To Actually Learn**** section breaks those concepts down into ****actual learning phases:**** what to study, how to build intuition, which projects to complete, and in what order. Finally, the ****Where To Learn Them**** section links out to the exact videos, lectures, papers, and codebases that'll help you execute this roadmap. ****So: concepts first, then the breakdown, then the tools to go do it.****

### Roadmap Overview & Topics

****Foundations Refresher****

- Linear Algebra and Probability that actually matter for DL
- Python/PyTorch for the dirty work
- Project: Build Micrograd. Afterwards you'll build an MLP and train it

****Transformers****

- Tokenization, embeddings, self-attention, all the block diagram stuff
- Pre-training paradigms: BERT/MLM vs GPT/CLM, and the why, how, and when
- Project: Build a working mini-GPT from scratch

****Scaling and Training****

- How "scaling laws" actually predict performance (math)
- Distributed training: Data, Tensor, Pipeline parallelism
- Project: Spin up multi-GPU training with HuggingFace Accelerate. Make it run, see why things break, fix it

****Alignment + Fine-Tuning****

- RLHF/Constitutional AI
- LoRA/QLoRA: parameter-efficient fine-tuning
- Project: Implement LoRA from scratch. Plug it into a HuggingFace model and actually fine-tune on a use case

****Inference Optimizations****

- Inference optimization: FlashAttention, quantization, getting sub-second responses

### How To Actually Learn (The Real Plan)

****Phases 0: Foundations Refresher****

You do not need a PhD in math to understand LLMs. But if you can't follow a simple PyTorch training loop, or you have zero intuition for matrix multiplication, things will seem very confusing (they really aren't once you get your head around them).

- ****Linear Algebra/Probability****: 3Blue1Brown's videos. I'd say, it's helpful to be able to "see" a matrix transform, rewatch if needed.
- ****Formal theory****: MIT 18.06 Linear Algebra (Strang, of course).
- ****Coding****: Karpathy's Micrograd series. The only "autograd engine from scratch" tutorial that isn't boring from my experience.
- ****PyTorch****: Do the official basics, but spend most of your time translating math into code.
- ****Mini-project****: Build Micrograd. Build and train a basic MLP on MNIST. No shortcuts.

****Phases 1: Transformers****

I have this [meme](https://x.com/TheAhmadOsman/status/1922336545719107759)

 about how the words are the scariest part in LLMs. Transformers is the very first word you need your brain to think "easy" when you hear. They're just stacks of matrix multiplications and attention blocks, with some really clever engineering.

- ****Intuition****: 3Blue1Brown on Transformers/Attention. Jay Alammar's Illustrated Transformer. Watch, take notes, and re-watch if you need to.
- ****Formal****: Stanford CS224N Natural Language Processing with Deep Learning (the lectures, not just the slides).
- ****Paper****: "Attention Is All You Need". Don't read it yet if you haven't built the mental model above. Otherwise, you'll drown. READ ONLY ONCE COMFORTABLE WITH ALL THE ABOVE.
- ****Hands-on****: Karpathy's "Let's Build GPT" (eureka moment, you'll realize how simple all of it is).
- ****Project****: Reimplement a decoder-only GPT from scratch. Bonus points: swap in your own tokenizer, try BPE/SentencePiece.

****Phases 2: Scaling Laws & Training for Scale****

LLMs got good through figuring out what to scale, how to scale it, proving it could scale, and showing that it actually works.

- ****Papers****: "Scaling Laws for Neural Language Models" (Kaplan et al), then "Chinchilla" (Hoffmann et al). Learn the difference.
- ****Distributed Training****: Learn what Data, Tensor, and Pipeline Parallelism actually do. Then set up multi-GPU training with HuggingFace Accelerate. ****Yes, you'll hate CUDA at some point. Such is life.****
- ****Project****: Pick a model, run a small distributed job. Play with batch sizes, gradient accumulation. Notice how easy it is to run out of VRAM? Good. [Welcome to my world](https://x.com/TheAhmadOsman/status/1935852655479595489)

.

****Phases 3: Alignment & PEFT****

Fine-tuning is not just a cheap trick. RLHF and PEFT are the reason you can actually use LLMs for real-world use cases.

- ****RLHF****: OpenAI's "Aligning language models to follow instructions" blog post, then Ouyang et al's paper. Grasp the SFT ➡️ Reward Model ➡️ RL pipeline. Don't get lost in PPO math too much.
- ****CAI/RLAIF****: Read Anthropic's "Constitutional AI".
- ****LoRA/QLoRA****: Read both papers, then actually implement LoRA in PyTorch. If you can't replace a Linear layer with a LoRA-adapted version, try again.
- ****Project****: Fine-tune an open model (e.g. gpt2, distilbert) with your own LoRA adapters. Do it for a real dataset, not toy text.

****Phases 4: Production****

You made it to the only part that most people ever see: the actual app.

- ****Inference Optimization****: Read the FlashAttention paper. Understand why it works, then try it with a quantized model.

### Where To Learn Them

Below is what to read/watch for the this learning plan.

****Math/CS Pre-Reqs****

- [3Blue1Brown: Essence of Linear Algebra (YouTube)](https://www.youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab)
- [MIT 18.06: Linear Algebra (Strang, OCW)](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/video_galleries/video-lectures/)
- [Deep Learning Book (Goodfellow)](https://www.deeplearningbook.org/)

****PyTorch Fundamentals****

- [Karpathy: Neural Networks Zero to Hero](https://karpathy.ai/zero-to-hero.html)
- [PyTorch Learn the Basics](https://pytorch.org/tutorials/beginner/basics/intro.html)
- [Zero to Mastery PyTorch](https://www.learnpytorch.io/)

****Transformers & LLMs****

- [Attention Is All You Need (Vaswani et al)](https://arxiv.org/abs/1706.03762)
- [3Blue1Brown: What is a GPT? (YouTube)](https://www.3blue1brown.com/lessons/gpt)
- [Jay Alammar: The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)
- [Karpathy: Let's Build GPT](https://www.youtube.com/watch?v=kCc8FmEb1nY)
- [Stanford CS224N (YouTube Lectures)](https://www.youtube.com/playlist?list=PLoROMvodv4rMFqRtEuo6SGjY4XbRIVRd4)

****Scaling & Distributed Training****

- [Kaplan et al: Scaling Laws](https://arxiv.org/abs/2001.08361)
- [Chinchilla Paper (Hoffmann et al)](https://arxiv.org/abs/2203.15556)
- [HuggingFace Accelerate](https://huggingface.co/docs/accelerate/)

****Alignment & PEFT****

- [OpenAI: Aligning LMs to Follow Instructions](https://openai.com/index/instruction-following/)
- [Anthropic: Constitutional AI](https://arxiv.org/abs/2212.08073)
- [LoRA: Low-Rank Adaptation](https://arxiv.org/abs/2106.09685)
- [QLoRA](https://arxiv.org/abs/2305.14314)
- [LightningAI: LoRA from Scratch](https://lightning.ai/lightning-ai/studios/code-lora-from-scratch)

****Inference****

- [FlashAttention Paper](https://arxiv.org/abs/2205.14135)

### The Endgame

If you actually do the roadmap above, build the projects, and push past the YouTube tutorial hell, you'll understand LLMs extremely well. You'll see through the hype, spot nonsense at a glance, and build your own models and tooling.

If you make it through this plan and actually ship something, DM me, I wanna see it.

****Happy hacking.****

> 📄 Original article URL: https://x.com/i/article/1937207829422841856

---

## Commentary from Other Bookmarks

### @TheAhmadOsman (Ahmad) — 2026-02-08

> @anuragtech5 Ask and you shall receive :)
> 
> https://x.com/TheAhmadOsman/status/1937209604552741152

[→ View quote tweet](https://x.com/TheAhmadOsman/status/2020441993873166808)

