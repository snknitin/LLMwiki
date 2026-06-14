---
title: "Wow.. Now you can transcribe 60 minutes of audio in just 1 second with a completely open-sourced mod..."
author: "Rohan Paul"
username: "@rohanpaul_ai"
date: "2025-05-07"
tweet_url: "https://x.com/rohanpaul_ai/status/1920069397277774228"
tweet_type: "original"
likes: 3247
retweets: 391
replies: 57
bookmarks: 4185
views: 242500
has_media: true
extraction_quality: full
tags: ["twitter-bookmark"]
---

# Wow.. Now you can transcribe 60 minutes of audio in just 1 second with a completely open-sourced mod...

> **Source:** [@rohanpaul_ai](https://x.com/rohanpaul_ai) · 2025-05-07 · 👍 3247 · 💬 57 · 🔖 4185 · 👁 242500

> 🔗 [View tweet on X](https://x.com/rohanpaul_ai/status/1920069397277774228)

## Tweet Content

Wow.. Now you can transcribe 60 minutes of audio in just 1 second with a completely open-sourced model 


@nvidia
 just open-sourced Parakeet TDT 0.6B V2, a 600M parameter automatic speech recognition (ASR) model that tops the 
@huggingface
 Open-ASR leaderboard with RTFx 3380

It's open-sourced under CC-BY-4.0, ready for commercial use.

 The Details

→ Built on FastConformer encoder + TDT decoder, the model handles up to 24-minute audio chunks with full attention and outputs with punctuation, capitalization, and accurate word/char/segment timestamps.

→ It achieves RTFx 3380 at batch size 128 on the Open ASR leaderboard, but performance varies with audio duration and batch size.

→ Trained using 150K steps on 128 A100 GPUs, then fine-tuned on 500 hours of high-quality human-transcribed English data.

→ Total training data spans 120K hours, combining human-labeled and pseudo-labeled sources, including LibriSpeech, Fisher, YTC, YODAS, and more.

→ Available via NVIDIA NeMo, optimized for GPU inference, and installable via pip install -U nemo_toolkit['asr'].

→ Compatible with Linux, runs on Ampere, Blackwell, Hopper, Volta GPU architectures, requiring minimum 2GB RAM.

→ Granary dataset used for training will be made public post Interspeech 2025.

## Media

![](https://pbs.twimg.com/media/GqV07AeXcAA9klA.jpg)

