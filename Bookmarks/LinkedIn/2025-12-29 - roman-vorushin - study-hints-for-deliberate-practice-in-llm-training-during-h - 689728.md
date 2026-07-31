---
title: "Study hints for deliberate practice in LLM training during holidays:"
author: "Roman Vorushin"
author_url: "https://www.linkedin.com/in/ACoAAABA4pEBost5E5FMoubScAC2ctHbhPi1_6c"
headline: "Research Engineer, Google DeepMind | Gemini | JAX, TPUs, Pallas"
date: "2025-12-29"
posted_relative: "7mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7411315396143689728/"
activity_id: "7411315396143689728"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, career, ml]
---

# Study hints for deliberate practice in LLM training during holidays:

> **Source:** [Roman Vorushin](https://www.linkedin.com/in/ACoAAABA4pEBost5E5FMoubScAC2ctHbhPi1_6c) · Research Engineer, Google DeepMind | Gemini | JAX, TPUs, Pallas · 7mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7411315396143689728/)

## Post

Study hints for deliberate practice in LLM training during holidays:

1. Stanford CS 336 Language Modeling from Scratch - really good videos and exercises from people that do pre-train and post-train quite large LLMs and talk to a lot of people in the industry.

2. The TPU book ("How To Scale Your Model") - teaches not just how TPUs are used to do efficient matmuls for transformer training, but all the transformer math, parallelism methods, strategies for effective inference, etc.

3. "Interview Prep: The ML Grind" by Jenya - lots of interesting little tasks to implement in pure NumPy to deepen the understanding of the matmul flow, activation flow, and gradient flow.

4. "Reinforcement Learning: An Introduction" book by Sutton and Barto. It's not exactly about RLHF and RLVF, but has all the important fundamentals.

How to practice deliberately? Take an interesting piece you want to improve on, copy-paste the relevant material into your favorite LLM and ask it to formulate you some problems to solve in JAX, NumPy, PyTorch. Try to write in Google Colab or your favourite editor as much code on you own as possible and only go to the LLM for hints when truly stuck. Send the partial and full solution to your chatbot and ask for the review/critique, ask how it could be improved, what needs to be changed for it to work at the big labs scale.

