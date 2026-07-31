---
title: "I tried Andrej Karpathy's autoresearch."
author: "Davit Buniatyan"
author_url: "https://www.linkedin.com/in/ACoAAAqyViUBkLqGZxdG9PFdHcqxUYOqEH88qnQ"
headline: "CEO @ Activeloop | Unlocking AI Data with Deeplake"
date: "2026-03-12"
posted_relative: "5mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7437697736981848065/"
activity_id: "7437697736981848065"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, ml]
---

# I tried Andrej Karpathy's autoresearch.

> **Source:** [Davit Buniatyan](https://www.linkedin.com/in/ACoAAAqyViUBkLqGZxdG9PFdHcqxUYOqEH88qnQ) · CEO @ Activeloop | Unlocking AI Data with Deeplake · 5mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7437697736981848065/)

## Post

I tried Andrej Karpathy's autoresearch.

The rules:
- run an experiment
- keep it if it improves
- revert it if it doesn’t
- repeat forever
- never ask permission

No theory debates. Just experiments.

After my 68 runs on NVidia DGX Spark:

1.725 BPB -> 1.145 BPB

The plot looks like a staircase.

Most steps are tiny.

But they compound.

This might be the simplest way to do ML research:

Let the experiments decide.

Here is how to run without breaking claude code.

claude -p "Hi, have a look at program.md and let's kick off a new experiment! Let's do the setup first." \
 --model claude-opus-4-6 \
 --dangerously-skip-permissions \
 --permission-mode bypassPermissions \
 --output-format stream-json \
 --verbose \
 --include-partial-messages \
 -c \
 2>&1 | tee -a logs/claude.txt

## Images

![](https://media.licdn.com/dms/image/v2/D5622AQHELHUPtooAxA/feedshare-shrink_480/B56ZzgCre5H8Ak-/0/1773285325040?e=1787184000&v=beta&t=L5zH1pIZp4Tlm29HVNsG70PjBywpiEyC2dTp8zk1LtU)

