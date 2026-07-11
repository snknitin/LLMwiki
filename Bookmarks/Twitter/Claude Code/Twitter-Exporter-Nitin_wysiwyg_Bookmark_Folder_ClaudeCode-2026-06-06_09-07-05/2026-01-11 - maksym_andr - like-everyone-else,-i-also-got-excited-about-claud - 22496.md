---
title: "Like everyone else, I also got excited about Claude Code + Opus 4.5. This led me to update my scient..."
author: "Maksym Andriushchenko"
username: "@maksym_andr"
date: "2026-01-11"
tweet_url: "https://x.com/maksym_andr/status/2010418240523022496"
tweet_type: "original"
likes: 527
retweets: 37
replies: 28
bookmarks: 792
views: 67560
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "claude", "llm", "agents"]
---

# Like everyone else, I also got excited about Claude Code + Opus 4.5. This led me to update my scient...

> **Source:** [@maksym_andr](https://x.com/maksym_andr) · 2026-01-11 · 👍 527 · 💬 28 · 🔖 792 · 👁 67560

> 🔗 [View tweet on X](https://x.com/maksym_andr/status/2010418240523022496)

## Tweet Content

Like everyone else, I also got excited about Claude Code + Opus 4.5. This led me to update my scientific writing workflow over the holidays:
- Claude Code Max ($200/month) with Opus 4.5 and variable levels of thinking (e.g., ultrathink for the hardest tasks like literature overviews). Yes, the $20/month subscription is not enough.
- Most useful for coding (quick experiments, data analysis, websites) and writing (papers, blog posts, grants, recommendation letters; unless this is explicitly forbidden).
- Run Claude Code locally in your LaTeX repository and sync with Overleaf via the Git + Overleaf integration. If there is a merge conflict due to simultaneous changes in the web version of Overleaf, use Claude Code to resolve merge conflicts.
- Run multiple Claude Code instances in parallel as some tasks take a while (e.g., a literature overview with `ultrathink` can take ~10 min). Note: simultaneous updates by multiple agents are fine, since Claude Code uses a diff-based approach (so it basically ends up like simultaneous edits in a Google Doc).
- Always provide YOUR input to Claude Code, in most cases raw bullet points or already existing artifacts (e.g., a blog post, GitHub repo, etc.). Context engineering is always key here.
- Always carefully check outputs. YOU are responsible for all mistakes, hallucinations, etc.
- Keep CLAUDE .md up-to-date and manually add detailed guidance (say, ~2-3 pages) on scientific writing, style, structure, etc.
- Enable "Verbose output" as sometimes Claude can misunderstand you or simply be wrong about something. It's faster to catch this in the terminal rather than later on.
- Use screenshots from a compiled PDF to insert back into Claude Code to provide the right context for any LaTeX-related changes (note: inserting images is Control+V instead of Command+V on Mac).

Tips:
- Claude Code is great for polishing papers: catching typos, logical inconsistencies, mismatches in numbers, etc. Making a thorough pass over the whole paper is very costly for humans, but very quick and cheap for LLMs.
- Also, Claude Code is great at converting between different formats. If a paper is already written, creating a blog post or poster is just one prompt + post-hoc polishing. This saves a lot of time!

As a result, CLI agents like Claude Code allow people to allocate more time for *actual thinking* instead of spending lots of time on "low-level" writing and debugging latex (as I did during my PhD!).

Frontier LLM agents still have limitations, though:
- Lack of up-to-date world knowledge (e.g., May 2025 for Opus 4.5, which is obviously pretty bad for AI research that moves very fast). This can be mitigated to some extent by forcing an LLM to use web search for narrow use cases or relying on an already written and verified related work section.
- Lack of project context (e.g., all discussions throughout a project's lifetime that happen in different ways: in-person, over Slack/email/GitHub, etc.).
- Imperfect tools (e.g., some websites are fetched only partially, which can introduce subtle errors).
- Lack of research taste (which is why using LLMs for reviewing is still a very bad idea!).

Interestingly, none of these limitations are due to the lack of relevant capabilities (maybe except the research taste one - will it be an emergent capability of some sort?). Hallucinations are quite rare. Tool use feels very natural and intuitive. Most of the limitations above are due to the lack of continual learning and limited context window.

Would be curious to hear what kind of workflows others came up with!

