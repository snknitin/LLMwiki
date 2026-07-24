---
title: "ZERO EMPLOYEES. ZERO HEADCOUNT. EVERY ROLE COVERED."
author: "YanXbt"
username: "@IBuzovskyi"
date: "2026-07-06"
tweet_url: "https://x.com/IBuzovskyi/status/2074174357220307317"
tweet_type: "original"
likes: 226
retweets: 34
replies: 8
bookmarks: 664
views: 146338
has_media: false
extraction_quality: full
article_id: "2074106701297360897"
tags: ["twitter-bookmark", "obsidian", "claude", "llm", "agents"]
---

# ZERO EMPLOYEES. ZERO HEADCOUNT. EVERY ROLE COVERED.

> **Source:** [@IBuzovskyi](https://x.com/IBuzovskyi) · 2026-07-06 · 👍 226 · 💬 8 · 🔖 664 · 👁 146338

> 🔗 [View tweet on X](https://x.com/IBuzovskyi/status/2074174357220307317)

## Article Content

ZERO EMPLOYEES. ZERO HEADCOUNT. EVERY ROLE COVERED.

A solo founder does not need employees. A solo founder needs systems.

This article maps 8 Hermes Agent profiles that can run your business operations. Each profile is a permanent team member with its own SOUL.md, model, memory, skills, cron jobs, and messaging channel. They coordinate through Kanban. They report to Telegram. They run 24/7 on a VPS.

No payroll. No management. No Slack threads about who's doing what.

One machine. Eight agents. You review results.

All technical details verified against Hermes Agent v0.18.0 documentation.

Subcribe to my Substack for more articles: [https://substack.com/@yanxbt](https://substack.com/@yanxbt)

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074130213156380672

### THE ORG CHART

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074130505797173249

This is the most efficience setup but also more expensive you will also find cheaper versions in this article

each role = one Hermes profile. each profile = isolated memory, skills, and cron. they share ONE Kanban board for coordination.

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074138232510382080

Jill???

### AGENT 1 — CHIEF OF STAFF

****What it replaces:**** a $90K/year operations manager who routes tasks, tracks priorities, and catches everything before it slips.

****What it does:****→ delivers a morning brief every day at 8am → pulls updates from all other 7 agents via Kanban → flags anything blocked or overdue → routes incoming requests to the right agent → maintains the master priority list → escalates decisions that need human judgment

****SOUL.md core:****

> You are Chief of Staff for a solo founder.
> Your job: make sure nothing falls through the cracks.
> Every morning: pull status from all Kanban cards,
> summarize what's done, what's in progress, what's blocked.
> Flag anything that needs founder attention.
> Route new tasks to the right team member by description.
> Never make strategic decisions. Surface information. Escalate choices.
> Tone: brief, structured, no fluff. bullet points only in briefs.

****Model:**** Budget: DeepSeek V4 (routing and summarization, cost-effective). Quality: Claude Sonnet 4.6 (stronger synthesis across 7 agents).

****Skills:****→ kanban_show, kanban_create, kanban_assign, kanban_comment → session_search (to check other agents' recent work)

****MCPs:**** Slack or Telegram (for delivering briefs)

****Cron jobs:****

morning brief (daily 8am):

> "Review all Kanban cards across all profiles.
> Summarize: completed yesterday, in progress today, blocked.
> Flag overdue items. Deliver to Telegram."

priority check (every 3 hours):

> "Check Kanban for any cards blocked more than 4 hours.
> If found, notify founder via Telegram with context."

wakeAgent gate on priority check: skip if no blocked cards.

****Example output (morning brief):****

> DAILY BRIEF: July 4, 2026
> 
> DONE YESTERDAY:
> → Research: competitive analysis on [competitor] complete
> → Content: 3 posts drafted, 1 published
> → DevOps: SSL cert renewed on production
> 
> IN PROGRESS:
> → SDR: 12 new leads qualified, 3 drafts pending review
> → Sales Ops: proposal for [client] in review stage
> → Analyst: Q2 revenue report running
> 
> BLOCKED:
> → Content: cover image for article needs your input
> → Sales Ops: [client] proposal needs pricing approval
> 
> ACTION NEEDED: 2 items require your decision.

****Common mistake:**** giving Chief of Staff permission to make strategic decisions. It should surface and route, not decide. The founder decides.

### AGENT 2 — HEAD OF RESEARCH

****What it replaces:**** a $75K/year research analyst who tracks competitors, monitors trends, and delivers weekly intel reports.

****What it does:****→ monitors competitors daily (pricing, features, hiring) → scans arXiv, Product Hunt, Hacker News for relevant launches → maintains the Obsidian wiki with research findings → delivers weekly research digest → answers ad-hoc research questions from any agent

****SOUL.md core:****

> You are Head of Research for a solo founder.
> Your job: know what's happening in our market before anyone else.
> Track competitors: pricing changes, feature launches, hiring signals.
> Scan sources daily: arXiv, Product Hunt, Hacker News, X, industry newsletters.
> Write findings to the Obsidian wiki using LLM Wiki skill.
> Every source must be verifiable. No speculation presented as fact.
> Flag high-urgency signals immediately via Telegram.
> Weekly digest every Monday 9am.

****Model:**** Budget: DeepSeek V4 (handles web research at low cost). Quality: GPT-5.5 (2M context, strong at broad research and synthesis across many sources).

****Skills:****→ llm-wiki (writes to Obsidian knowledge base) → firecrawl-scrape (reliable web scraping) → web search toolset

****MCPs:**** X search via Grok OAuth (for real-time social signals)

****Cron jobs:****

daily scan (7am):

> "Check competitors [list] for pricing changes,
> new features, blog posts, and hiring signals.
> Check arXiv for papers in [niche].
> Check Product Hunt for relevant launches.
> Write findings to wiki. If anything high-urgency,
> send to Telegram immediately."

wakeAgent gate: skip if no new signals detected.

weekly digest (Monday 9am):

> "Synthesize all research findings from the past 7 days.
> Rank by impact. Deliver a structured digest to Telegram.
> Include: market moves, competitor updates, opportunities."

****Example output (daily signal):****

> HIGH-URGENCY SIGNAL:
> 
> [Competitor] dropped their free tier.
> Pricing page updated 2 hours ago.
> Previous: Free plan with 1,000 API calls.
> Current: No free plan. Lowest tier $29/month.
> 
> Source: [URL]
> Written to wiki: competitors/[name]/pricing-history.md
> 
> Opportunity: their free-tier users need an alternative.
> Consider a targeted post or landing page.

****Common mistake:**** routing research through Opus. GPT-5.5 handles broad web research at a fraction of the cost. Save Opus for synthesis and decision-making in Chief of Staff.

### AGENT 3 — HEAD OF CONTENT

****What it replaces:**** a $65K/year content manager who drafts posts, maintains a content calendar, and handles publishing logistics.

****What it does:****→ drafts posts based on research findings and ideas → maintains content calendar (what publishes when) → runs slop check on every draft → suggests cover image concepts → manages DM templates for comment bait responses

****SOUL.md core:****

> You are Head of Content for a solo founder on X (Twitter).
> Niche: Hermes Agent by Nous Research. English only.
> Voice: tech bro who shipped it at 3 AM.
> Conversational, direct, slightly hyped but grounded.
> Light swearing when natural. Never corporate.
> HERMES AGENT must be the first words of every hook.
> ALL CAPS hooks. Single posts only. No threads.
> No em-dashes. No adverbs. No throat-clearing.
> Every technical claim verifiable against official docs.
> Run Bookmarkability Rubric (target 8+/12) on every draft.

****Model:**** Claude Sonnet 4.6 for both tiers. Writing quality directly affects your reputation. Do not cut here.

****Skills:****→ custom content-writer skill (voice rules, hook patterns, slop filter) → custom bookmarkability-rubric skill

****Cron jobs:****

content calendar check (daily 10am):

> "Check content calendar for today's scheduled post.
> If nothing scheduled: suggest 3 post ideas
> based on this week's research findings from the wiki.
> Deliver to Telegram."

draft review (on-demand, triggered by Kanban):

> When a draft card moves to "review" in Kanban,
> run slop check + bookmarkability rubric.
> Report score and specific issues to Telegram.

****Example output (content calendar check):****

> CONTENT CALENDAR: July 4, 2026
> 
> TODAY: no post scheduled.
> 
> 3 IDEAS BASED ON THIS WEEK'S RESEARCH:
> 
> 1. HERMES AGENT v0.18.0 JUST SHIPPED.
>    angle: completion contracts + /journey + /learn
>    source: wiki entry "v0.18.0-release"
>    bookmarkability estimate: 9/12
> 
> 2. HERMES AGENT MIXTURE OF AGENTS
>    angle: benchmark numbers + preset configs
>    source: wiki entry "moa-benchmarks"
>    bookmarkability estimate: 8/12
> 
> 3. HERMES AGENT + STRIPE PAYMENTS
>    angle: autonomous business operations
>    source: wiki entry "stripe-link-cli"
>    bookmarkability estimate: 10/12
> 
> RECOMMENDATION: option 3. highest bookmark potential.
> draft ready in 20 minutes if approved.

****Common mistake:**** letting the content agent publish directly. Always route through human approval. The agent drafts and checks. You decide what ships.

### AGENT 4 — SDR (SALES DEVELOPMENT REP)

****What it replaces:**** a $55K/year SDR who monitors inbound leads, qualifies them, and drafts initial outreach.

****What it does:****→ monitors inbox for incoming brand deal emails → qualifies leads against your criteria → drafts personalized responses → logs every interaction in the pipeline → flags high-value opportunities immediately

****SOUL.md core:****

> You are SDR for a solo founder.
> Your job: find and qualify inbound leads from email.
> Qualification criteria:
> - Budget minimum: $[amount]
> - Relevance to niche: AI agents, automation, Hermes Agent
> - Brand reputation: no gambling, no adult, no crypto scams
> When qualified, draft a personalized response.
> Reference something specific about their product.
> Tone: professional but warm. Not corporate.
> Never send emails without founder approval.
> Flag deals over $[amount] immediately via Telegram.

****Model:**** Budget: DeepSeek V4 Flash (cheapest, handles classification). Quality: DeepSeek V4 (slightly better reasoning, still cheap). Email scanning is high-volume low-complexity. No frontier model needed.

****Skills:****→ email processing skill (parse, extract, classify)

****MCPs:**** Email gateway (IMAP/SMTP)

****Cron jobs:****

inbox scan (every 30 min):

> "Check inbox for new emails matching brand deal patterns.
> Qualify against criteria in SOUL.md.
> For qualified leads: draft response, create Kanban card
> assigned to Sales Ops, notify Telegram.
> For unqualified: log and archive."

wakeAgent gate: skip if no new emails.

****Example output:****

> NEW QUALIFIED LEAD:
> 
> From: [name] at [brand]
> Subject: Partnership opportunity
> Budget: $3,500 for 60s integration
> Platform: YouTube + X cross-post
> Relevance: AI productivity tool, strong niche fit
> 
> Draft response ready. Kanban card created.
> Assigned to Sales Ops for proposal.
> 
> APPROVE RESPONSE? [link to draft]

****Common mistake:**** giving SDR permission to send emails. Draft only. Founder approves every outbound message. One bad automated email can damage your reputation permanently.

### AGENT 5 — SALES OPS MANAGER

****What it replaces:**** a $70K/year sales ops person who manages the deal pipeline, generates proposals, and tracks contract status.

****What it does:****→ takes qualified leads from SDR → generates custom proposals based on templates → tracks deal stages (contacted → proposal → negotiation → signed → delivered) → follows up on stale deals → reports pipeline status weekly

****SOUL.md core:****

> You are Sales Ops Manager for a solo founder.
> Your job: move deals through the pipeline from qualified lead to signed contract.
> Use the proposal template to generate custom proposals.
> Track every deal in Kanban with clear status.
> Follow up on deals with no response after 5 days.
> Weekly pipeline report every Friday.
> Negotiation rules:
> - Minimum rate: $[amount]
> - Usage rights: max 12 months unless premium rate
> - Exclusivity: only at 2x standard rate
> Never agree to terms without founder approval.

****Model:**** Budget: DeepSeek V4 (proposals from templates, adequate quality). Quality: Claude Sonnet 4.6 (stronger writing for proposals and negotiation drafts).

****Skills:****→ proposal-generator skill (custom templates with [brackets]) → kanban toolset

****Cron jobs:****

stale deal check (daily 3pm):

> "Check Kanban for deals in 'contacted' or 'proposal sent'
> with no update for 5+ days. Draft follow-up email.
> Notify Telegram."

pipeline report (Friday 5pm):

> "Summarize all deals: stage, value, next action.
> Total pipeline value. Expected close this month.
> Deliver to Telegram."

****Common mistake:**** letting Sales Ops negotiate independently. It drafts counter-offers. Founder approves terms. Automated negotiation with no human oversight loses money.

****Example output (Friday pipeline report):****

> PIPELINE REPORT: Week of June 30, 2026
> 
> ACTIVE DEALS: 4
> 
> 1. [Brand A]: $3,500 YouTube integration
>    Stage: proposal sent (3 days ago)
>    Next: follow up Monday if no response
> 
> 2. [Brand B]: $5,000 X + YouTube bundle
>    Stage: negotiation (they countered at $4,200)
>    Next: NEEDS YOUR DECISION on counter-offer
> 
> 3. [Brand C]: $1,200 single post
>    Stage: contacted (6 days, no response)
>    Next: follow-up draft ready. approve to send?
> 
> 4. [Brand D]: $8,000 quarterly package
>    Stage: signed. deliverables due July 15
>    Next: Content agent has the brief
> 
> TOTAL PIPELINE: $17,700
> EXPECTED CLOSE THIS MONTH: $8,000 (Brand D signed)
> PENDING DECISIONS: 1 (Brand B counter-offer)

### AGENT 6 — EXECUTIVE ASSISTANT

****What it replaces:**** a $45K/year EA who manages calendar, reminders, travel logistics, and routine admin.

****What it does:****→ manages reminders and deadlines → tracks expenses and receipts → handles routine admin (file organization, data entry) → monitors calendar for conflicts → delivers daily agenda

****SOUL.md core:****

> You are Executive Assistant for a solo founder.
> Your job: make sure the founder never forgets anything
> and never wastes time on admin.
> Set reminders. Track deadlines. Organize files.
> Daily agenda at 7:30am before the morning brief.
> Process receipts when photos are sent.
> Tone: concise, helpful, anticipatory.
> If you notice a scheduling conflict, flag it immediately.

****Model:**** DeepSeek V4 Flash for both tiers. EA work is routine admin. Reminders, calendar, receipts. Cheapest model that handles these tasks well.

****MCPs:**** Google Calendar, Google Drive (or Notion)

****Cron jobs:****

daily agenda (7:30am):

> "Check calendar for today's events.
> Check reminders due today.
> Check deadlines within 48 hours.
> Deliver agenda to Telegram."

receipt processing (on-demand):

> When a photo is sent in the "expenses" Telegram topic,
> extract vendor, amount, date, category.
> Log to expenses tracker. Confirm in chat.

****Common mistake:**** overloading EA with tasks that need reasoning. EA handles routine admin. Anything that requires judgment goes to Chief of Staff for routing.

****Example output (daily agenda):****

> AGENDA: July 4, 2026
> 
> TODAY:
> → 10:00 AM: call with [client] (Zoom link in calendar)
> → 2:00 PM: content review block (no meetings)
> → 5:00 PM: gym (personal)
> 
> REMINDERS DUE TODAY:
> → send invoice to [Brand D] (deliverables shipped yesterday)
> → reply to [name] email (flagged 2 days ago)
> 
> DEADLINES WITHIN 48 HOURS:
> → July 5: [Brand D] video deliverable due
> → July 6: quarterly tax filing
> 
> CONFLICTS: none detected.
> 
> RECEIPT PROCESSED YESTERDAY:
> → Adobe Creative Cloud: $54.99, software
> → Hetzner VPS: $7.00, infrastructure
>   logged to expenses tracker.

### AGENT 7 — ANALYST

****What it replaces:**** a $80K/year business analyst who tracks KPIs, builds reports, and identifies trends in your data.

****What it does:****→ generates weekly revenue and growth reports → tracks KPIs (followers, views, engagement, revenue) → identifies trends and anomalies → compares performance across time periods → delivers monthly deep-dive analysis

****SOUL.md core:****

> You are Analyst for a solo founder.
> Your job: turn data into decisions.
> Track KPIs: revenue, followers, views, engagement rate,
> cost per post, conversion rate, pipeline value.
> Weekly report every Sunday with trends and anomalies.
> Monthly deep-dive on the first Monday.
> Always compare current period vs previous period.
> Flag any metric that changed more than 20%.
> Present numbers first. Interpretation second. Recommendation third.
> No speculation without data.

****Model:**** Budget: DeepSeek V4 (data fetching and comparison, handles it well). Quality: GPT-5.5 (stronger pattern recognition and structured reporting, 2M context handles large datasets).

****Skills:****→ data analysis skill (CSV parsing, calculations)

****MCPs:**** Google Sheets (for pulling live data)

****Cron jobs:****

weekly report (Sunday 8pm):

> "Pull this week's data: [KPI sources].
> Compare vs last week and vs 4-week average.
> Flag anomalies (>20% change).
> Deliver structured report to Telegram."

monthly deep-dive (first Monday 9am):

> "Full month analysis. Revenue, growth, content performance,
> pipeline conversion, cost breakdown.
> Include: what worked, what didn't, recommended changes.
> Deliver to Telegram + save as report in ~/reports/."

****Common mistake:**** running Analyst on a premium model. This is mostly data fetching and comparison. GPT-5.5 handles it well. Opus would cost 5x more for the same output.

****Example output (weekly report):****

> WEEKLY ANALYTICS: June 23-29, 2026
> 
> FOLLOWERS: 1,847 (+124 this week, +7.2%)
>   vs 4-week avg: +89/week. THIS WEEK ABOVE AVERAGE.
> 
> IMPRESSIONS: 412K (+31% vs last week)
>   top post: "15 Levels of Hermes Agent" (164K views)
> 
> ENGAGEMENT RATE: 4.8% (up from 3.9%)
>   bookmarks drove the increase (312 this week vs 180 avg)
> 
> REVENUE: $3,500 (Brand D signed)
>   pipeline: $9,700 pending across 3 deals
> 
> CONTENT: 5 posts published. 2 articles.
>   best performing format: long-form single post
>   worst performing: news reaction (2 underperformed)
> 
> ANOMALY: ⚠️ bookmark rate jumped 73% week over week.
>   cause: "15 Levels" article. reference-style content
>   drives saves at 3x the rate of news posts.
> 
> RECOMMENDATION: publish one more reference article
> this week while the algorithm is warm.

### AGENT 8 — DEVOPS ENGINEER

****What it replaces:**** a $95K/year DevOps engineer who monitors servers, manages deployments, and handles incident response.

****What it does:****→ monitors server health (RAM, disk, CPU, uptime) → runs deployment scripts when code is pushed → checks SSL certs, DNS, and service status → alerts on failures → auto-fixes known issues from its skill library

****SOUL.md core:****

> You are DevOps Engineer for a solo founder.
> Your job: keep everything running.
> Monitor all servers and services every 5 minutes.
> Alert immediately on: service down, disk >85%, RAM >90%,
> SSL cert expiring within 7 days.
> For known issues: check skill library and auto-fix if confident.
> For unknown issues: alert founder with diagnosis,
> do not attempt fixes without approval.
> Never modify production config without explicit approval.
> Log every action.

****Model:**** Budget: DeepSeek V4 Flash (mostly no_agent, agent wakes rarely). Quality: Claude Sonnet 4.6 (strong debugging when agent does wake for complex issues).

****Skills:****→ server-monitoring skill (health check scripts) → deployment skill (git pull, build, restart patterns)

****Cron jobs:****

health check (every 5 min):

> no_agent mode.
> script checks: HTTP 200, disk usage, RAM usage,
> SSL cert expiry, service uptime.
> wakeAgent: true only if any check fails.

deploy watcher (every 15 min):

> no_agent mode.
> script checks git remote for new commits on main.
> wakeAgent: true only if new commits found.
> agent runs deployment script and verifies.

****Example alert:****

> ALERT: production disk usage at 87%.
> 
> Diagnosis: /var/log/hermes growing fast.
> Cause: verbose logging from cron job debug mode.
> 
> Recommended fix: rotate logs and set log level to "warn."
> Skill "log-rotation" matches this pattern.
> 
> AUTO-FIX AVAILABLE. Approve? [yes/no]

****Common mistake:**** giving DevOps full auto-fix permissions on production. Use approval gates. Let it diagnose and propose. You approve the fix.

### HOW THEY COORDINATE: KANBAN

all 8 agents share one Kanban board.

when SDR qualifies a lead → creates a card → assigns to Sales Ops. when Research finds a signal → creates a card → assigns to Content. when DevOps detects an issue → creates a card → Chief of Staff routes it.

the board is the communication layer. agents don't message each other directly. they read and write cards.

Chief of Staff reads the entire board every morning and synthesizes status across all agents.

> hermes kanban swarm "new product launch" \
>   --workers researcher,content,sdr \
>   --verifier analyst \
>   --synthesizer chief-of-staff

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074143493958631425

### TELEGRAM ORGANIZATION

one Telegram group. topics enabled. one topic per agent.

create a group called "Operations HQ." enable Topics in group settings. create 8 topics:

→ [#chief](https://x.com/search?q=%23chief&src=hashtag_click)

-of-staff (morning briefs, priority alerts) → [#research](https://x.com/search?q=%23research&src=hashtag_click)

 (signals, weekly digest) → [#content](https://x.com/search?q=%23content&src=hashtag_click)

 (drafts, calendar, ideas) → [#sdr](https://x.com/search?q=%23sdr&src=hashtag_click)

 (new leads, qualified prospects) → [#sales](https://x.com/search?q=%23sales&src=hashtag_click)

-ops (pipeline, proposals, follow-ups) → [#assistant](https://x.com/search?q=%23assistant&src=hashtag_click)

 (agenda, reminders, receipts) → [#analyst](https://x.com/search?q=%23analyst&src=hashtag_click)

 (weekly reports, anomalies) → [#devops](https://x.com/search?q=%23devops&src=hashtag_click)

 (health alerts, deploys)

****the practical setup: one bot, one gateway, topic routing.****

Telegram allows only one active connection per bot token. Hermes maps one TELEGRAM_BOT_TOKEN per gateway process.

running 8 separate gateways with 8 separate bots works but consumes significant resources on a VPS. each gateway is its own process with its own memory footprint.

the lighter approach: one bot added to the group as admin. each cron job delivers to a specific topic via chat_id:

deliver: telegram:GROUP_CHAT_ID/TOPIC_ID

Chief of Staff cron delivers to [#chief](https://x.com/search?q=%23chief&src=hashtag_click)

-of-staff topic. SDR cron delivers to [#sdr](https://x.com/search?q=%23sdr&src=hashtag_click)

 topic. DevOps alerts go to [#devops](https://x.com/search?q=%23devops&src=hashtag_click)

 topic. one bot, eight channels. clean separation.

you open Telegram and scan topics like Slack channels. everything separated. nothing mixed.

****when to run separate gateways:****

if you need profiles to respond interactively in their own topics (not just deliver cron output), each profile needs its own gateway and bot token.

chief-of-staff gateway    # [@ChiefOfStaff_bot](https://x.com/@ChiefOfStaff_bot)

researcher gateway        # [@Researcher_bot](https://x.com/@Researcher_bot)

content gateway           # [@Content_bot](https://x.com/@Content_bot)

this gives you 8 interactive agents in 8 topics. each one responds when you message it directly. costs more VPS resources. use when you need two-way conversations with individual agents.

for most setups: one bot with topic routing covers 90% of the value at 10% of the complexity.

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074162564389384192

### ONE LEAD THROUGH ALL 8 AGENTS

a new lead arrives. watch how it flows through the team.

****MINUTE 0:**** SDR scans inbox. finds a brand deal email. qualifies it. creates a Kanban card. notifies [#sdr](https://x.com/search?q=%23sdr&src=hashtag_click)

 topic.

****MINUTE 5:**** Chief of Staff sees the new card in the priority check. routes it to Sales Ops.

****HOUR 1:**** Sales Ops generates a custom proposal using the template. drafts a response email. creates a Kanban card in "review." notifies [#sales](https://x.com/search?q=%23sales&src=hashtag_click)

-ops.

****HOUR 2:**** you open Telegram. read the [#sales](https://x.com/search?q=%23sales&src=hashtag_click)

-ops topic. approve the proposal. Sales Ops sends the draft (you hit send manually).

****DAY 3:**** no response. Sales Ops flags the deal as stale. drafts a follow-up. notifies [#sales](https://x.com/search?q=%23sales&src=hashtag_click)

-ops.

****DAY 5:**** brand responds. deal moves to "negotiation." Sales Ops drafts a counter-offer. Kanban card updated. Chief of Staff includes it in the morning brief.

****DAY 7:**** deal signed. Sales Ops moves card to "signed." creates a deliverable card assigned to Content. Analyst logs the revenue.

****DAY 8:**** Content drafts the sponsored post based on the brief. runs slop check. creates a review card. notifies [#content](https://x.com/search?q=%23content&src=hashtag_click)

.

****DAY 9:**** you review, edit, publish. Content marks the card "delivered."

****SUNDAY:**** Analyst includes the deal in the weekly report. revenue tracked. conversion rate updated.

one lead. eight agents. you made two decisions (approve proposal, review post). everything else was automated.

### WHAT THIS COSTS

Two setups. Same 8 agents. Different price points.

****BUDGET SETUP (minimum cost, functional output):****

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074134796117155840

Content stays on Sonnet because writing quality directly affects your reputation. everything else runs on DeepSeek.

****QUALITY SETUP (best output, higher cost):****

https://x.com/IBuzovskyi/article/2074174357220307317/media/2074135197872689152

Researcher and Analyst on GPT-5.5 (2M context, strong at synthesis). Chief of Staff and DevOps on Sonnet (reliable reasoning and code understanding). SDR and EA stay budget (volume tasks, no reasoning needed).

> ****BOTH SETUPS: set auxiliary models to cheap:****

by default auxiliary tasks use your MAIN model. that means compression, vision, web summaries, memory flush, skill matching all burn premium tokens.

override for every profile:

auxiliary: compression: provider: openrouter model: google/gemini-3-flash-preview web_extract: provider: openrouter model: google/gemini-3-flash-preview vision: provider: openrouter model: google/gemini-3-flash-preview

or set in Desktop app / Dashboard: Models → Auxiliary.

this single change saves 30-50% on token costs across all profiles.

****BOTH SETUPS: set delegation model to cheap:****

sub-agents spawned by any profile default to that profile's main model. override:

delegation: model: "google/gemini-3-flash-preview" provider: "openrouter"

> ****COST COMPARISON:****

8 agents on budget setup: $22-49/month. 8 agents on quality setup: $41-86/month. VPS: $7/month (Hetzner CX22). Telegram: $0.

****Total budget: $29-56/month.**** ****Total quality: $48-93/month.****

vs one junior employee: $3,500+/month (US-based).

Salary figures are US-based estimates. Adjust for your market. The ratio stays the same: 8 agents cost less than one junior hire anywhere.

[SCREENSHOT 9: Dashboard Usage tab showing per-profile token spend breakdown]

Token cost scales with activity. Quiet week = lower end. Launch week = higher end.

set budget caps per profile to prevent surprises:

budget: daily_max_usd: 5

> ****OPTIONAL: MIXTURE OF AGENTS FOR CRITICAL ROLES****

MoA presets combine multiple models into one answer. the aggregator synthesizes reference models' perspectives. 8% higher than Opus 4.8 on Hermes Bench.

worth enabling for 2 profiles only:

Content (writing quality = your reputation): → aggregator: Sonnet 4.6 → references: GPT-5.5 + DeepSeek V4 Pro

Chief of Staff (daily synthesis across 7 agents): → aggregator: Sonnet 4.6 → references: GPT-5.5 + Gemini 2.5 Pro

set in Desktop app / Dashboard: Models → Mixture of Agents → Add Preset.

tradeoff: 2-3x slower, higher cost per turn. do not use MoA on high-frequency agents (SDR, EA, DevOps). the cost-per-turn increase does not justify the quality gain on routine tasks.

### WHAT NOT TO AUTOMATE

→ ****Strategic decisions.**** Which product to build. Which deals to accept. What to say publicly. The agents surface information. You decide.

→ ****Sending emails.**** Every outbound email is drafted by agents and approved by you. One bad automated email can cost a relationship.

→ ****Publishing content.**** Agents draft and check. You review and hit publish. The quality bar is your reputation.

→ ****Financial transactions.**** Stripe Link CLI can automate purchases. You approve every spend on your phone. No unsupervised spending.

→ ****Hiring/firing agents.**** You decide when to add a new profile, change a model, or shut one down. The system doesn't modify itself.

The rule: agents handle execution. You handle judgment. If a task requires taste, reputation risk, or irreversible consequences, a human does it.

### HOW TO BUILD THIS YOURSELF

Two approaches. Pick based on your experience.

> ****APPROACH A: WEEK BY WEEK (recommended for first-time multi-agent users)****

You do not need all 8 on day one. Start with 2-3 and add when you hit a bottleneck. Each week you learn how one agent behaves, tune its SOUL.md, adjust the model, fix cron timing. By week 8 each agent is tuned to YOUR workflow, not a generic template.

Week 1: Chief of Staff + Executive Assistant. Two profiles. Morning brief + daily agenda. Telegram delivery. This alone changes how you start your day.

Week 2: Add Research. Third profile. Daily competitor scan. Obsidian wiki. You stop manually checking what's happening in your market.

Week 3: Add Content. Fourth profile. Draft posts based on research findings. Your content pipeline stops depending on your energy levels.

Week 4+: Add SDR, Sales Ops, Analyst, DevOps. One profile per week. Each solves a specific bottleneck. By week 8 you have the full team, each one tuned.

> ****APPROACH B: ALL 8 AT ONCE (experienced Hermes users)****

If you already know profiles, cron, and Kanban, give Hermes one /goal command and it creates all 8 profiles with SOUL.md, models, and cron jobs in a single session. 10-15 minutes.

set max_turns higher for this:

goals: max_turns: 40

then run a /goal with all 8 profile specs (SOUL.md, model, cron for each). Hermes creates them sequentially and reports status.

the tradeoff: you get the full team fast but each agent runs on generic settings. you still need to tune SOUL.md, adjust cron timing, and test each agent over the following weeks.

deploy fast. tune over time.

****FOR EITHER APPROACH, each new agent needs:****

1. Create profile: Desktop app / Dashboard: Profiles → Create CLI: hermes profile create [name]
2. Write SOUL.md (use examples above as templates)
3. Set model: Desktop app / Dashboard: profile settings → Model CLI: [name] config set model.default [model]
4. Add skills and MCPs relevant to the role
5. Set cron jobs with wakeAgent gates
6. Connect to Telegram (each agent gets its own bot or its own topic in a group chat)
7. Test for one week before adding the next agent

### THE FULL STACK

→ 1 VPS ($7/month) → 8 Hermes profiles (isolated, permanent) → 1 Kanban board (shared coordination) → 1 Telegram group with topics (one per agent) → wakeAgent gates on every cron (zero cost when idle) → no_agent scripts for monitoring ($0 forever) → budget caps per profile (no surprise bills)

set in Desktop app, Dashboard, or config.yaml: budget.daily_max_usd: 5 (per profile)

→ you review results, not tasks

this is what a zero-headcount company looks like from the inside.

### OFFICIAL SOURCES

- [Profiles](https://hermes-agent.nousresearch.com/docs/user-guide/profiles)
- [Kanban](https://hermes-agent.nousresearch.com/docs/user-guide/features/kanban)
- [Cron](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron)
- [Delegation](https://hermes-agent.nousresearch.com/docs/developer-guide/delegation)
- [SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/soul)

All technical details verified against Hermes Agent v0.18.0 documentation.

[@Teknium](https://x.com/@Teknium)

 [@NousResearch](https://x.com/@NousResearch)

> 📄 Original article URL: https://x.com/i/article/2074106701297360897

---

## Commentary from Other Bookmarks

### @IBuzovskyi (YanXbt) — 2026-07-08

> HERMES AGENT IS NOW IN THE CLOUD.
> NO VPS. NO TERMINAL. NO SETUP.
> PICK A MODEL. PICK A SERVER SIZE.
> AGENT IS LIVE IN 60 SECONDS.
> 
> Nous Portal just launched hosted Hermes Agent.
> two clicks. one minute. done. @NousResearch 
> 
> WHAT THIS MEANS:
> 
> before today: install Hermes on a VPS or your laptop.
> configure providers. set up gateway. manage updates.
> run hermes setup. edit config.yaml.
> great for power users. friction for everyone else.
> 
> now: go to http://portal.nousresearch.com/cloud.
> pick a model. pick a server size.
> your agent is live and reachable in 60 seconds.
> no terminal. no SSH. no Docker.
> 
> same Hermes. same features. same tools.
> someone else handles the infrastructure.
> 
> FOR TEAMS:
> 
> this is where it gets interesting.
> 
> spin up agents for everyone at your org.
> each team member gets their own Hermes instance.
> granular access controls per user.
> unified billing through Nous Portal.
> 
> your team gets Hermes on day one.
> no DevOps needed. no VPS per person.
> one admin dashboard. one bill.
> 
> WHAT'S INCLUDED:
> 
> → 300+ models via Nous Portal
>   (Claude, GPT, Gemini, DeepSeek, Grok, MiniMax, and more)
> → Tool Gateway
>   (web search, image generation, TTS, browser automation)
> → all messaging platforms
>   (Telegram, Discord, Slack, WhatsApp, Signal)
> → full feature set
>   (profiles, cron, kanban, skills, memory, sub-agents,
>   MoA, /goal, /learn, /journey)
> → automatic updates
> 
> ONE PORTAL. FOUR TIERS:
> 
> Free: $0/month. pay-as-you-go credits from $10.
> Plus: $20/month. $22 in monthly usage credit.
> Super: $100/month. $110 in monthly credit.
> Ultra: $200/month. $220 in monthly credit. highest rate limits.
> 
> every paid tier includes Tool Gateway.
> one OAuth. one subscription. no extra API keys.
> 
> SELF-HOSTED IS NOT GOING ANYWHERE:
> 
> Hermes is MIT licensed. open source. free forever.
> you can still run it on your laptop, VPS, or GPU cluster.
> nothing changes for self-hosted users.
> 
> the cloud version is for people who want
> the agent running without managing the machine.
> 
> pick your path:
> → self-hosted: full control. you manage everything.
> → cloud: zero ops. Nous manages infrastructure.
> → hybrid: self-host your main agent,
>   cloud for team members.
> 
> HOW TO START:
> 
> cloud: http://portal.nousresearch.com/cloud
> self-hosted: hermes setup --portal
> 
> both connect to the same Nous Portal.
> same models. same tools. same billing.
> 
> learn how to replace your entire team with 8 hermes agents 👇

[→ View quote tweet](https://x.com/IBuzovskyi/status/2074883463916777612)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

