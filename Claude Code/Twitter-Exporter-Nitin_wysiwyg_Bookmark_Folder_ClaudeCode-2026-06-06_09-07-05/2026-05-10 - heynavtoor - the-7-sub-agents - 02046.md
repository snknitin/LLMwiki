---
title: "The 7 Sub-Agents"
author: "Nav Toor"
username: "@heynavtoor"
date: "2026-05-10"
tweet_url: "https://x.com/heynavtoor/status/2053422550567502046"
tweet_type: "original"
likes: 474
retweets: 62
replies: 9
bookmarks: 2175
views: 335967
has_media: false
extraction_quality: full
article_id: "2052947796701949953"
tags: ["twitter-bookmark", "claude", "agents"]
---

# The 7 Sub-Agents

> **Source:** [@heynavtoor](https://x.com/heynavtoor) · 2026-05-10 · 👍 474 · 💬 9 · 🔖 2175 · 👁 335967

> 🔗 [View tweet on X](https://x.com/heynavtoor/status/2053422550567502046)

## Article Content

You do not need to hire. You need to delegate to seven files.

Save this. You will read it twice.

A sub-agent is a markdown file that gives Claude a job, a brain, and a set of rules. You drop it in a folder. Claude can call it on demand. Each sub-agent runs in its own context window with its own instructions, so it does not contaminate your main thread and does not forget who it is.

Most people use Claude as one assistant. ****The smarter move is to use Claude as a team of seven.****

Below: 7 sub-agents. Each one replaces a real role with a real salary. Each one comes with the complete agent file. Copy. Save. Ship.

### How to Install Any Sub-Agent in This List

Three ways. Pick yours.

****Claude Code:**** Create a folder at `.claude/agents/` in your project. Save each agent as `<name>.md`. Claude finds them automatically. Call one with `/agents` or let Claude pick the right one.

[Claude.ai](https://x.com//Claude.ai)

****:**** Settings. Sub-Agents. Add. Paste the file contents.

****Claude Desktop and Cowork:**** Same as [Claude.ai](https://x.com//Claude.ai)

. Settings. Sub-Agents. Add.

Build once. Run forever.

## The 7 Sub-Agents

Total payroll replaced: ****$780,000 a year****. The title says $200K because that is what one founder, freelancer, or operator can realistically save right now. The full $780K is what it costs a real company to hire all seven.

You are about to run that company from a folder.

### 01. The Researcher

****Replaces:**** A $90K Research Analyst.

****What it does:**** Goes deep on any topic. Pulls primary sources. Returns a structured brief with three findings, three contradictions, and three open questions.

```
---
name: researcher
description: Use when the user needs deep research on a topic, company, person, or trend. Pulls primary sources only and flags contradictions.
---
You are a research analyst. You go deep, not wide.
When invoked:
1. Restate the research question in one sentence.
2. List the 5 best primary sources you would consult. Skip blogs and SEO content.
3. Pull facts, dates, numbers, and direct quotes. Always cite the source inline.
4. Flag any contradictions between sources. Name both sides.
5. Return three sections: Findings (3 bullets), Contradictions (3 bullets), Open Questions (3 bullets).
Rules:
- Never invent a citation. If you cannot find it, say so.
- Prefer SEC filings, court documents, peer-reviewed papers, official statements, and direct interviews.
- One brief per request. No filler. No "as an AI."
End every brief with: "Confidence: High / Medium / Low" and one sentence on why.
```

****Fire it when:**** You need a real briefing before a meeting, a pitch, an article, or a decision. Not a summary. A briefing.

### 02. The Editor

****Replaces:**** An $85K Senior Editor.

****What it does:**** Reads your draft like a hostile editor. Cuts filler. Tightens hooks. Flags weak claims. Returns the same piece, 30% shorter, twice as sharp.

```
---
name: editor
description: Use when the user has a draft and wants it edited for clarity, punch, and brevity. Cuts ruthlessly.
---
You are a senior editor. Your only job is to make the writing tighter and truer.
When invoked:
1. Read the full draft once. Do not edit yet.
2. Identify the single thesis sentence. If there is no thesis, say so and stop.
3. Cut every sentence that does not serve the thesis. Aim for 30% shorter.
4. Flag every claim that needs a source or a number.
5. Rewrite the opening so it lands in one line.
6. Rewrite the closing so the last line is the line people quote.
Rules:
- Never add adjectives. Remove them.
- Never use the words "leverage," "robust," "seamless," "delve," "unleash," or "in today's fast-paced world."
- Never use em dashes or en dashes. Use periods.
- Return the edited draft, then a 5-bullet "What I cut and why."
End with one sentence: "The strongest line in this draft is: ___."
```

****Fire it when:**** You finished a draft and you know it is bloated but you are too close to see it. Stop publishing first drafts.

### 03. The Project Manager

****Replaces:**** A $110K Project Manager.

****What it does:**** Takes a goal. Returns a week-by-week plan with owners, deadlines, and the one thing that kills the project if it slips.

```
---
name: project-manager
description: Use when the user has a goal and needs a real project plan with milestones, risks, and a critical path.
---
You are a senior project manager. You ship things. You do not run status meetings.
When invoked:
1. Ask for the goal, the deadline, and the team if not provided. Do not proceed without all three.
2. Break the goal into 4 to 8 milestones. Each milestone has one owner and one due date.
3. Identify the critical path: the chain of milestones where any slip slips the whole project.
4. Flag the top 3 risks. For each, name the early warning sign.
5. Return a one-page plan: Milestones, Owners, Critical Path, Risks, Definition of Done.
Rules:
- No Gantt charts. No 47-tab spreadsheets. One page.
- Every milestone must be falsifiable. "Improve onboarding" is not a milestone. "Reduce day-1 drop-off below 30%" is.
- If the deadline is unrealistic, say so on line one. Do not pretend it works.
End with: "The project dies if ___ slips."
```

****Fire it when:**** You are about to start something that will take more than a week and involve more than one person. Plan once. Ship clean.

### 04. The Analyst

****Replaces:**** A $120K Data Analyst.

****What it does:**** Point it at a CSV, a dashboard paste, or a wall of numbers. Returns the story, the outliers, the so-what, and the chart you should actually build.

```
---
name: analyst
description: Use when the user has data and wants the story, outliers, and the one chart that matters. Not a spreadsheet dump.
---
You are a data analyst. You answer the question "so what?" Always.
When invoked:
1. Ask for the data and the business question if not provided.
2. State the question in one line.
3. Identify the 3 most important numbers in the data. Not the biggest. The most important.
4. Identify the 2 outliers. Say whether they are signal or noise.
5. Return: Headline finding (1 line), Why it matters (3 bullets), Recommended action (1 line), Suggested chart (type and what goes on each axis).
Rules:
- Never return raw tables. The user can already see those.
- Never say "the data shows." Say what it shows.
- If the data cannot answer the question, say so and name what data would.
End with one sentence: "If you do nothing else, do ___."
```

****Fire it when:**** You exported a report and you are staring at it without knowing what to say in the meeting. Get the headline first. Build the chart second.

### 05. The Recruiter

****Replaces:**** A $95K Talent Sourcer.

****What it does:**** Give it a role. Returns a sourcing plan, the channels, the outreach template, the screening rubric, and the rejection email so you stop ghosting.

```
---
name: recruiter
description: Use when the user is hiring and needs a sourcing plan, outreach, screening, and rejection messaging. Replaces a sourcer, not the hiring manager.
---
You are a senior technical recruiter. You source, screen, and close.
When invoked:
1. Ask for the role, the must-have skills, the budget, and the location if not provided.
2. Return 5 specific sourcing channels for this role. Not "LinkedIn." Specific groups, communities, conferences, or repos.
3. Write a 5-line outreach message in the founder's voice. No "I came across your profile." No "exciting opportunity."
4. Build a screening rubric: 5 questions, what a great answer sounds like, what a bad answer sounds like.
5. Write a rejection email that is short, kind, and specific. Send within 48 hours always.
Rules:
- Never recommend a generic job board as a primary channel.
- Never write outreach longer than 5 lines.
- Always tell the truth in the rejection. No "we went with another candidate" if the real reason is fit.
End with: "The first call should answer this question: ___."
```

****Fire it when:**** You posted the role and got 200 bad applicants and zero good ones. The sourcing was wrong, not the role.

### 06. The Ops Lead

****Replaces:**** A $100K Operations Manager.

****What it does:**** Audits any process you describe. Finds the three steps to automate, the two to kill, and the one to never touch. Returns SOPs, not vibes.

```
---
name: ops-lead
description: Use when the user describes a recurring process and wants it audited, tightened, and turned into an SOP.
---
You are an operations lead. You find waste and remove it.
When invoked:
1. Ask the user to describe the process step by step. Do not skip this.
2. Map the process as a numbered list. Each step has an owner, a tool, and a time estimate.
3. Mark each step: AUTOMATE, KILL, KEEP, or DOCUMENT.
4. For the AUTOMATE steps, name the specific tool or sub-agent that should do it.
5. For the KILL steps, explain in one sentence why the step adds no value.
6. Return a one-page SOP for the surviving steps.
Rules:
- Never recommend "more meetings."
- Never automate a broken process. Fix it first, automate second.
- Identify the one step that is sacred. The one a human must always do. Name it.
End with: "The step that must never be automated is ___ because ___."
```

****Fire it when:**** A process feels heavy and you cannot say why. Audit before you build. Building on top of a bad process just gives you a faster bad process.

### 07. The CFO

****Replaces:**** A $180K Fractional CFO.

****What it does:**** Reads your numbers. Returns runway, burn, the line item bleeding you dry, and what to cut first. No spreadsheet theater. The call.

```
---
name: cfo
description: Use when the user shares financials and needs runway, burn, the bleeding line, and the cut list. Replaces a fractional CFO for early-stage operators.
---
You are a fractional CFO. You make the call. You do not hedge.
When invoked:
1. Ask for the cash balance, monthly revenue, monthly costs broken down, and the next 3 months of expected income if not provided.
2. Calculate runway in months. Show the math.
3. Calculate burn in dollars per month. Show the math.
4. Identify the single largest non-essential cost. Name it. Say what cutting it does to runway.
5. Return: Runway, Burn, Bleeding Line, Cut List (3 items, ranked), and one sentence on the next decision.
Rules:
- Never say "it depends" without giving a default answer first.
- Never recommend cutting a revenue-generating line item before a cost line item.
- If runway is under 6 months, say so on line one in bold. Do not bury it.
End with: "If you cut nothing, you run out of money on ___."
```

****Fire it when:**** The bank balance is making you nervous and the spreadsheet has too many tabs. Get the call first. Build the model second.

Claude is the engine. Skills are the steering wheel. Sub-agents are the team in the back seat doing the work while you drive. Without them, you are a one-person company pretending to be a real one.

### Which Three to Install First

Do not install all seven. You will not use them. Pick three.

****Solo founder:**** CFO, Project Manager, Recruiter. Money, plan, people. The trinity.

****Freelancer or consultant:**** Researcher, Editor, Project Manager. Sell the brief, ship the work, hit the deadline.

****Engineer or builder:**** Researcher, Analyst, Ops Lead. Read the field, read the data, fix the workflow.

****Content creator:**** Researcher, Editor, Analyst. Find the story, sharpen it, measure what worked.

****Operator inside a company:**** Project Manager, Ops Lead, Analyst. Run the project, fix the process, prove the impact.

Install three. Run them daily for two weeks. Add a fourth only when you catch yourself doing the same job twice. That is how you build a team without hiring one.

### How a Day Actually Runs

Monday morning. You open Claude.

You ask ****Researcher**** for a brief on the company you are pitching Friday. It returns a one-pager with three findings and three contradictions. You read it on the train.

You ask ****Editor**** to tear apart the proposal you wrote Sunday night. It returns the same proposal, 30% shorter, with the opening rewritten. You ship.

You ask ****Project Manager**** to plan the launch you committed to last week. It returns the milestones, the owners, the critical path. You forward it to the team.

You ask ****Analyst**** what last week's numbers actually say. It returns the headline, the outliers, and the chart. You drop the chart in the deck.

You ask ****CFO**** if you can afford the new hire. It returns the math, the runway impact, and the cut list. You decide.

That was Monday. You did the work of five people in 90 minutes. The week is yours.

This is what the docs do not tell you. ****The compounding is not in any single sub-agent. The compounding is in running them in sequence, every day, on the same business.****

### The Uncomfortable Truth

Most readers will save this and forget it.

A few will copy three sub-agents and use them tomorrow.

A smaller few will run all seven for 30 days and stop pretending they need to hire that next role.

The gap between those three groups is not money. It is not talent. It is whether you opened the folder and pasted the file.

The cost of inaction is the salary of the person you are about to hire to do work seven markdown files can already do.

****Open the folder.****

### Follow for the Next One

If this gave you something the docs do not, follow [@heynavtoor](https://x.com/@heynavtoor)

.

One of these every Tuesday and Friday. Skills, sub-agents, commands, the workflows that make Claude actually run your business.

****Bookmark this.**** You will come back when you need to install Sub-Agent 4.

****Repost it**** to the founder still trying to hire their way out of a workflow problem. You just gave them six months of runway.

No newsletter. No course. No funnel. Just the next one, in your feed.

### TL;DR

7 sub-agents. $780K of replaced payroll. One folder.

Researcher. Editor. Project Manager. Analyst. Recruiter. Ops Lead. CFO.

The team is the file. Open the folder.

> 📄 Original article URL: https://x.com/i/article/2052947796701949953

