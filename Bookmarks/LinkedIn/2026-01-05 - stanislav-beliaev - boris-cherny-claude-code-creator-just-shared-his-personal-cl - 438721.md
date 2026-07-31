---
title: "Boris Cherny (Claude Code creator) just shared his personal Claude setup to get 10x better results �..."
author: "Stanislav Beliaev"
author_url: "https://www.linkedin.com/in/ACoAACPwVh4B9nRz6TBuOrJzp8I7gScS9bvv968"
headline: "Co-Founder & CTO at GetFluently.App (YC W24), ex Nvidia"
date: "2026-01-05"
posted_relative: "7mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7413977077873438721/"
activity_id: "7413977077873438721"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, agents, llm, mcp]
---

# Boris Cherny (Claude Code creator) just shared his personal Claude setup to get 10x better results �...

> **Source:** [Stanislav Beliaev](https://www.linkedin.com/in/ACoAACPwVh4B9nRz6TBuOrJzp8I7gScS9bvv968) · Co-Founder & CTO at GetFluently.App (YC W24), ex Nvidia · 7mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7413977077873438721/)

## Post

Boris Cherny (Claude Code creator) just shared his personal Claude setup to get 10x better results 👇

1) Parallel sessions are the foundation
Boris runs 5 Claude sessions in parallel via terminal (numbered tabs 1-5). System notifications alert him when Claude needs input.

→ Setup guide: https://lnkd.in/ddRsYK8n

2) Local + web sessions at once
He also runs 5–10 sessions on claude.ai/code. Tasks are passed between local and web using & and --𝘁𝗲𝗹𝗲𝗽𝗼𝗿𝘁. He launches sessions from his iPhone every morning and checks in later.

3) Opus 4.5 with thinking mode
It’s slower than Sonnet but smarter, requires less steering, and ends up faster in real use.

4) Shared 𝗖𝗟𝗔𝗨𝗗𝗘.𝗺𝗱
The team maintains a living doc checked into git. Every mistake Claude makes = logged and avoided in future. Each team has its own version.

5) Update docs via GitHub PRs
During code review, teammates tag @.𝗰𝗹𝗮𝘂𝗱𝗲 to update 𝗖𝗟𝗔𝗨𝗗𝗘.𝗺𝗱 directly in the PR. The Claude GitHub Action automates it, like a shared brain that keeps improving.

6) Always start in Plan Mode
Sessions start in Plan Mode (Shift+Tab twice). Once the plan is solid, Boris switches to auto-accept edits, Claude usually completes the task in one shot.

7) Slash commands for repeat tasks
Boris creates slash commands (in .𝗰𝗹𝗮𝘂𝗱𝗲/𝗰𝗼𝗺𝗺𝗮𝗻𝗱𝘀/) for workflows he does often. /𝗰𝗼𝗺𝗺𝗶𝘁-𝗽𝘂𝘀𝗵-𝗽𝗿 handles git + PR in one go.

8) Subagents for PR workflows
Subagents like 𝗰𝗼𝗱𝗲-𝘀𝗶𝗺𝗽𝗹𝗶𝗳𝗶𝗲𝗿 and 𝘃𝗲𝗿𝗶𝗳𝘆-𝗮𝗽𝗽 automate common tasks like cleanup and end-to-end testing.

9) PostToolUse hook for formatting
Claude formats code pretty well, but this hook ensures 100% consistency to avoid CI fails.

10) Avoid --𝗱𝗮𝗻𝗴𝗲𝗿𝗼𝘂𝘀𝗹𝘆-𝘀𝗸𝗶𝗽-𝗽𝗲𝗿𝗺𝗶𝘀𝘀𝗶𝗼𝗻𝘀
Instead, pre-approve safe bash commands via /𝗽𝗲𝗿𝗺𝗶𝘀𝘀𝗶𝗼𝗻𝘀. Stored in .𝗰𝗹𝗮𝘂𝗱𝗲/𝘀𝗲𝘁𝘁𝗶𝗻𝗴𝘀.𝗷𝘀𝗼𝗻 and shared across the team.

11) Claude integrates with external tools
Slack messages, Sentry logs, BigQuery queries - Claude runs them all via MCP server. Config lives in .𝗺𝗰𝗽.𝗷𝘀𝗼𝗻.

12) Handle long tasks with agents + sandbox
Boris uses:
- background agents
- stop hooks
- the Ralph-Wiggum plugin (a wild but effective idea)

13) Claude verifies its own work
The most underrated step. Claude uses the Chrome extension to test every change it lands - UI, UX, behavior. Real feedback loop = 2-3x better results.

--
Bonus: GetFluently.app 👉 AI English tutor for non-native professionals
--

♻️ Save and share with your network to help others get more out of Claude Code.

## Links

- https://lnkd.in/ddRsYK8n

## Images

![](https://media.licdn.com/dms/image/v2/D4D22AQE0-5kILZDecA/feedshare-shrink_480/B4DZuO82YoGgAc-/0/1767629878842?e=1787184000&v=beta&t=daN7MPraTAluf57Y2rDPM7JekV3SljiR2s5J7bvGhCg)

