---
title: "****Most people use AI like a slightly smarter Google.****"
author: "Mr. Buzzoni"
username: "@polydao"
date: "2026-04-09"
tweet_url: "https://x.com/polydao/status/2042203352054771748"
tweet_type: "original"
likes: 658
retweets: 74
replies_count: 23
bookmarks: 2397
views: 394564
has_media: false
article_id: "2040467358272155648"
tags: ["twitter-bookmark", "obsidian", "claude", "mcp", "llm", "ai-tools"]
---

# ****Most people use AI like a slightly smarter Google.****

> **Source:** [@polydao](https://x.com/polydao) - 2026-04-09 - Likes: 658 - Bookmarks: 2397 - Views: 394564

> [View on X](https://x.com/polydao/status/2042203352054771748)

## Article Content

****Most people use AI like a slightly smarter Google.****

- Ask a question, get an answer, close the tab, forget everything
- Meanwhile, a small group of people is quietly building ****self-improving knowledge bases**** that compound every week
- And those people will outcompete everyone else in research, products, and careers

> This article shows you exactly how to build one - using Obsidian, Claude Code, Skills, and plain markdown. No PhD required. Just a system you can set up this weekend.

https://x.com/polydao/article/2042203352054771748/media/2040927323994611713### What You're Actually Building

> Forget "taking notes". You're building a ****living wiki**** that an LLM writes and maintains for you in the background.

The idea comes from Andrej Karpathy (ex-OpenAI, Tesla AI) who recently shared that a large fraction of his LLM usage has shifted - less into writing code, more into ****manipulating knowledge stored as markdown files****.

****Here's the full loop:****

- You dump raw data (articles, papers, repos, transcripts, images) into a raw/ folder
- An LLM compiles that into a structured wiki in wiki/ - markdown files with concepts, backlinks, summaries
- You view and navigate it in ****Obsidian**** with graph view
- You ask complex questions - the LLM reads your wiki and writes answers as new files
- Periodically, an LLM "health check" cleans inconsistencies and proposes new articles
- Every query ****files back**** into the wiki, making it smarter over time

> ****The mental shift: LLM as compiler and librarian - not chatbot.****

### Step 1 - Make Capture Stupidly Easy

If saving info is annoying, the system dies on day one. So start here.

https://x.com/polydao/article/2042203352054771748/media/2040927796927795200****What to install:****

- [Obsidian](https://obsidian.md/)

 - free, local-first, markdown-based knowledge editor
- [Obsidian Web Clipper](https://obsidian.md/clipper)

 - browser extension that saves any web page into your vault as clean .md with URL, title, date, and tags
- ****Create three folders in your vault:****
raw/ - all source material drops here
wiki/ - compiled knowledge lives here
reports/ - your outputs (answers, essays, slide decks)

> One extra trick: bind a hotkey in Obsidian to ****download all images**** for the current note locally - so your LLM can reference them without hitting external URLs.

Your only job right now: any time you see something interesting, ****clip it to raw/.**** Don't organize. Don't rename. Just capture.

### Step 2 - Let the LLM Write Your Wiki For You

Here's where most "note-taking systems" fall apart: the human has to do all the organizing. In this system, the human doesn't.

https://x.com/polydao/article/2042203352054771748/media/2040929772595736576The LLM scans raw/ and produces or updates pages in wiki/. Each important concept gets its own .md file with:

- A short definition and key insights
- Links back to the original sources in raw/
- Backlinks to related concepts
- Index pages listing key subtopics (e.g. RAG.md, prediction-markets.md, LLM-architectures.md)

You barely touch wiki/ manually. ****The LLM owns it.****

### Step 3 - Obsidian Is Your Second Brain IDE

Don't think of Obsidian as "a markdown editor". In this workflow, it's your ****knowledge IDE****.

Why Obsidian works:

- ****Backlinks**** - see everywhere a concept is referenced across the entire vault
- ****Graph view**** - spot clusters of knowledge and isolated nodes (= gaps you haven't filled yet)
- ****Dataview plugin**** - query your notes like a database
- ****Marp plugin**** - render a markdown file directly as a presentation deck

> Karpathy's key observation: ****the human mostly reads, the LLM mostly writes.**** You browse, make small edits, and ask new questions. You don't hand-craft wiki pages like it's 2008.

![](https://pbs.twimg.com/amplify_video_thumb/2040931159677313024/img/M1LIhCBgzV_W42kx.jpg)

### Step 4 - Q&A on Top of Your Own Knowledge Graph

Once your wiki reaches ~50-100 articles, the real value kicks in.

****Instead of asking "Explain prediction market arbitrage" in a stateless chat, you ask:****

> "Using only my wiki, explain the key edge strategies for prediction market traders based on everything I've researched so far."

****Behind the scenes your agent:****

1. Locates the relevant markdown files in wiki/
2. Has the LLM read them end-to-end (modern 1M-token context windows make this viable at personal scale)
3. Writes a ****new markdown report**** into reports/, with links back to the source concepts it used

Every serious question becomes a ****new permanent asset in your vault**** instead of disappearing into chat history.

https://x.com/polydao/article/2042203352054771748/media/2040932432883363840### Step 5 - Never Answer in Chat, Always Answer in Files

One habit that 10x-es the ROI of this system: ****force the LLM to answer as files****, not as text in a UI.

****Great output formats:****

- Markdown reports in reports/ - your best thinking, saved and searchable
- ****Marp slide decks**** - .md files that render into full presentation slides (great for pitches and syncs)
- Plots and diagrams as .png in images/, embedded inline into wiki pages

****Then you:****

- Link the report from the relevant concept pages
- Reuse it as source material for future queries
- Push everything to Git for version control and history

****Your queries literally compound into better future answers.****

https://x.com/polydao/article/2042203352054771748/media/2040934637930004480### Step 6 - LLM Health Checks (This Part Everyone Skips)

> Most people never think to use an LLM to ****clean and refactor knowledge**** - only to add it. Big mistake.

****Karpathy runs periodic "knowledge linting" passes where an LLM scans for:****

- Conflicting statements about the same concept across different notes
- Entities mentioned frequently but lacking a dedicated page
- Near-duplicate pages that should be merged
- Claims that look unsourced or numerically inconsistent
- New article candidates suggested by emerging connection patterns

You can wrap this into a single weekly command. Over time, your wiki drifts toward ****higher integrity and less chaos**** with zero manual bookkeeping.

### Where Claude Code + Skills Make This 10x Better

> So how does ****Claude Code**** actually plug into all of this?

****Claude Code is built for exactly this kind of system:****

- It runs inside a real ****filesystem environment**** - can read and write markdown, run bash and scripts
- It supports ****Skills**** - reusable workflows packaged as directories with a SKILL.md plus optional scripts and resources

****Here's a starter set of Skills to build for your second brain:****

https://x.com/polydao/article/2042203352054771748/media/2040942386562420736Skills can bundle extra markdown instructions, scripts, and reference files - you encode your personal style and domain preferences once, and reuse them across Claude apps, Claude Code, and the API.

****You write the playbook once. Claude executes it on demand.****

### Why This Destroys Stateless "New Chat" Usage

> Standard AI usage is stateless. You ask, get an answer, close the tab. Next session, the model remembers nothing. You start from zero. Forever.

https://x.com/polydao/article/2042203352054771748/media/2040938729322229760An LLM knowledge base turns that into ****stateful, compounding memory****:

- Today's answer becomes tomorrow's context
- Your terminology and frameworks become canonical wiki pages
- Six months of work = a private corpus a model can ingest in a single context window

****Real-world benefits:****

- ****Faster**** - most questions reduce to "generate a report reusing my wiki"
- ****More consistent**** - no random different definitions or notation each session
- ****More valuable at work**** - your second brain is documentation, onboarding material, research archive, and slide factory rolled into one

And all of this lives in ****plain markdown and images**** - not locked inside a closed SaaS. Fully portable. Fully yours.

### Prefer Privacy? Run It Fully Local

Don't want your research going to the cloud? You don't have to.

The whole architecture runs locally with ****Obsidian + Ollama**** (local LLM runner):

- Web pages captured via Clipper into a local vault
- Local LLM reads and updates your wiki - nothing leaves your machine
- Claude Code can layer on top for specific tasks where cloud processing is acceptable

You decide which projects stay fully private and which ones benefit from more powerful cloud models.

https://x.com/polydao/article/2042203352054771748/media/2040940423380963328### Advanced Mode: From Wiki to Finetuned Model

Once your wiki is large enough, another door opens.

> Karpathy points out the natural end state: instead of always relying on massive context windows, you can treat your wiki as a ****finetuning corpus**** - baking your knowledge directly into a model's weights.

- For individuals - your notes, research, code compressed into a "you-flavored" model
- For teams - internal docs, APIs, incident history, design decisions → a finetuned org assistant

Even without finetuning, the compiled wiki pattern already gives massive leverage. Finetuning just compresses and accelerates it.

### Bonus: Connect Claude Directly to Your Obsidian Vault via MCP

Claude Skills + Obsidian is already powerful. But there's one layer most people skip entirely.

> ****MCP for Obsidian**** - an MCP server that lets Claude read and write directly into your vault in real time. Not copy-paste. Not export. Claude literally opens your notes, edits them, creates new files, and inserts content under specific headings - all from the chat window.

3.3k stars on [GitHub](https://github.com/MarkusPfundstein/mcp-obsidian)

. 384 forks. Runs stable.

https://x.com/polydao/article/2042203352054771748/media/2042025456581390336****What Claude can do with your vault:****

- ****list_files_in_vault**** - browse the full structure of your vault
- ****list_files_in_dir**** - explore a specific folder
- ****get_file_contents**** - read any file by name
- ****search**** - find all notes where a topic is mentioned
- ****patch_content**** - insert content under a specific heading or block reference
- ****append_content**** - add content to the end of an existing note
- ****delete_file**** - remove a file or folder

****Real prompts you can use immediately:****

- "Find all notes mentioning Polymarket and give me a short summary of each"
- "Take my last meeting note and create a new file summary.md with an intro I can send by email"
- "Add this idea to my existing research note under the [#Ideas](https://x.com/search?q=%23Ideas&src=hashtag_click)

 heading"

Your Obsidian vault stops being a storage system. It becomes a live workspace Claude actively maintains.

### Setup in 3 steps:

****Step 1. Install the plugin in Obsidian****

Settings → Community Plugins → Browse → search [Local REST API](https://coddingtonbear.github.io/obsidian-local-rest-api/)

 → install and enable. Copy the API key from plugin settings.

https://x.com/polydao/article/2042203352054771748/media/2042023641433464832****Step 2. Open Claude Desktop config****

- ****Mac:**** ~/Library/Application Support/Claude/claude_desktop_config.json
- ****Windows:**** %APPDATA%/Claude/claude_desktop_config.json

****Step 3. Add this block:****

```
{
  "mcp-obsidian": {
    "command": "uvx",
    "args": [
      "mcp-obsidian"
    ],
    "env": {
      "OBSIDIAN_API_KEY": "<your_api_key_here>",
      "OBSIDIAN_HOST": "127.0.0.1",
        "OBSIDIAN_PORT": "27124"
    }
  }
}
```

> Restart Claude. Done.

****Things to know before you start:****

- If Claude can't find uvx - run which uvx in terminal and paste the full path into the "command" field instead of just "uvx"
- Default port is 27124, default host is 127.0.0.1 - no need to change unless you configured otherwise
- Obsidian must be open while using Claude - the Local REST API plugin only runs while the vault is active
- Start your first prompt with "Use Obsidian to..." - this helps Claude immediately understand it should access the vault
- To debug, watch the logs: tail -n 20 -f ~/Library/Logs/Claude/mcp-server-mcp-obsidian.log

### Your One-Weekend MVP Plan

Here's a realistic way to test this in ****2 days****:

****Day 1 - Setup and Capture****

- Install Obsidian, create vault with raw/, wiki/, reports/
- Install Obsidian Web Clipper, set default save location to raw/
- Pick ONE topic you care about (crypto, prediction markets, LLM agents, whatever)
- Clip 20-30 articles into raw/ - don't organize anything, just capture

****Day 2 - Build the Loop****

- In Claude Code, create a basic /kb-compile Skill that reads files in raw/ and asks Claude to create or update concept pages in wiki/
- Run it. Open Obsidian and explore graph view and backlinks
- Create a /kb-report Skill. Ask it one real question about your topic
- Read the output in reports/. Link it from the relevant wiki page

If you do this seriously for just one ongoing research theme, you will feel the difference within a week.

****You're not "just chatting" anymore. You're growing a second brain that writes with you.****

https://x.com/polydao/article/2042203352054771748/media/2040940727103111168### 👇 One Last Thing

- ****Bookmark this**** - seriously, right now, not "later". Most people read → close → never implement. Be the one who does.
- ****Follow**** me [@polydao](https://x.com/@polydao)

 if you want more breakdowns on LLM workflows, Claude Code Skills, prediction markets, and how to turn AI tools into a real edge - in your career, trading, or product.
- ****Drop any reaction**** (like, repost, comment) - it helps the algorithm and tells me this kind of content is worth going deeper on.

> Original article: https://x.com/i/article/2040467358272155648

### Article Screenshots

![](https://pbs.twimg.com/media/HFLUln8WYAEE_Mv?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLVBJwaEAAEMLc?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLW0JsWcAADC7C?format=jpg&name=900x900)

![](https://pbs.twimg.com/amplify_video_thumb/2040931159677313024/img/M1LIhCBgzV_W42kx.jpg)

![](https://pbs.twimg.com/media/HFLZPACWMAAAO8y?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLbPWebwAAkJxP?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLiSYYXUAAt2RE?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLe9gGWsAARpAB?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLggG9bkAAuwrL?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFa7VWnWsAAwJvo?format=png&name=900x900)

![](https://pbs.twimg.com/media/HFa5rsqXYAA3rEP?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HFLgxyabwAAssAX?format=jpg&name=900x900)

---

## Commentary from Other Bookmarks

### @polydao (Mr. Buzzoni) - 2026-05-15

> This beginner guide to Karpathy's LLM Wiki is one of the most useful AI videos i've shared this year
> 
> Karpathy's idea: instead of asking AI questions every time, make it build you a permanent knowledge base that grows smarter over time
> 
> > drop your documents into a folder
> > Claude reads them and builds a structured wiki in Obsidian
> > every time you add a new source, Claude Sonnet updates existing pages and links new ideas
> > ask complex questions - Claude Opus answers from the organized wiki, not raw files
> 
> it's like having a researcher who never forgets and connects dots across everything you've ever given it
> 
> full setup guide is in the video above

[View quote tweet](https://x.com/polydao/status/2055237756318781502)

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2055128381465804800/img/mk0eBqw7-7cE16D9.jpg)

[Watch video](https://video.twimg.com/amplify_video/2055128381465804800/vid/avc1/1920x1080/UryvZ5TPJ0v5nWcS.mp4?tag=27)

*Video - see MEDIA-REVIEW.md*

