---
title: "Claude + Obsidian should be illegal."
author: "Defileo🔮"
username: "@defileo"
date: "2026-04-09"
tweet_url: "https://x.com/defileo/status/2042241063612502162"
tweet_type: "original"
likes: 9653
retweets: 980
replies_count: 203
bookmarks: 45850
views: 7263048
has_media: false
article_id: "2041858771123617793"
tags: ["twitter-bookmark", "obsidian", "claude", "mcp", "notebooklm", "llm", "ai-tools"]
---

# Claude + Obsidian should be illegal.

> **Source:** [@defileo](https://x.com/defileo) - 2026-04-09 - Likes: 9653 - Bookmarks: 45850 - Views: 7263048

> [View on X](https://x.com/defileo/status/2042241063612502162)

## Article Content

### Claude + Obsidian should be illegal.

Let me tell you what my setup does before I explain how to build it.

Every morning I open my laptop, Before I type a single word, Claude already knows who I am, what I'm working on, every crypto tool I use, every open task, every article I've ever written, and every idea I've ever captured.

That's not a chatbot, that's a second brain that never sleeps, never forgets, and gets smarter every single day you use it.

![](https://pbs.twimg.com/amplify_video_thumb/2042212949536755712/img/3wYNHsvcb_ov1PIR.jpg)

This as an example what you can make in 5 minutes

Here's exactly how it works, and how you can build it yourself this week, it will take you few hours to save you THOUSANDS of hours:

### How to set up your second brain in 5 minutes:

****First let's download Obsidian (If you don't have it yet), few clicks and it's installed easily:****

https://x.com/defileo/article/2042241063612502162/media/2042218008475488256

[https://obsidian.md/](https://obsidian.md/)

****Now you need to create your second brain, that's called vault, you can name me however you want, mine is Leo's workspace:****

https://x.com/defileo/article/2042241063612502162/media/2042219290980401152

****Download Claude code for your desktop if you still don't have it:****

https://x.com/defileo/article/2042241063612502162/media/2042220668087869440

[https://claude.com/product/claude-code](https://claude.com/product/claude-code)

****Then go to Claude code  and choose your vault:****

![](https://pbs.twimg.com/amplify_video_thumb/2042222353560604672/img/W0Lkb4drfrUf1Qv7.jpg)

And the most important step is Andrej Karpathy’s prompt, which I split into two parts.

Copy the first part, then the second, and then put them together:

```
# LLM Wiki

A pattern for building personal knowledge bases using LLMs.

This is an idea file, it is designed to be copy pasted to your own LLM Agent (e.g. OpenAI Codex, Claude Code, OpenCode / Pi, or etc.). Its goal is to communicate the high level idea, but your agent will build out the specifics in collaboration with you.

## The core idea

Most people's experience with LLMs and documents looks like RAG: you upload a collection of files, the LLM retrieves relevant chunks at query time, and generates an answer. This works, but the LLM is rediscovering knowledge from scratch on every question. There's no accumulation. Ask a subtle question that requires synthesizing five documents, and the LLM has to find and piece together the relevant fragments every time. Nothing is built up. NotebookLM, ChatGPT file uploads, and most RAG systems work this way.

The idea here is different. Instead of just retrieving from raw documents at query time, the LLM **incrementally builds and maintains a persistent wiki** — a structured, interlinked collection of markdown files that sits between you and the raw sources. When you add a new source, the LLM doesn't just index it for later retrieval. It reads it, extracts the key information, and integrates it into the existing wiki — updating entity pages, revising topic summaries, noting where new data contradicts old claims, strengthening or challenging the evolving synthesis. The knowledge is compiled once and then *kept current*, not re-derived on every query.

This is the key difference: **the wiki is a persistent, compounding artifact.** The cross-references are already there. The contradictions have already been flagged. The synthesis already reflects everything you've read. The wiki keeps getting richer with every source you add and every question you ask.

You never (or rarely) write the wiki yourself — the LLM writes and maintains all of it. You're in charge of sourcing, exploration, and asking the right questions. The LLM does all the grunt work — the summarizing, cross-referencing, filing, and bookkeeping that makes a knowledge base actually useful over time. In practice, I have the LLM agent open on one side and Obsidian open on the other. The LLM makes edits based on our conversation, and I browse the results in real time — following links, checking the graph view, reading the updated pages. Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase.

This can apply to a lot of different contexts. A few examples:

- **Personal**: tracking your own goals, health, psychology, self-improvement — filing journal entries, articles, podcast notes, and building up a structured picture of yourself over time.
- **Research**: going deep on a topic over weeks or months — reading papers, articles, reports, and incrementally building a comprehensive wiki with an evolving thesis.
- **Reading a book**: filing each chapter as you go, building out pages for characters, themes, plot threads, and how they connect. By the end you have a rich companion wiki. Think of fan wikis like [Tolkien Gateway](https://tolkiengateway.net/wiki/Main_Page) — thousands of interlinked pages covering characters, places, events, languages, built by a community of volunteers over years. You could build something like that personally as you read, with the LLM doing all the cross-referencing and maintenance.
- **Business/team**: an internal wiki maintained by LLMs, fed by Slack threads, meeting transcripts, project documents, customer calls. Possibly with humans in the loop reviewing updates. The wiki stays current because the LLM does the maintenance that no one on the team wants to do.
- **Competitive analysis, due diligence, trip planning, course notes, hobby deep-dives** — anything where you're accumulating knowledge over time and want it organized rather than scattered.

## Architecture

There are three layers:

**Raw sources** — your curated collection of source documents. Articles, papers, images, data files. These are immutable — the LLM reads from them but never modifies them. This is your source of truth.

**The wiki** — a directory of LLM-generated markdown files. Summaries, entity pages, concept pages, comparisons, an overview, a synthesis. The LLM owns this layer entirely. It creates pages, updates them when new sources arrive, maintains cross-references, and keeps everything consistent. You read it; the LLM writes it.

**The schema** — a document (e.g. CLAUDE.md for Claude Code or AGENTS.md for Codex) that tells the LLM how the wiki is structured, what the conventions are, and what workflows to follow when ingesting sources, answering questions, or maintaining the wiki. This is the key configuration file — it's what makes the LLM a disciplined wiki maintainer rather than a generic chatbot. You and the LLM co-evolve this over time as you figure out what works for your domain.

## Operations

**Ingest.** You drop a new source into the raw collection and tell the LLM to process it. An example flow: the LLM reads the source, discusses key takeaways with you, writes a summary page in the wiki, updates the index, updates relevant entity and concept pages across the wiki, and appends an entry to the log. A single source might touch 10-15 wiki pages. Personally I prefer to ingest sources one at a time and stay involved — I read the summaries, check the updates, and guide the LLM on what to emphasize. But you could also batch-ingest many sources at once with less supervision. It's up to you to develop the workflow that fits your style and document it in the schema for future sessions.

**Query.** You ask questions against the wiki. The LLM searches for relevant pages, reads them, and synthesizes an answer with citations. Answers can take different forms depending on the question — a markdown page, a comparison table, a slide deck (Marp), a chart (matplotlib), a canvas. The important insight: **good answers can be filed back into the wiki as new pages.** A comparison you asked for, an analysis, a connection you discovered — these are valuable and shouldn't disappear into chat history. This way your explorations compound in the knowledge base just like ingested sources do.

**Lint.** Periodically, ask the LLM to health-check the wiki. Look for: contradictions between pages, stale claims that newer sources have superseded, orphan pages with no inbound links, important concepts mentioned but lacking their own page, missing cross-references, data gaps that could be filled with a web search. The LLM is good at suggesting new questions to investigate and new sources to look for. This keeps the wiki healthy as it grows.
```

```
## Indexing and logging

Two special files help the LLM (and you) navigate the wiki as it grows. They serve different purposes:

**index.md** is content-oriented. It's a catalog of everything in the wiki — each page listed with a link, a one-line summary, and optionally metadata like date or source count. Organized by category (entities, concepts, sources, etc.). The LLM updates it on every ingest. When answering a query, the LLM reads the index first to find relevant pages, then drills into them. This works surprisingly well at moderate scale (~100 sources, ~hundreds of pages) and avoids the need for embedding-based RAG infrastructure.

**log.md** is chronological. It's an append-only record of what happened and when — ingests, queries, lint passes. A useful tip: if each entry starts with a consistent prefix (e.g. `## [2026-04-02] ingest | Article Title`), the log becomes parseable with simple unix tools — `grep "^## \[" log.md | tail -5` gives you the last 5 entries. The log gives you a timeline of the wiki's evolution and helps the LLM understand what's been done recently.

## Optional: CLI tools

At some point you may want to build small tools that help the LLM operate on the wiki more efficiently. A search engine over the wiki pages is the most obvious one — at small scale the index file is enough, but as the wiki grows you want proper search. [qmd](https://github.com/tobi/qmd) is a good option: it's a local search engine for markdown files with hybrid BM25/vector search and LLM re-ranking, all on-device. It has both a CLI (so the LLM can shell out to it) and an MCP server (so the LLM can use it as a native tool). You could also build something simpler yourself — the LLM can help you vibe-code a naive search script as the need arises.

## Tips and tricks

- **Obsidian Web Clipper** is a browser extension that converts web articles to markdown. Very useful for quickly getting sources into your raw collection.
- **Download images locally.** In Obsidian Settings → Files and links, set "Attachment folder path" to a fixed directory (e.g. `raw/assets/`). Then in Settings → Hotkeys, search for "Download" to find "Download attachments for current file" and bind it to a hotkey (e.g. Ctrl+Shift+D). After clipping an article, hit the hotkey and all images get downloaded to local disk. This is optional but useful — it lets the LLM view and reference images directly instead of relying on URLs that may break. Note that LLMs can't natively read markdown with inline images in one pass — the workaround is to have the LLM read the text first, then view some or all of the referenced images separately to gain additional context. It's a bit clunky but works well enough.
- **Obsidian's graph view** is the best way to see the shape of your wiki — what's connected to what, which pages are hubs, which are orphans.
- **Marp** is a markdown-based slide deck format. Obsidian has a plugin for it. Useful for generating presentations directly from wiki content.
- **Dataview** is an Obsidian plugin that runs queries over page frontmatter. If your LLM adds YAML frontmatter to wiki pages (tags, dates, source counts), Dataview can generate dynamic tables and lists.
- The wiki is just a git repo of markdown files. You get version history, branching, and collaboration for free.

## Why this works

The tedious part of maintaining a knowledge base is not the reading or the thinking — it's the bookkeeping. Updating cross-references, keeping summaries current, noting when new data contradicts old claims, maintaining consistency across dozens of pages. Humans abandon wikis because the maintenance burden grows faster than the value. LLMs don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass. The wiki stays maintained because the cost of maintenance is near zero.

The human's job is to curate sources, direct the analysis, ask good questions, and think about what it all means. The LLM's job is everything else.

The idea is related in spirit to Vannevar Bush's Memex (1945) — a personal, curated knowledge store with associative trails between documents. Bush's vision was closer to this than to what the web became: private, actively curated, with the connections between documents as valuable as the documents themselves. The part he couldn't solve was who does the maintenance. The LLM handles that.

## Note

This document is intentionally abstract. It describes the idea, not a specific implementation. The exact directory structure, the schema conventions, the page formats, the tooling — all of that will depend on your domain, your preferences, and your LLM of choice. Everything mentioned above is optional and modular — pick what's useful, ignore what isn't. For example: your sources might be text-only, so you don't need image handling at all. Your wiki might be small enough that the index file is all you need, no search engine required. You might not care about slide decks and just want markdown pages. You might want a completely different set of output formats. The right way to use this is to share it with your LLM agent and work together to instantiate a version that fits your needs. The document's only job is to communicate the pattern. Your LLM can figure out the rest.
```

### Now you need to help your second brain get info, nobody tells you this part:

****Y****ou don't even need to open Obsidian, point Claude Code at the folder, work from the terminal, and your second brain quietly builds itself in the background. 

Obsidian is just the window you look through when you want to see what's inside.

### What actually goes in a second brain?

Think about everything you consumed in the last year that just disappeared:

****> The book you finished and forgot.****

****> The podcast that changed how you think about something.****

****> Articles saved at 11pm that you never reopened.

> YouTube rabbit holes that taught you more than any course.****

****> Kindle highlights you marked and never looked at again. 

> Research you did before a big decision.

> Old project notes.

> Lessons from things that went wrong.****

All of that is sitting somewhere doing nothing. It belongs in your vault.

No existing material? Open Claude chat and talk for twenty minutes, your work, your goals, what you're building, what you're figuring out. 

Save that conversation as your Memory file, that's enough to make your first session feel like Claude actually knows you.

The vault doesn't need to be complete to be useful. It just needs to be real.

### The operations: what you actually do day to day

****Ingest, y****ou clip an article with the Web Clipper, it lands in your raw sources folder, you tell Claude:

```
claude -p "I just added an article to /raw-sources. 
Read it, extract the key ideas, write a summary page to /wiki/summaries/, 
update index.md with a link and one-line description, and update any 
existing concept pages that this article connects to. 
Show me every file you touched." --allowedTools Bash,Write,Read
```

One article: Claude links 10-15 wiki pages, surfaces unexpected connections, flags contradictions, and logs exactly what changed.

Query: Ask the wiki, claude scans the index, pulls the right pages, and answers with citations. 

Then it saves the best outputs back into the wiki, comparisons, analyses, new connections, so insights don’t vanish in chat and your knowledge base compounds.

Lint: Once a week, run this:

```
claude -p "Read every file in /wiki/. Find: contradictions between pages, 
orphan pages with no inbound links, concepts mentioned repeatedly but 
with no dedicated page, and claims that seem outdated based on newer files 
in /raw-sources/. Write a health report to /wiki/lint-report.md with 
specific fixes." --allowedTools Bash,Write,Read
```

Your knowledge base stays healthy automatically, maintenance stops being your job.

### The morning briefing set it once, runs forever:

```
claude -p "Write a Python script called morning_digest.py that:
1) reads Memory.md and surfaces any open actions due today
2) reads any new files added to /raw-sources in the last 24 hours
3) prints a clean briefing to the terminal.
Then schedule it as a cron job every morning at 7:30am." --allowedTools Bash,Write
```

You set this up once, every morning it runs without you touching anything.

### Process a call transcript and update your entire system:

```
claude -p "Read the transcript in /transcripts/call-today.md.
Extract every decision made, every action item with owner and deadline,
and a 3-bullet summary. Add actions to /Action-Tracker.md, log decisions 
to /Decision-Log.md, and create a client note in /clients/ linking back 
to this transcript." --allowedTools Bash,Write,Read
```

Every decision filed, every action tracked, nothing lost to chat history ever again

### Why almost nobody has this

The reason this isn't everywhere yet is simple: the people who've built it aren't explaining it clearly, and the people who need it don't know it exists.

Most second brain projects die the same death. You start organized. Maintenance piles up, updating tags, keeping cross-references current, reorganizing when the structure evolves. 

****That's extra work on top of a full workload -> you skip it, the system degrades -> u go back to scattered notes. 
****
Six months later you try to rebuild it and the cycle repeats.

Claude breaks that cycle permanently, maintenance is just a command. Reorganizing your entire vault is a prompt, migrating from Notion?

One command processes every exported file, adds the right properties, and restructures everything into your new system.

****The human's job is to curate sources, ask good questions, and think about what it all means. 
****
Claude's job is everything else, the summarizing, cross-referencing, filing, and bookkeeping that makes a knowledge base actually useful over time.

Vannevar Bush described something like this in 1945, a personal, curated knowledge store where the connections between documents are as valuable as the documents themselves. 

He called it the Memex, the part he couldn't solve was who does the maintenance.

Now you know who does it: Build this once -> Use it forever,  and it gets better every single day you add to it.

****That's why it should be illegal.

- Leo****

> Original article: https://x.com/i/article/2041858771123617793

### Article Screenshots

![](https://pbs.twimg.com/amplify_video_thumb/2042212949536755712/img/3wYNHsvcb_ov1PIR.jpg)

![](https://pbs.twimg.com/amplify_video_thumb/2042222353560604672/img/W0Lkb4drfrUf1Qv7.jpg)

---

## Commentary from Other Bookmarks

### @Bober_smart (Bober_smart) - 2026-04-11

> http://1.Download Obsidian → create a new vault (folder)
> http://2.Download Claude Desktop (Claude Code)
> 3.Point Claude to the path of your vault
> 4.Paste the prompt from the article
> 
> > Just 4 steps and 10 minutes of your time
> 
> The face I made when I realized I had been suffering all this time, not knowing such simple things

[View quote tweet](https://x.com/Bober_smart/status/2042952545514008864)

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2042952357831692288/img/gSddeAEBwbZHY-0J.jpg)

[Watch video](https://video.twimg.com/amplify_video/2042952357831692288/vid/avc1/1880x1080/eGAliFHw5W_pJs_r.mp4?tag=21)

*Video - see MEDIA-REVIEW.md*

### @0xCortexl (Cortex) - 2026-05-09

> 22-YEAR-OLD FROM SEOUL BUILT A SECOND BRAIN WITH CLAUDE AND OBSIDIAN AND NOW MAKES $17,000 A MONTH FROM IT
> 
> Every morning at 7:30 AM a cron job fires before he gets out of bed - Claude has already read everything he saved overnight, written summaries for 12–15 articles and updated his daily briefing with open tasks and priority changes from the last 24 hours.
> 
> His Obsidian graph has over 3,400 connected nodes across 6 layers of knowledge, all cross-referenced automatically without him touching a single file manually.
> 
> He packaged the entire setup into a $97 course on Gumroad and sold 175 copies in the first 3 weeks.
> 
> Then launched a $49/month membership for ongoing system updates and hit 280 active subscribers by month 2.
> 
> $17,000 a month from a knowledge system that runs itself, built by a guy who just refused to forget things the normal way.

[View quote tweet](https://x.com/0xCortexl/status/2053229819824136675)

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2053228868484440066/img/f9JJLgl8E7si2VmS.jpg)

[Watch video](https://video.twimg.com/amplify_video/2053228868484440066/vid/avc1/1920x1080/lhb_dPMvNhf6iRMy.mp4?tag=27)

*Video - see MEDIA-REVIEW.md*

