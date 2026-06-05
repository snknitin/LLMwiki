---
title: "Every AI conversation starts the same way. You explain who you are. You explain what you're working..."
author: "Muratcan Koylan"
username: "@koylanai"
date: "2026-02-21"
tweet_url: "https://x.com/koylanai/status/2025286163641118915"
tweet_type: "original"
likes: 6224
retweets: 860
replies_count: 137
bookmarks: 18149
views: 2781142
has_media: false
article_id: "2025249985722224640"
tags: ["twitter-bookmark", "claude", "llm", "ai-tools"]
---

# Every AI conversation starts the same way. You explain who you are. You explain what you're working...

> **Source:** [@koylanai](https://x.com/koylanai) - 2026-02-21 - Likes: 6224 - Bookmarks: 18149 - Views: 2781142

> [View on X](https://x.com/koylanai/status/2025286163641118915)

## Article Content

Every AI conversation starts the same way. You explain who you are. You explain what you're working on. You paste in your style guide. You re-describe your goals. You give the same context you gave yesterday, and the day before, and the day before that. Then, 40 minutes in, the model forgets your voice and starts writing like a press release.

I got tired of this. So I built a system to fix it.

I call it Personal Brain OS. It's a file-based personal operating system that lives inside a Git repository. Clone it, open it in Cursor or Claude Code, and the AI assistant has everything: my voice, my brand, my goals, my contacts, my content pipeline, my research, my failures. No database, no API keys, no build step. Just 80+ files in markdown, YAML, and JSONL that both humans and language models read natively.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 30, 2025](https://x.com/koylanai/status/2005827257458131321)

Context Engineering Skills 10x'd my project creation.

I rebuilt my digital brain system with Claude Code using the Context Plugin, so it is now a Personal OS.

It provides a complete folder-based architecture for managing:
- Personal Brand - Voice, positioning, values
- Content

https://x.com/koylanai/status/2005827257458131321/photo/1Quote

****Muratcan Koylan****

@koylanai

·

Oct 6, 2025

![Embedded video](https://pbs.twimg.com/amplify_video_thumb/1975080002589691904/img/PKiTlWQ7nUuStWAD?format=jpg&name=240x240)

7:31

How I built an AI agent system that automatically maintains my digital brain based on the content I engage with?

My personal context engineering architecture with Claude Sonnet 4.5, Groq Compound, Browser Use, all in Cursor I'm sharing the full architecture, the design decisions, and the mistakes so you can build your own version. Not a copy of mine; yours. The specific modules, the file schemas, the skill definitions will look different for your work. But the patterns transfer. The principles for structuring information for AI agents are universal. Take what fits, ignore what doesn't, and ship something that makes your AI actually useful instead of generically helpful.

Here's how I built it, why the architecture decisions matter, and what I learned the hard way.

### 1) THE CORE PROBLEM: CONTEXT, NOT PROMPTS

Most people think the bottleneck with AI assistants is prompting. Write a better prompt, get a better answer. That's true for single interactions and production agent prompts. It falls apart when you want an AI to operate as you across dozens of tasks over weeks and months.

****The Attention Budget:**** Language models have a finite context window, and not all of it is created equal. This means dumping everything you know into a system prompt isn't just wasteful, it actively degrades performance. Every token you add competes for the model's attention.

https://x.com/koylanai/article/2025286163641118915/media/2025256255552356352Our brains work similarly. When someone briefs you for 15 minutes before a meeting, you remember the first thing they said and the last thing they said. The middle blurs. Language models have the same U-shaped attention curve, except theirs is mathematically measurable. Token position affects recall probability. The newer models are getting better at this, but still, you are distracting the model from focusing on what matters most. Knowing this changes how you design information architecture for AI systems.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 12, 2025](https://x.com/koylanai/status/1999192104850133146)

AI Agent Personas should simulate the structure of human reasoning.

I’ve been arguing that you cannot "invent" a digital expert agent using just prompt engineering. You have to extract the expert via deep interviewing. 

A new NeurIPS paper, "Simulating Society Requires

https://x.com/koylanai/status/1999192104850133146/photo/1Quote

****Muratcan Koylan****

@koylanai

·

Dec 10, 2025

https://x.com/koylanai/status/1998530190847390025/photo/1You should NOT use LLMs to generate synthetic human-like profiles.

I just read the NeurIPS paper "LLM Generated Persona is a Promise with a Catch" and it confirms a suspicion we’ve held for a long time: You cannot "invent" a realistic human being using just statistics and an

Instead of writing one massive system prompt, I split Personal OS into 11 isolated modules. When I ask the AI to write a blog post, it loads my voice guide and brand files. When I ask it to prepare for a meeting, it loads my contact database and interaction history. The model never sees network data during a content task, and never sees content templates during a meeting prep task.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 10, 2025](https://x.com/koylanai/status/1998530190847390025)

You should NOT use LLMs to generate synthetic human-like profiles.

I just read the NeurIPS paper "LLM Generated Persona is a Promise with a Catch" and it confirms a suspicion we’ve held for a long time: You cannot "invent" a realistic human being using just statistics and an

https://x.com/koylanai/status/1998530190847390025/photo/1****Progressive Disclosure:**** This is the architectural pattern that makes the whole system work. Instead of loading all 80+ files at once, the system uses three levels. ****Level 1 is a lightweight routing**** file that's always loaded. It tells the AI which module is relevant.**** Level 2 is module-specific instructions**** that load only when that module is needed. ****Level 3 is the actual data**** JSONL logs, YAML configs, research documents, loaded only when the task requires them.

This mirrors how experts operate. The three levels create a funnel: broad routing, then module context, then specific data. At each step, the model has exactly what it needs and nothing more.

https://x.com/koylanai/article/2025286163641118915/media/2025256717408223233My routing file is `SKILL.md` that tells the agent "this is a content task, load the brand module" or "this is a network task, load the contacts." The module instruction files (`CONTENT.md`, `OPERATIONS.md`, `NETWORK.md`) are 40-100 lines each, with file inventories, workflow sequences, and an `<instructions>` block with behavioural rules for that domain. Data files load last, only when needed. The AI reads contacts line by line from JSONL rather than parsing the entire file. Three levels, with a maximum of two hops to any piece of information.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 7, 2025](https://x.com/koylanai/status/1997444237890081104)

Most people treat AI like Google: ask a question, get an answer. But what if AI could think *like/with you?*

I reverse-engineer "Theory of Mind" to test if the model can form a "theory of my mind".

Using AI as a mirror to understand myself by giving it personal context and

![](https://pbs.twimg.com/amplify_video_thumb/1997438305894371329/img/Tn9XiH9Nui8tMyr7.jpg)

Quote

****Carlos E. Perez****

@IntuitMachine

·

Dec 6, 2025

https://x.com/IntuitMachine/status/1997131059805163542/photo/1You know how some people seem to have a magic touch with LLMs? They get incredible, nuanced results while everyone else gets generic junk.

The common wisdom is that this is a technical skill. A list of secret hacks, keywords, and formulas you have to learn.

But a new paper

****The Agent Instruction Hierarchy: ****I built three layers of instructions that scope how the AI behaves at different levels. At the repository level, `CLAUDE.md` is the onboarding document -- every AI tool reads it first and gets the full map of the project. At the brain level, `AGENT.md` contains seven core rules and a decision table that maps common requests to exact action sequences. At the module level, each directory has its own instruction file with domain-specific behavioral constraints.

https://x.com/koylanai/article/2025286163641118915/media/2025266558931525632This solves the "conflicting instructions" problem that plagues large AI projects. When everything lives in one system prompt, rules contradict each other. A content creation instruction might conflict with a networking instruction. By scoping rules to their domain, you eliminate conflicts and give the agent clear, non-overlapping guidance. The hierarchy also means you can update one module's rules without risking regression in another module's behavior.

https://x.com/koylanai/article/2025286163641118915/media/2025257778005069824My `AGENT.md` is a decision table. The AI reads "User says 'send email to Z'" and immediately sees:

1. Step 1, look up contact in HubSpot.
2. Step 2, verify email address.
3. Step 3, send via Gmail.

Module-level files like `OPERATIONS.md` define priority levels (P0: do today, P1: this week, P2: this month, P3: backlog) so the agent triages tasks consistently. The agent follows the same priority system I use because the system is codified, not implied.

### 2) THE FILE SYSTEM AS MEMORY

One of the most counterintuitive decisions I made: no database. No vector store. No retrieval system except Cursor or Claude Code's features. Just files on disk, versioned with Git.

https://x.com/koylanai/article/2025286163641118915/media/2025258736168660992****Format-Function Mapping:**** Every file format in the system was chosen for a specific reason related to how AI agents process information. JSONL for logs because it's append-only by design, stream-friendly (the agent reads line by line without parsing the entire file), and every line is self-contained valid JSON. YAML for configuration because it handles hierarchical data cleanly, supports comments, and is readable by both humans and machines without the noise of JSON brackets. Markdown for narrative because LLMs read it natively, it renders everywhere, and it produces clean diffs in Git.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Feb 16](https://x.com/koylanai/status/2023405681080938932)

The problem is how memory gets into the context window and what happens when compaction wipes it.

OpenClaw loads MEMORY[.]md plus the last two days of daily logs at session start. Static injection. Everything gets stuffed into the context window upfront. When the window fills

https://x.com/koylanai/status/2023405681080938932/photo/1Quote

****@levelsio****

@levelsio

·

Feb 16

How did you guys fix persistent memory with OpenClaw? My bot keeps forgetting stuff, I already have qmd installed

JSONL's append-only nature prevents a category of bugs where an agent accidentally overwrites historical data. I've seen this happen with JSON files agent writes the whole file, loses three months of contact history. With JSONL, the agent can only add lines. Deletion is done by marking entries as `"status": "archived"`, which preserves the full history for pattern analysis. YAML's comment support means I can annotate my goals file with context the agent reads but that doesn't pollute the data structure. And Markdown's universal rendering means my voice guide looks the same in Cursor, on GitHub, and in any browser.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 5, 2025](https://x.com/koylanai/status/1996905189656211931)

OpenAI wants markdown structure. Anthropic prefers XML tags. Google emphasizes few-shot examples.

So I built a simple agent system that reads the official prompting docs and applies them to the given prompt.

Each optimizer runs a ReAct loop:
- list_provider_docs → discover

![](https://pbs.twimg.com/amplify_video_thumb/1996899836021395456/img/tgLJMRKbjUv_MHUq.jpg)

My system uses 11 JSONL files (posts, contacts, interactions, bookmarks, ideas, metrics, experiences, decisions, failures, engagement, meetings), 6 YAML files (goals, values, learning, circles, rhythms, heuristics), and 50+ Markdown files (voice guides, research, templates, drafts, todos). Every JSONL file starts with a schema line: `{"_schema": "contact", "_version": "1.0", "_description": "..."}`. The agent always knows the structure before reading the data.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 5, 2025](https://x.com/koylanai/status/1996757974610559171)

Your best people can't document their expertise because they don't know what they know until they're asked.

We built an interviewer that achieves peer status, so experts reveal the judgment patterns they'd only share with a colleague.

I wrote a blog about how we architected the

https://x.com/koylanai/status/1996757974610559171/photo/1https://x.com/koylanai/status/1996757974610559171/photo/2Quote

****Anthropic****

@AnthropicAI

·

Dec 4, 2025

We’re launching Anthropic Interviewer, a new tool to help us understand people’s perspectives on AI.

It’s now available at http://claude.ai/interviewer for a week-long pilot.

****Episodic Memory: ****Most "second brain" systems store facts. Mine stores judgment as well. The `memory/` module contains three append-only logs: `experiences.jsonl` (key moments with emotional weight scores from 1-10), `decisions.jsonl` (key decisions with reasoning, alternatives considered, and outcomes tracked), and `failures.jsonl` (what went wrong, root cause, and prevention steps).

https://x.com/koylanai/article/2025286163641118915/media/2025259682101702657There's a difference between an AI that has your files and an AI that has your judgment. Facts tell the agent what happened. Episodic memory tells the agent what mattered, what I'd do differently, and how I think about tradeoffs. When the agent encounters a decision similar to one I've logged, it can reference my past reasoning instead of generating generic advice. The failures log is the most valuable, it encodes pattern recognition that took real pain to acquire.

> When I was deciding whether to accept Antler Canada's $250K investment or join [Sully.ai](https://x.com//Sully.ai)
> 
>  as Context Engineer, the decision log captured both options, the reasoning for each, and the outcome. If a similar career tradeoff comes up, the agent doesn't give me generic career advice. It references how I actually think about these decisions: "Learning > Impact > Revenue > Growth" is my priority order, and "Can I touch everything? Will I learn at the edge of my capability? Do I respect the founders?" is my company-joining framework.

****Cross-Module References: ****The system uses a flat-file relational model. No database, but structured enough for agents to join data across files. `contact_id` in `interactions.jsonl` points to entries in `contacts.jsonl`. `pillar` in `ideas.jsonl` maps to content pillars defined in `identity/brand.md`. Bookmarks feed content ideas. Post metrics feed weekly reviews. The modules are isolated for loading, but connected for reasoning.

Isolation without connection is just a pile of folders. The cross-references let the agent traverse the knowledge graph when needed. "Prepare for my meeting with Sarah" triggers a lookup chain: find Sarah in contacts, pull her interactions, check pending todos involving her, compile a brief. The agent follows the references across modules without loading the entire system.

My pre-meeting workflow chains three files: `contacts.jsonl` (who they are), `interactions.jsonl` (filtered by contact_id for history), and `todos.md` (any pending items). The agent produces a one-page brief with relationship context, last conversation summary, and open follow-ups. No manual assembly. The data structure makes the workflow possible.

### 3) THE SKILL SYSTEM: TEACHING AI HOW TO DO YOUR WORK

Files store knowledge. Skills encode process. I built Agent Skills following the Anthropic Agent Skills standard, structured instructions that tell the AI how to perform specific tasks with quality gates baked in.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 28, 2025](https://x.com/koylanai/status/2005082048973905938)

Most "agentic" failures happen because the model lacks specific domain knowledge. 

Here I'm showing how loading a Skills Plugin solves that for dataset generation. I turned a research paper (shows fine-tuning dataset creation from books) into a Skill and just gave a book link

![](https://pbs.twimg.com/amplify_video_thumb/2005080230134771712/img/sL0lQi7olj8DXhO3.jpg)

Quote

****Muratcan Koylan****

@koylanai

·

Dec 27, 2025

https://x.com/koylanai/status/2004877190911950881/photo/1I wanted to try this, so I trained Qwen3-8B-Base on Gertrude Stein's "Three Lives" (1909) with Thinking Machines.

The model now writes in Stein's repetitive, rhythmic voice and gets Human Written label from AI Detection tools like Pangram.

https://muratcankoylan.com/projects/gertrude-stein-style-training/…

This became

****Auto-Loading vs. Manual Invocation: ****Two types of skills solve two different problems. Reference skills (`voice-guide`, `writing-anti-patterns`) set `user-invocable: false` in their YAML frontmatter. The agent reads the description field and injects them automatically whenever the task involves writing. I never invoke them, they activate silently, every time. Task skills (`/write-blog`, `/topic-research`, `/content-workflow`) set `disable-model-invocation: true`. The agent can't trigger them on its own. I type the slash command, and the skill becomes the agent's complete instruction set for that task.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Jan 29](https://x.com/koylanai/status/2016684758588154239)

Progressive disclosure is not reliable because LLMs are inherently lazy.

"In 56% of eval cases, the skill was never invoked. The agent had access to the documentation but didn't use it."

Vercel ran evals on Next.js 16 APIs that aren't in model training data to test whether

Quote

****Vercel****

@vercel

·

Jan 29

We're experimenting with ways to keep AI agents in sync with the exact framework versions in your projects. Skills, 𝙲𝙻𝙰𝚄𝙳𝙴.𝚖𝚍, and more.

But one approach scored 100% on our Next.js evals:
https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals…

Auto-loading solves the consistency problem. I don't have to remember to say "use my voice" every time I ask for a draft. The system remembers for me. Manual invocation solves the precision problem. A research task has different quality gates than a blog post. Keeping them separate prevents the agent from conflating two different workflows. The YAML frontmatter is the mechanism, and a few metadata fields control the entire loading behaviour.

https://x.com/koylanai/article/2025286163641118915/media/2025260062810238976When I type `/write-blog context engineering for marketing teams`, five things happen automatically: the voice guide loads (how I write), the anti-patterns load (what I never write), the blog template loads (7-section structure with word count targets), the persona folder is checked for audience profiles, and the research folder is checked for existing topic research. One slash command triggers a full context assembly. The skill file itself says "Read `brand/tone-of-voice.md`", it references the source module, never duplicates the content. Single source of truth.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Jan 7](https://x.com/koylanai/status/2008824728824451098)

I just built Ralph Wiggum Copywriter; learns your voice, critiques its own work, rewrites until it's actually good.

Self-critique loop hits different.

https://x.com/koylanai/status/2008824728824451098/photo/1****The Voice System: ****My voice is encoded as structured data and ngl with some vibes. The voice profile rates five attributes on a 1-10 scale: Formal/Casual (6), Serious/Playful (4), Technical/Simple (7), Reserved/Expressive (6), Humble/Confident (7). The anti-patterns file contains 50+ banned words across three tiers, banned openings, structural traps (forced rule of three, copula avoidance, excessive hedging), and a hard limit of one em-dash per paragraph.

https://x.com/koylanai/article/2025286163641118915/media/2025260657709400064Most people describe their voice with adjectives: "professional but approachable." That's useless for an AI. A 7 on the Technical/Simple scale tells the model exactly where to land. The banned word list is even more powerful; it's easier to define what you're NOT than what you are. The agent checks every draft against the anti-patterns list and rewrites anything that triggers it. The result is content that sounds like me because the guardrails prevent it from sounding like AI.

Every content template includes voice checkpoints every 500 words: "Am I leading with insight? Am I being specific with numbers? Would I actually post this?" The blog template has a 4-pass editing process built in: structure edit (does the hook grab?), voice edit (banned words scan, sentence rhythm check), evidence edit (claims sourced?), and a read-aloud test. The quality gates are part of the skill, not something I add after the fact.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Oct 6, 2025](https://x.com/koylanai/status/1975090268316827983)

How I built an AI agent system that automatically maintains my digital brain based on the content I engage with?

My personal context engineering architecture with Claude Sonnet 4.5, Groq Compound, Browser Use, all in Cursor 
![](https://pbs.twimg.com/amplify_video_thumb/1975080002589691904/img/PKiTlWQ7nUuStWAD.jpg)

****Templates as Structured Scaffolds:**** Five content templates define the structure for different content types. The long-form blog template has seven sections (Hook, Core Concept, Framework, Practical Application, Failure Modes, Getting Started, Closing) with word count targets per section totaling 2,000-3,500 words. The thread template defines an 11-post structure with a hook, deep-dive, results, and CTA. The research template has four phases: landscape mapping, technical deep-dive, evidence collection, and gap analysis.

Templates not only constrain creativity but also constrain chaos. Without structure, the agent produces amorphous blobs of text. With structure, it produces content that has rhythm, progression, and payoff. Each template also includes a quality checklist so the agent can ****self-evaluate**** before presenting the draft.

The research template outputs to `knowledge/research/[topic].md` with a structured format: Executive Summary, Landscape Map, Core Concepts, Evidence Bank (with statistics, quotes, case studies, and papers each cited with source and date), Failure Modes, Content Opportunities, and a Sources List graded HIGH/MEDIUM/LOW on reliability. That research document then feeds into the blog template's outline stage. The output of one skill becomes the input of the next. The pipeline builds on itself.

### 4) THE OPERATING SYSTEM: HOW I ACTUALLY USE THIS DAILY

Architecture is nothing without execution. 
Here's how the system runs in practice.

****The Content Pipeline: ****Seven stages: Idea, Research, Outline, Draft, Edit, Publish, Promote.

- Ideas are captured to `ideas.jsonl` with a scoring system, each idea rated 1-5 on alignment with positioning, unique insight, audience need, timeliness, and effort-versus-impact. Proceed if total score hits 15 or higher.
- Research outputs to the knowledge module.
- Drafts go through four editing passes.
- Published content gets logged to `posts.jsonl` with platform, URL, and engagement metrics.
- Promotion uses the thread template to create an X announcement and a LinkedIn adaptation.

https://x.com/koylanai/article/2025286163641118915/media/2025265634762731520I batch content creation on Sundays: 3-4 hours, target output of 3-4 posts drafted and outlined. The content calendar maps each day to a platform and content type.

****The Personal CRM:**** Contacts organized into four circles with different maintenance cadences: inner (weekly), active (bi-weekly), network (monthly), dormant (quarterly reactivation). Each contact record has `can_help_with` and `you_can_help_with` fields that enable the introduction matching system. cross-referencing these fields surfaces mutually valuable intros. Interactions are logged with sentiment tracking (positive, neutral, needs_attention) so relationship health is visible at a glance.

https://x.com/koylanai/article/2025286163641118915/media/2025267841843249152Most people keep contacts in their head and let relationships decay through neglect. The `stale_contacts` script cross-references contacts (who they are), interactions (when we last talked), and circles (how often we should talk) to surface outreach needs. A 30-second scan each week shows me which relationships need attention.

Specialized groups in `circles.yaml`founders, investors, ai_builders, creators, mentors, mentees, each have explicit relationship development strategies. For AI builders: share useful content, collaborate on open source, provide tool feedback, amplify their work. For mentors: bring specific questions, update on progress from previous advice, look for ways to add value back. These are operational instructions the agent follows when I ask "Who should I reach out to this week?"

****Automation Chains: ****Five scripts handle recurring workflows. They chain together for compound operations. The Sunday weekly review runs three scripts in sequence: `metrics_snapshot.py` updates the numbers, `stale_contacts.py` flags relationships, `weekly_review.py` generates a summary document with completed-versus-planned, metrics trends, and next week's priorities. The content ideation chain reads recent bookmarks, checks undeveloped ideas, generates fresh suggestions, and cross-references with the content calendar to find scheduling gaps. These aren't cron jobs -- the agent runs them when I ask for a review, or I trigger them with `npm run weekly-review`.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Feb 4](https://x.com/koylanai/status/2018865011356053927)

This is how I consume X and LinkedIn.

Cursor is my cockpit. MCPs connect everything: Zapier for actions, alphaXiv for papers, Browser Use for scraping posts, ElevenLabs for audio. All managed through custom Skills in my Digital Brain OS repo.

Just saw an Anthropic announcement.

![](https://pbs.twimg.com/amplify_video_thumb/2018862272915939328/img/c9nJe9_-WEOiECxp.jpg)

Scripts that output to stdout in agent-readable format close the loop between data and action. The weekly review script doesn't just tell me what happened -- it references my goals and identifies which key results are on track, which are behind, and what to prioritize next week. The scripts read from the same files the agent reads during normal operation, so there's no data duplication or synchronization problem.

https://x.com/koylanai/article/2025286163641118915/media/2025266035327197184After running the weekly review, the agent has everything it needs to update `todos.md` for next week, adjust `goals.yaml` progress numbers, and suggest content topics that align with underperforming key results. The review isn't a report -- it's the starting point for next week's planning. The automation creates a feedback loop: goals drive content, content drives metrics, metrics drive reviews, reviews drive goals.

### 5) WHAT I GOT WRONG AND WHAT I'D DO DIFFERENTLY

- ****I over-engineered the schema first pass. ****My initial JSONL schemas had 15+ fields per entry. Most were empty. Agents struggle with sparse data -- they try to fill in fields or comment on the absence. I cut schemas to 8-10 essential fields and added optional fields only when I actually had data for them. Simpler schemas, better agent behavior.
- ****The voice guide was too long at first. ****Version one of `tone-of-voice.md` was 1,200 lines. The agent would start strong, then drift by paragraph four as the voice instructions fell into the lost-in-middle zone. I restructured it to front-load the most distinctive patterns (signature phrases, banned words, opening patterns) in the first 100 lines, with extended examples further down. The critical rules need to be at the top, not the middle.
- ****Module boundaries matter more than you think.**** I initially had identity and brand in one module. The agent would load my entire bio when it only needed my banned words list. Splitting them into two modules cut token usage for voice-only tasks by 40%. Every module boundary is a loading decision. Get them wrong and you load too much or too little.
- ****Append-only is non-negotiable. ****I lost three months of post engagement data early on because an agent rewrote `posts.jsonl` instead of appending to it. JSONL's append-only pattern isn't just a convention -- it's a safety mechanism. The agent can add data. It cannot destroy data. This is the most important architectural decision in the system.

### 6) THE RESULTS AND THE PRINCIPLE BEHIND THEM

The real result is simpler than any metric. I open Cursor or Claude Code, start a conversation, and the AI already knows who I am, how I write, what I'm working on, and what I care about. It writes in my voice because my voice is encoded as structured data. It follows my priorities because my goals are in a YAML file it reads before suggesting what to work on. It manages my relationships because my contacts and interactions are in files it can query.

The principle behind all of it: this is context engineering, not prompt engineering. Prompt engineering asks "how do I phrase this question better?" Context engineering asks "what information does this AI need to make the right decision, and how do I structure that information so the model actually uses it?"

The shift is from optimizing individual interactions to designing information architecture. It's the difference between writing a good email and building a good filing system. One helps you once. The other helps you every time.

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Nov 9, 2025](https://x.com/koylanai/status/1987254288393916571)

Kimi K2 is a great writer, but it's hard to explain your taste to LLMs.

So, I built an AI interviewer that extracts your literary DNA.

12-question interview → structured profile → reusable prompt.

Open sourcing shortly.

https://x.com/koylanai/status/1987254288393916571/photo/1The entire system fits in a Git repository. Clone it to any machine, point any AI tool at it, and the operating system is running. Zero dependencies. Full portability. And because it's Git, every change is versioned, every decision is traceable, and nothing is ever truly lost.

Muratcan Koylan is Context Engineer at [Sully.ai](https://x.com//Sully.ai)

, where he designs context engineering systems for healthcare AI. His on-source work on context engineering (8,000+ GitHub stars) is cited in academic research alongside Anthropic. Previously AI Agent Systems Manager at 99Ravens AI, building multi-agent systems handling 10,000+ weekly interactions.

Framework: [Agent Skills for Context Engineering]([https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering)

)

https://x.com/koylanai****Muratcan Koylan****

@koylanai

·

[Dec 21, 2025](https://x.com/koylanai/status/2002797649842331919)

I’m excited to share a new repo: Agent Skills for Context Engineering

Instead of just offering a library of black-box tools, it acts as a "Meta-Agent" knowledge base. It provides a standard set of skills, written in markdown and code, that you can feed to an agent so it

https://x.com/koylanai/status/2002797649842331919/photo/1Quote

****Muratcan Koylan****

@koylanai

·

Dec 21, 2025

It’s actually a good question; the difference is subtle but structural. 

I usually frame it like this:
AGENTS[.]md acts as the declarative context. You write this for every repo (and nested directories) to define the project structure, persona, and coding rules.

Skills are the x.com/AAAzzam/status…

> Original article: https://x.com/i/article/2025249985722224640

### Article Screenshots

![](https://pbs.twimg.com/media/G9YcHGnW8AABl6q?format=jpg&name=small)

![](https://pbs.twimg.com/amplify_video_thumb/1975080002589691904/img/PKiTlWQ7nUuStWAD?format=jpg&name=240x240)

![](https://pbs.twimg.com/media/HBsn1YtWAAAhgKc?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/G76HOSwXgAAZaJB?format=jpg&name=small)

![](https://pbs.twimg.com/media/G7wtzSvX0AAYKCf?format=jpg&name=240x240)

![](https://pbs.twimg.com/media/G7wtzSvX0AAYKCf?format=jpg&name=small)

![](https://pbs.twimg.com/media/HBsoQRQXQAEVWn1?format=jpg&name=900x900)

![](https://pbs.twimg.com/amplify_video_thumb/1997438305894371329/img/Tn9XiH9Nui8tMyr7.jpg)

![](https://pbs.twimg.com/media/G7c8F_pWYAA5o2b?format=png&name=240x240)

![](https://pbs.twimg.com/media/HBsxNHyXYAATt1r?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HBspOASW0AA-E6d?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HBsqFxuW8AAdrU-?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HBSDv5aW8AAZaVZ?format=png&name=small)

![](https://pbs.twimg.com/amplify_video_thumb/1996899836021395456/img/tgLJMRKbjUv_MHUq.jpg)

![](https://pbs.twimg.com/media/G7XmZw0XsAAoB0S?format=jpg&name=small)

![](https://pbs.twimg.com/media/G7XoDGtW8AAr-U0?format=jpg&name=small)

![](https://pbs.twimg.com/media/HBsq81mXsAEoTyy?format=jpg&name=900x900)

![](https://pbs.twimg.com/amplify_video_thumb/2005080230134771712/img/sL0lQi7olj8DXhO3.jpg)

![](https://pbs.twimg.com/media/G9LBIxNXgAAQk-P?format=jpg&name=240x240)

![](https://pbs.twimg.com/media/HBsrS_2W8AAyLgY?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/G-DEzNFXkAALZ_Y?format=jpg&name=small)

![](https://pbs.twimg.com/media/HBsr1oBXwAAn6h5?format=jpg&name=900x900)

![](https://pbs.twimg.com/amplify_video_thumb/1975080002589691904/img/PKiTlWQ7nUuStWAD.jpg)

![](https://pbs.twimg.com/media/HBswXU_WsAAsCfg?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/HBsyXzAWwAAW89B?format=jpg&name=900x900)

![](https://pbs.twimg.com/amplify_video_thumb/2018862272915939328/img/c9nJe9_-WEOiECxp.jpg)

![](https://pbs.twimg.com/media/HBswupNXYAAJwVy?format=jpg&name=900x900)

![](https://pbs.twimg.com/media/G5QkwRlWIAAnUmD?format=png&name=small)

![](https://pbs.twimg.com/media/G8tds0UXoAAagSR?format=jpg&name=small)

---

## Commentary from Other Bookmarks

### @Hesamation (ℏεsam) - 2026-02-22

> this is one of the best technical articles i’ve read lately. what separates you from anyone else that’s using AI is your ability to steer the LLM and squeeze what you want from it, not what it decides to offer. commit to the long-term investment of recording your “taste”.

[View quote tweet](https://x.com/Hesamation/status/2025386547176956077)

