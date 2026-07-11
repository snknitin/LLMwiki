---
title: "Do AGENTS.md Files Actually Help Coding Agents?"
source: "https://x.com/rasbt/status/2063649136323252397"
author:
  - "[[@rasbt]]"
published: 2026-06-07
created: 2026-06-08
description: "Catching up with the agent-related research literature, one paper that definitely got my attention is \"Evaluating AGENTS.md: Are Repository-..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/HKONleZXoAACQ1b?format=jpg&name=large)

Catching up with the agent-related research literature, one paper that definitely got my attention is "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?." It looks into whether adding repository-level instruction files such as AGENTS.md or CLAUDE.md to tell coding agents how to work in a codebase is actually helpful.

The paper evaluates this in two settings. First, it uses SWE-bench Lite, where the authors generate context files because the original repositories do not necessarily contain developer-written ones.

Second, they introduce AGENTBENCH, a new benchmark of 138 Python tasks from 12 repositories that already have developer-provided context files. The agents are then evaluated under three conditions: no context file, an LLM-generated context file, and, where available, a developer-written context file. The results are summarized below.

![Image](https://pbs.twimg.com/media/HKOM0lVXIAAmZ3y?format=png&name=large)

Figure 1: Main results from the Evaluating AGENTS.md paper ([https://arxiv.org/abs/2602.11988](https://arxiv.org/abs/2602.11988)).

Based on the results shown in the figure above, compared to using no context files, LLM-generated context files reduce task success slightly or don’t make a big difference on average. This is maybe surprising but maybe not, because I guess the LLM / agent harness just generates the necessary context information on the fly. The context file is more about improving efficiency between independent sessions.

Also, developer-written context files are better than LLM-generated ones, which is perhaps expected because that’s where the domain expertise comes in.

What’s very surprising though is that using no context files is also cheaper and more efficient in their benchmarks!

![Image](https://pbs.twimg.com/media/HKONC9CW8AA9sSk?format=jpg&name=large)

Figure 2: Efficiency results from the Evaluating AGENTS.md paper ([https://arxiv.org/abs/2602.11988](https://arxiv.org/abs/2602.11988)).

The fact that using no context files results in better efficiency is a bit mind-boggling at first. I first suspected this is perhaps because the harnesses here might be processing redundant information (i.e., they read the context files, and, no matter what, they parse the additional info from the code repo as if they hadn’t read the context files).

The researchers did a trace analysis here that showed that the agents generally follow the instructions in the context files, but they run more tests, search more files, read more files, and use more repository-specific tools when those tools are mentioned. So the negative or weak performance effect does not seem to come from agents ignoring the files. A more likely explanation is that context files often add requirements and exploration steps that make the task harder or more thorough, but as we saw in Figure 11, this doesn’t necessarily result in better success.

My takeaway is that repository-level context files should probably be kept shorter and more specific and perhaps ideally hierarchical (e.g., “if you do x, check this other context file y.md, otherwise ignore it”).

Of course, the problem here is that the LLMs and harnesses are a bit dated by now, and it would be interesting to redo this study with the latest harnesses and LLMs.

Link to the paper on arxiv: [https://arxiv.org/abs/2602.11988](https://arxiv.org/abs/2602.11988)