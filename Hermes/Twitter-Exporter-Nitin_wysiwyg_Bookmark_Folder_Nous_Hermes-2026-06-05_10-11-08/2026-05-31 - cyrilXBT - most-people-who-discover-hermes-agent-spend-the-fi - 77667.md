---
title: "Most people who discover Hermes Agent spend the first week confused."
author: "CyrilXBT"
username: "@cyrilXBT"
date: "2026-05-31"
tweet_url: "https://x.com/cyrilXBT/status/2060883609935077667"
tweet_type: "original"
likes: 483
retweets: 52
replies: 22
bookmarks: 1504
views: 320922
has_media: false
extraction_quality: full
article_id: "2060852386651111424"
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# Most people who discover Hermes Agent spend the first week confused.

> **Source:** [@cyrilXBT](https://x.com/cyrilXBT) · 2026-05-31 · 👍 483 · 💬 22 · 🔖 1504 · 👁 320922

> 🔗 [View tweet on X](https://x.com/cyrilXBT/status/2060883609935077667)

## Article Content

Most people who discover Hermes Agent spend the first week confused.

Not because Hermes is complicated.

Because nobody has written the complete guide that takes you from zero knowledge to a fully operational autonomous agent system in one sitting.

This is that guide.

By the end of this masterclass you will have installed Hermes, configured your first agent, built your first skill, connected your first MCP server, set up persistent memory, automated your first workflow, and deployed a multi-agent operation that runs without you.

Every section builds on the previous one. Read it in order the first time. Return to specific sections when you need to reference them later.

### Section 1: What Hermes Agent Actually Is

Before you install anything understand what you are building with.

Hermes Agent is an open source autonomous AI agent framework. It is not a chatbot. It is not a wrapper around an existing tool. It is infrastructure for building agents that operate persistently, remember everything across sessions, execute reusable workflows, and run autonomously on a schedule.

The four properties that make Hermes different from every other agent framework:

****Persistent memory.**** Most AI agents forget everything when you close the session. Hermes remembers. Every conversation, every task, every output, every decision is stored in a memory layer that persists indefinitely. The agent you interact with today knows everything that happened in every session before it.

****Skill system.**** Hermes executes reusable workflow files called skills. You write a skill once as a plain Markdown file describing what the agent should do. Every subsequent run calls that skill without rebuilding the logic. Your operation gets faster and more consistent every skill you add.

****Scheduled automation.**** Hermes runs on a configurable schedule without you initiating anything. Morning research briefs. Nightly content processing. Hourly source monitoring. All of it fires automatically at the times you configure.

****MCP integration.**** Hermes connects to Model Context Protocol servers that give it access to real tools. File systems. Databases. Web search. APIs. External services. Every MCP connection transforms Hermes from a language model into an agent that acts on the real world.

These four properties together produce something qualitatively different from any individual AI interaction.

A Hermes agent is not a tool you use.

It is a system that operates.

### Section 2: Installation and Initial Setup

****Prerequisites:****

Node.js version 18 or higher. Git. A terminal you are comfortable using.

Verify your Node.js version:

node --version

If you need to install or update Node.js visit [nodejs.org](https://x.com//nodejs.org)

 and download the current LTS version.

****Install Hermes:****

git clone [https://github.com/hermes-agent/hermes](https://github.com/hermes-agent/hermes)

cd hermes
npm install

****Configure your environment:****

cp .env.example .env

Open the .env file and configure your model provider:

# Primary model configuration
MODEL_PROVIDER=anthropic
MODEL_NAME=claude-opus-4-5
ANTHROPIC_API_KEY=your-anthropic-api-key

# Alternative: Use DeepSeek for free operation
# MODEL_PROVIDER=deepseek
# MODEL_NAME=deepseek-chat
# DEEPSEEK_API_KEY=your-deepseek-key

# Memory configuration
MEMORY_BACKEND=sqlite
MEMORY_PATH=./data/memory.db

# Scheduler
ENABLE_SCHEDULER=true
SCHEDULER_TIMEZONE=America/New_York

# Logging
LOG_LEVEL=info
LOG_PATH=./logs/hermes.log

****Start Hermes:****

npm run start

You should see output confirming Hermes is running:

[Hermes] Memory backend: SQLite initialized
[Hermes] Skill directory: ./skills loaded
[Hermes] Scheduler: enabled
[Hermes] Agent ready. Awaiting instructions.

Hermes is now running with persistent memory and the scheduler active.

****Verify the installation:****

Type your first message:

Hello. What do you know about yourself?

Hermes should respond describing its configuration, memory status, and available skills.

### Section 3: Understanding the File Architecture

Before building anything understand where everything lives.

hermes/
    skills/
        [your-skill-name].md
    data/
        memory.db
        processed/
        outputs/
    logs/
        hermes.log
    config/
        sources.json
        schedule.json
    CLAUDE.md
    .env
    package.json

****skills/**** is where every workflow you build lives. Each skill is a Markdown file. Hermes reads these files and executes the workflows they describe.

****data/**** is where Hermes stores everything it processes. memory.db is the SQLite database that powers persistent memory. processed/ holds items that have been handled. outputs/ holds generated content.

****logs/**** contains operation logs. Check hermes.log when something is not working as expected.

****config/**** holds your configuration files. sources.json defines your content sources. schedule.json defines when automated workflows run.

****CLAUDE.md**** is the most important file in the entire installation. It tells Hermes everything about who you are, what you do, and how you want it to operate. We build this in Section 4.

### Section 4: Writing Your CLAUDE.md

The CLAUDE.md is the operating constitution of your Hermes agent.

Every skill reads it before executing. Every automated workflow uses it for context. Every output is shaped by it.

A poorly written CLAUDE.md produces generic outputs.

A precisely written CLAUDE.md produces outputs that feel like they were made by someone who knows your operation inside out.

Here is the complete template:

# Hermes Agent — CLAUDE.md

## Identity
Name: [YOUR NAME OR BRAND]
Role: [WHAT YOU DO]
Primary platform: [WHERE YOU PUBLISH]
Audience: [WHO YOU SERVE]

## Content and Work Focus
Primary topics: [LIST YOUR MAIN TOPICS]
Content formats: [WHAT YOU CREATE]
Voice and tone: [HOW YOU COMMUNICATE]
What you never do: [SPECIFIC THINGS TO AVOID]

## Current Projects
[PROJECT 1]: [ONE SENTENCE DESCRIPTION]
Status: [ACTIVE/PENDING/COMPLETE]
Next action: [SPECIFIC NEXT STEP]

[PROJECT 2]: [ONE SENTENCE DESCRIPTION]
Status: [ACTIVE/PENDING/COMPLETE]
Next action: [SPECIFIC NEXT STEP]

## Current Priorities
1. [MOST IMPORTANT THING RIGHT NOW]
2. [SECOND MOST IMPORTANT]
3. [THIRD MOST IMPORTANT]

## Content Standards
A great output: [SPECIFIC DESCRIPTION]
An acceptable output: [MINIMUM THRESHOLD]
A rejected output: [WHAT FAILS]

## Sources I Trust
[LIST SPECIFIC PUBLICATIONS, CHANNELS, PEOPLE]

## What I Specifically Do Not Want
[LIST TOPICS, FORMATS, OR APPROACHES TO AVOID]

## Memory Rules
- Store every significant decision with reasoning
- Track all content published with performance notes
- Remember source quality assessments
- Never repeat content from the same source within 72 hours

## Output Rules
- Save all generated content to data/outputs/
- Date stamp every file: YYYY-MM-DD-[type]-[topic].md
- Log all operations to logs/hermes.log
- Flag anything requiring human review before posting

## Update Schedule
Review and update this file: [YOUR SCHEDULE]

Spend 30 minutes filling this out completely before building any skills. Everything downstream depends on the quality of this document.

### Section 5: Building Your First Skill

A skill is a plain text Markdown file that describes a workflow Hermes executes.

The skill format has four required sections:

# skill-name

## Purpose
[One sentence describing what this skill does]

## Trigger
[How to invoke it — manually or on a schedule]

## Process
[Step-by-step instructions for what Hermes does]

## Output
[What the skill produces and where it saves it]

Let us build your first real skill: a morning briefing that reads your configured sources and delivers a structured summary.

Create skills/morning-briefing.md:

# morning-briefing

## Purpose
Generate a structured morning intelligence briefing 
from all configured sources and save it to the 
outputs folder.

## Trigger
Scheduled daily at 6:00 AM.
Manual: "Run morning briefing" or "Generate my briefing"

## Process
1. Read CLAUDE.md for full context on who I am 
   and what topics matter to me.

2. Read config/sources.json for all configured sources.

3. For each source in my primary topics list:
   Search for significant developments from the 
   last 24 hours using web search.
   
   Filter results using these criteria:
   INCLUDE: New announcements, significant updates, 
   research findings, strategic moves by key players
   EXCLUDE: Rehashed content, opinion pieces without 
   new information, anything I would classify as noise 
   based on my CLAUDE.md preferences

4. Check memory for anything relevant from 
   previous sessions that connects to today's news.

5. Generate the briefing in this format:

---
# Morning Brief — [DATE]

## THE ONE THING
[Most important development today and why it 
matters specifically for my work]

## WHAT HAPPENED
[3-7 significant items, each 2-3 sentences]

## WHAT TO WATCH
[1-2 developing situations worth monitoring]

## FROM MEMORY
[Any relevant connection to something stored 
in previous sessions]

## TODAY'S FOCUS
[Single recommended priority based on briefing]
---

6. Save briefing to:
   data/outputs/[DATE]-morning-briefing.md

7. Store summary in memory with tag: daily-brief

## Output
Structured briefing file in outputs folder.
Memory entry tagged: daily-brief
Log entry in hermes.log

Test your first skill:

Run morning briefing

Watch Hermes execute each step, search for information, and generate your first automated briefing.

### Section 6: The Memory System

Memory is what transforms Hermes from a capable tool into a compounding system.

Understanding how memory works lets you design skills that get progressively smarter over time.

****How Hermes stores memory:****

Every significant operation creates a memory entry in the SQLite database. Each entry has:

- Content: what was stored
- Tags: categories for retrieval
- Timestamp: when it was created
- Source: which skill created it
- Relevance score: updated based on how often it is retrieved

****How Hermes retrieves memory:****

When any skill runs Hermes automatically searches memory for relevant context before executing. The search uses semantic similarity so related concepts surface even when exact keywords do not match.

****Designing skills for memory:****

Include explicit memory instructions in every skill:

## Memory Instructions

STORE after completion:
- Key findings tagged: [relevant-tags]
- Decisions made tagged: decision
- Outputs produced tagged: output

RETRIEVE before starting:
- Previous runs of this skill
- Any entries tagged: [relevant-tags]
- Decisions that affect this workflow

****Manual memory operations:****

Store this in memory: [information] — tag it as [tag]
What do you remember about [topic]?
Show me all memory entries from the last 7 days
What decisions have been stored?

****The memory compound effect:****

A Hermes agent with one week of memory is useful.

A Hermes agent with three months of memory is a different category of tool.

After three months of daily operation Hermes has read hundreds of sources, processed thousands of pieces of content, tracked dozens of decisions, and built a detailed picture of what works and what does not in your specific operation.

Every new task benefits from that accumulated context.

### Section 7: Connecting MCP Servers

MCP servers transform Hermes from an agent that reasons about the world into an agent that acts on it.

Each MCP connection gives Hermes access to a real tool. File systems. Web search. Databases. APIs. External services.

****Installing the core MCP servers:****

# Filesystem MCP — read and write local files
npm install -g [@modelcontextprotocol/server-filesystem](https://x.com/@modelcontextprotocol/server-filesystem)

# Web search — real-time Brave Search
npm install -g [@modelcontextprotocol/server-brave-search](https://x.com/@modelcontextprotocol/server-brave-search)

# GitHub — repository access
npm install -g [@modelcontextprotocol/server-github](https://x.com/@modelcontextprotocol/server-github)

# Puppeteer — browser automation
npm install -g [@modelcontextprotocol/server-puppeteer](https://x.com/@modelcontextprotocol/server-puppeteer)

****Configure MCP connections in your .env:****

# Filesystem
MCP_FILESYSTEM_PATH=/path/to/your/working/directory

# Brave Search
MCP_BRAVE_API_KEY=your-brave-search-api-key

# GitHub
MCP_GITHUB_TOKEN=your-github-personal-access-token

# Puppeteer
MCP_PUPPETEER_HEADLESS=true

****The Filesystem MCP:****

The most immediately valuable connection. Gives Hermes direct read and write access to your local files.

Once connected Hermes can:

Read files you specify in skill instructions. Write outputs directly to folders on your system. Update files based on new information. Monitor folders for new content.

Skills that use the filesystem MCP:

## Process
1. Read the file at [PATH] for context
2. Process the content
3. Write the output to [OUTPUT PATH]
4. Update the index file at [INDEX PATH]

****The Brave Search MCP:****

Gives Hermes access to real-time web search. Without this Hermes can only reason about information up to its training cutoff. With it Hermes searches the live web for current information.

Every research, monitoring, and briefing skill benefits from Brave Search.

Get your free Brave Search API key at [brave.com/search/api](https://x.com//brave.com/search/api)

. The free tier allows 2,000 queries per month.

****The GitHub MCP:****

Gives Hermes access to GitHub repositories. It can read code, check trending repos, monitor repositories you follow, and track releases.

Valuable for: developer tools content, open source monitoring, technical research, repository analysis.

****Verifying MCP connections:****

What MCP servers are currently connected?
List all available tools from connected servers.

Hermes should list every connected server and the tools each one provides.

### Section 8: The Scheduler System

The scheduler transforms Hermes from a tool you use into a system that operates.

Without the scheduler: Hermes does what you ask when you ask.

With the scheduler: Hermes operates continuously whether you are involved or not.

****Configure your schedule:****

Create config/schedule.json:

{
  "schedules": [
    {
      "skill": "morning-briefing",
      "cron": "0 6 * * *",
      "description": "Daily morning briefing at 6AM"
    },
    {
      "skill": "source-monitor",
      "cron": "0 */2 * * *",
      "description": "Check sources every 2 hours"
    },
    {
      "skill": "content-processor",
      "cron": "0 20 * * *",
      "description": "Process captured content at 8PM"
    },
    {
      "skill": "weekly-review",
      "cron": "0 19 * * 0",
      "description": "Weekly review every Sunday at 7PM"
    },
    {
      "skill": "memory-consolidation",
      "cron": "0 23 * * *",
      "description": "Consolidate memory entries at 11PM"
    }
  ]
}

****Cron expression reference:****

0 6 * * *      → 6AM every day
0 */2 * * *    → Every 2 hours
0 20 * * 1-5   → 8PM Monday through Friday
0 19 * * 0     → 7PM every Sunday
0 23 * * *     → 11PM every day

****The five scheduled workflows every Hermes operation needs:****

Morning briefing: 6AM daily. Reads sources. Generates intelligence brief. Sets the day's focus.

Source monitor: Every 2 hours. Checks configured sources for new content. Adds to processing queue.

Content processor: 8PM daily. Processes everything captured during the day. Generates outputs. Updates memory.

Weekly review: Sunday 7PM. Synthesizes the week's activity. Identifies patterns. Generates insights.

Memory consolidation: 11PM daily. Reviews new memory entries. Removes duplicates. Updates relevance scores.

****Monitoring scheduled execution:****

Show me scheduled operations for today
What ran in the last 24 hours?
Show me the execution log

### Section 9: Building a Complete Content Operation

This section walks through building a complete automated content operation with Hermes. By the end you will have a system that monitors sources, identifies viral content opportunities, generates drafts, and manages a publishing queue automatically.

****Step 1: Configure your sources****

Create config/sources.json:

{
  "sources": [
    {
      "name": "Anthropic Blog",
      "type": "rss",
      "url": "[https://anthropic.com/news/rss](https://anthropic.com/news/rss)

",
      "priority": "critical",
      "check_interval": "1h"
    },
    {
      "name": "GitHub Trending AI",
      "type": "web",
      "url": "[https://github.com/trending/python?since=daily](https://github.com/trending/python?since=daily)

",
      "priority": "high",
      "check_interval": "4h"
    },
    {
      "name": "HackerNews AI",
      "type": "web",
      "url": "[https://news.ycombinator.com](https://news.ycombinator.com)

",
      "priority": "medium",
      "check_interval": "2h"
    }
  ]
}

****Step 2: Build the content opportunity identifier****

Create skills/content-opportunity.md:

# content-opportunity

## Purpose
Scan all sources for content opportunities worth 
creating and add them to the content queue.

## Trigger
Runs after source-monitor detects new content.
Manual: "Find content opportunities"

## Process
1. Read CLAUDE.md for my content pillars and audience.

2. Read all items flagged as new by source-monitor 
   from memory tagged: source-monitor-new.

3. For each new item evaluate:

   VIRAL POTENTIAL SCORE (1-10):
   - Is this something my specific audience cares about?
   - Is this genuinely new information or a rehash?
   - Does this connect to any of my current content pillars?
   - Is there a unique angle I can take that others have not?

   Only items scoring 7 or above qualify as opportunities.

4. For each qualified opportunity create an entry in 
   data/outputs/content-queue.md with:
   - Source and link
   - Why this is an opportunity
   - Suggested content angle
   - Suggested format (tweet/thread/article/video)
   - Priority: urgent/high/medium

5. Store all opportunities in memory tagged: content-queue

## Output
Updated content-queue.md file.
Memory entries tagged: content-queue

****Step 3: Build the draft generator****

Create skills/draft-generator.md:

# draft-generator

## Purpose
Generate content drafts for items in the 
content queue based on their priority.

## Trigger
Runs daily at 2PM.
Manual: "Generate drafts" or "Draft the top 3 items"

## Process
1. Read CLAUDE.md for my voice, tone, and content rules.

2. Read data/outputs/content-queue.md for pending items.

3. Select the top 3 items by priority score.

4. For each selected item:

   a. Research the topic using web search to ensure 
      the information is current and accurate
   
   b. Check memory for any previous coverage of 
      this topic to avoid repetition
   
   c. Generate the draft in the specified format:
   
      For TWEETS:
      Follow the cyrilXBT format:
      - Declaration hook in ALL CAPS
      - Short punchy lines
      - Every sentence on its own line
      - Bookmark this + Follow CTA at end
      
      For THREADS:
      - Hook tweet
      - 5-8 body tweets with specific details
      - CTA closer
      
      For ARTICLES:
      - Strong hook paragraph
      - Problem statement
      - Solution walkthrough
      - Actionable steps
      - CTA to follow

5. Save each draft to:
   data/outputs/drafts/[DATE]-[FORMAT]-[TOPIC].md

6. Update content-queue.md marking items as drafted.

7. Store draft summaries in memory tagged: draft-generated

## Output
Draft files in data/outputs/drafts/
Updated content-queue.md
Memory entries tagged: draft-generated

****Step 4: Build the performance tracker****

Create skills/performance-tracker.md:

# performance-tracker

## Purpose
Track content performance and use the data to 
improve future content decisions.

## Trigger
Manual: "Log performance for [content] — [metrics]"
Weekly review reads all performance logs.

## Process
1. When triggered with performance data:
   - Store the metrics in memory with the content reference
   - Tag: performance-log
   
2. Identify patterns:
   - Which topics performed best this week?
   - Which formats had highest engagement?
   - Which sources produced the most viral content?
   
3. Update CLAUDE.md content priorities based on 
   performance data if patterns are clear.

4. Generate weekly performance report on Sundays.

## Output
Memory entries tagged: performance-log
Weekly performance report in outputs folder

### Section 10: Multi-Agent Operations

Single agent Hermes is powerful. Multi-agent Hermes is a different category of capability.

Multi-agent operation means multiple specialized Hermes instances each handling one domain of your operation, sharing memory, and coordinating outputs.

****The four-agent content operation:****

****Research Agent:**** Monitors sources, identifies opportunities, conducts deep research. Only reads. Never creates.

****Production Agent:**** Takes research outputs and generates content drafts. Only creates. Never publishes.

****Quality Agent:**** Reviews production outputs against standards. Approves or returns for revision. Never creates or publishes.

****Distribution Agent:**** Takes approved outputs and manages publishing schedule. Only publishes. Never creates.

****Setting up the multi-agent configuration:****

Create separate CLAUDE.md files for each agent:

hermes-research/
    CLAUDE.md  ← Research agent constitution
    skills/    ← Research-only skills

hermes-production/
    CLAUDE.md  ← Production agent constitution
    skills/    ← Production-only skills

hermes-quality/
    CLAUDE.md  ← Quality agent constitution
    skills/    ← Quality-only skills

hermes-distribution/
    CLAUDE.md  ← Distribution agent constitution
    skills/    ← Distribution-only skills

****The shared memory layer:****

Configure all four agents to point at the same SQLite database:

MEMORY_PATH=/shared/hermes-memory.db

This means every agent reads every other agent's outputs. Research outputs are visible to production. Production outputs are visible to quality. Quality approvals are visible to distribution.

****The handoff protocol:****

Each agent signals readiness for handoff through memory tags:

Research agent completes work → stores output tagged: ready-for-production

Production agent picks up tagged items → stores output tagged: ready-for-quality

Quality agent approves → stores output tagged: ready-for-distribution

Distribution agent publishes → stores result tagged: published

****The orchestrator skill:****

Create one master orchestrator skill that monitors the entire pipeline:

# pipeline-orchestrator

## Purpose
Monitor all four agents and ensure smooth 
handoffs between pipeline stages.

## Trigger
Runs every 30 minutes.

## Process
1. Check for items tagged: ready-for-production
   If found: alert production agent
   
2. Check for items tagged: ready-for-quality
   If found: alert quality agent
   
3. Check for items tagged: ready-for-distribution
   If found: alert distribution agent
   
4. Check for items in any stage longer than 4 hours
   If found: flag as stalled and alert for review
   
5. Generate pipeline status report every 4 hours

## Output
Pipeline status in memory tagged: pipeline-status
Alerts for stalled items
Hourly operation log

### Section 11: Advanced Skill Patterns

As your Hermes operation matures you will encounter situations the basic skill format does not cover. These advanced patterns handle the most common complex scenarios.

****Pattern 1: Conditional Execution****

Skills that take different paths based on conditions:

## Process
1. Check condition: [WHAT TO CHECK]

2. IF [CONDITION A]:
   Execute path A:
   [STEPS FOR PATH A]
   
   IF [CONDITION B]:
   Execute path B:
   [STEPS FOR PATH B]
   
   IF NEITHER:
   Flag for human review and log the ambiguous case.

****Pattern 2: Retry Logic****

Skills that should retry on failure:

## Process
For each item attempt the following up to 3 times:

1. Try: [PRIMARY APPROACH]
   If successful: proceed to output
   If failed: log the error and try alternative

2. Alternative: [BACKUP APPROACH]
   If successful: proceed to output with note 
   that alternative was used
   If failed: mark as failed and flag for review

Never proceed with incomplete or uncertain output.

****Pattern 3: Quality Gates****

Skills that enforce standards before producing output:

## Quality Gate
Before saving any output evaluate against these criteria:

PASS criteria (all must be true):
- [CRITERION 1]
- [CRITERION 2]
- [CRITERION 3]

If PASS: save output and log success
If FAIL: identify which criteria failed, attempt 
revision, re-evaluate. Maximum 2 revision attempts.
If still failing after 2 attempts: save to 
review-needed/ folder with failure notes.

****Pattern 4: Memory-Informed Execution****

Skills that get smarter with each run:

## Memory-Informed Process
Before executing retrieve:
- All previous runs of this skill from memory
- Performance data tagged: [relevant-tag]
- Any pattern notes stored from previous runs

Use retrieved context to:
- Avoid approaches that previously failed
- Prioritize approaches that previously succeeded
- Apply any pattern insights to current execution

After executing store:
- What approach was used
- Whether it succeeded
- Any new pattern observed
- Tagged: [skill-name]-learning

### Section 12: Troubleshooting Common Issues

Every Hermes operation encounters problems in the first few weeks. These are the most common issues and how to fix them.

****Issue: Hermes is not executing scheduled skills****

Check the scheduler is enabled in your .env:

ENABLE_SCHEDULER=true

Verify your cron expressions are valid using [crontab.guru](https://x.com//crontab.guru)

.

Check the hermes.log for scheduler errors:

tail -f logs/hermes.log

****Issue: Memory is not persisting between sessions****

Verify the memory database path is correct:

MEMORY_PATH=./data/memory.db

Check file permissions on the data directory:

ls -la data/

The hermes process needs write access to this directory.

****Issue: MCP servers are not connecting****

Verify the MCP server is installed globally:

which npx
npx [@modelcontextprotocol/server-filesystem](https://x.com/@modelcontextprotocol/server-filesystem)

 --help

Check your API keys are correctly set in .env with no trailing spaces.

Restart Hermes after changing MCP configuration.

****Issue: Skill outputs are low quality****

The most common cause is a vague CLAUDE.md. Return to Section 4 and add more specific detail to every section.

Also check that the skill's Process section is specific enough. Vague instructions produce vague outputs.

****Issue: Hermes is using outdated information****

Verify the Brave Search MCP is connected:

What MCP servers are connected?

If Brave Search is not listed check your API key and reinstall the MCP server.

****Issue: Skills are running but not saving outputs****

Check the Filesystem MCP is connected and pointing at the correct path.

Verify the output paths in your skill files are relative to the working directory Hermes is running in.

### Section 13: Measuring and Improving Your Operation

A Hermes operation that does not improve over time is not using its memory system correctly.

****The weekly review skill:****

Create skills/weekly-review.md:

# weekly-review

## Purpose
Synthesize the week's operation and identify 
improvements for the following week.

## Trigger
Every Sunday at 7PM.
Manual: "Run weekly review"

## Process
1. Read all memory entries from the past 7 days.

2. Analyze skill performance:
   - Which skills ran without issues?
   - Which skills encountered errors?
   - Which skills produced the best outputs?
   - Which skills need improvement?

3. Analyze content performance (if logged):
   - Which content performed best?
   - What patterns appear in high performers?
   - What topics should be prioritized next week?

4. Analyze memory quality:
   - Are memory entries being created correctly?
   - Are retrieval results relevant when skills run?
   - Are there gaps in what is being stored?

5. Generate improvement recommendations:
   - One skill to improve this week
   - One new skill to build this week
   - One process to streamline
   - One topic to prioritize in content

6. Update CLAUDE.md with any confirmed improvements.

## Output
Weekly review report in data/outputs/
CLAUDE.md updates if improvements identified
Memory entry tagged: weekly-review

****The metrics that matter:****

Skill reliability rate: what percentage of scheduled skills run without errors. Target above 95%.

Memory retrieval relevance: when memory is retrieved for a skill is it actually relevant. Review weekly.

Output quality consistency: are outputs consistently meeting your standards. Track manually.

Operation coverage: what percentage of your intended workflows are actually automated. Expand toward 100% over time.

### Section 14: The 90-Day Build Plan

Building a mature Hermes operation takes 90 days of consistent iteration.

****Days 1 to 7: Foundation****

Install Hermes. Write your CLAUDE.md. Build the morning briefing skill. Connect the Filesystem and Brave Search MCP servers. Run your first scheduled briefing.

Goal: Hermes is running reliably and producing one useful output daily.

****Days 8 to 30: Core Skills****

Build five to eight core skills for your specific operation. Configure the scheduler for all five standard automated workflows. Identify the first MCP server specific to your domain.

Goal: Hermes is automating 30% of your repeating knowledge work.

****Days 31 to 60: Optimization****

Review memory quality and improve storage conventions. Refine skill outputs based on three to four weeks of results. Build your first advanced skills using conditional execution and quality gates.

Goal: Hermes outputs are consistently meeting quality standards without manual revision.

****Days 61 to 90: Multi-Agent****

If your operation justifies it, design your multi-agent architecture. Build the specialist agent CLAUDE.md files. Configure the shared memory layer. Deploy the orchestrator skill.

Goal: Hermes is running a coordinated multi-agent operation handling your most complex workflows end to end.

### The Compounding Reality

The builders who start their Hermes operation today and run it consistently for 90 days will have something that cannot be replicated quickly.

Not because the technology is hard to access.

Because the memory layer that accumulates over 90 days of consistent operation is not something you can shortcut.

The Hermes agent at day 90 knows your operation. It knows which sources produce the best content for your audience. It knows which approaches have worked and which have failed. It knows your voice, your standards, and your priorities because it has executed against them hundreds of times.

That accumulated intelligence is the moat.

Every day you run the operation the moat gets deeper.

Every day you wait to start is a day of compound intelligence you never get back.

Build the foundation this weekend.

The skills take an afternoon to write.

The memory starts accumulating from the first session.

The compounding starts from the first automated workflow that runs without you.

Follow [@cyrilXBT](https://x.com/@cyrilXBT)

 for every Hermes Agent build, skill template, and multi-agent architecture that makes autonomous AI operations actually work.

> 📄 Original article URL: https://x.com/i/article/2060852386651111424

---

## Commentary from Other Bookmarks

### @cyrilXBT (CyrilXBT) — 2026-05-31

> Hermes Agent. Zero to full autonomous operation. One complete course.
> 
> Installation. Skills. Memory. MCP. Scheduler. Multi-agent.
> 
> Works while you sleep.
> 
> The people who build this system will never manually operate a content, research, or business workflow again.
> 
> The compounding starts from the first automated skill that runs.
> 
> Read this and bookmark it now.

[→ View quote tweet](https://x.com/cyrilXBT/status/2060914969605189808)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

