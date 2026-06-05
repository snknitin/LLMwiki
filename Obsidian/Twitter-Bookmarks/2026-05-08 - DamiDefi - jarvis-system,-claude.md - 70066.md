---
title: "JARVIS SYSTEM, CLAUDE.md"
author: "Dami-Defi"
username: "@DamiDefi"
date: "2026-05-08"
tweet_url: "https://x.com/DamiDefi/status/2052714650483970066"
tweet_type: "original"
likes: 213
retweets: 28
replies_count: 15
bookmarks: 322
views: 75646
has_media: false
article_id: "2052313324927258628"
tags: ["twitter-bookmark", "obsidian", "claude"]
---

# JARVIS SYSTEM, CLAUDE.md

> **Source:** [@DamiDefi](https://x.com/DamiDefi) - 2026-05-08 - Likes: 213 - Bookmarks: 322 - Views: 75646

> [View on X](https://x.com/DamiDefi/status/2052714650483970066)

## Article Content

Every Obsidian vault promises to capture your thinking. None of them do anything with it. What you are about to build is not a notes vault. It is JARVIS

You save an idea. It sits there. You save another. It sits next to the first one. Six months later you have a vault full of captures that never connected, never compounded, never produced anything you could not have written without them.

That is not a second brain. That is a filing cabinet with better search.

What you are about to build is different. It captures everything you think and notice. It finds connections across those captures automatically relationships you would never find manually. It turns those connections into content briefs before you sit down to write. And it gets more useful every single day because it reads your performance data alongside your content and learns what your audience actually responds to.

The difference between this system and every other Obsidian setup you have read about is one thing: this vault compounds. After 30 days it is smarter than it was on day one. After six months it knows your content better than any analytics dashboard because it is reading the ideas and the results together, not just the numbers.

It runs inside Obsidian. It is powered by Claude Code. Here is the full build.

### What You Are Actually Building

Before the setup steps, understand what you are building toward. Most people set up Obsidian and start capturing. Then they wonder why nothing comes out the other side.

This system has four jobs in sequence.

It captures everything you think, notice, and observe with zero friction. Raw. Unpolished. Speed over structure at capture time.

It connects ideas across your vault automatically. Not by keyword. By underlying principle. A note about how attention works psychologically and a note about why short-form content outperforms long-form on X can live in completely different folders and still find each other. That connection is where original content comes from.

It generates content briefs from those connections so you never start from blank. Hook written. Closer written. Source notes linked. The writing is the last step, not the first.

It closes the loop with performance data. Every piece you publish feeds back into the vault. What performed. What flopped. Which hook format outperformed its topic average. Over time the system uses that data to tell you what to write next not based on trends, based on your actual audience.

That is the system. Now here is how to build it.

### What You Need Before You Start

Obsidian download at obsidian.md. Free for personal use. Your notes are plain markdown files stored locally on your machine. Nothing is locked behind a subscription.

Claude Code install with:

npm install -g [@anthropic/claude-code](https://x.com/@anthropic/claude-code)

An Anthropic API key get one at [console.anthropic.com](https://x.com//console.anthropic.com)

. Set it in your terminal:

export ANTHROPIC_API_KEY=your_key_here

That is everything. No paid plugins. No third-party subscriptions beyond your Anthropic API usage.

### Step 1: Build the Vault Architecture

Open Obsidian. Create a new vault. Name it whatever you want. The folder structure matters more than the name.

Create this exact structure:

JARVIS/ ├── 00-INBOX/ ├── 01-CAPTURES/ │   ├── observations/ │   ├── reactions/ │   ├── patterns/ │   ├── questions/ │   └── numbers/ ├── 02-CONNECTIONS/ ├── 03-BRIEFS/ ├── 04-PUBLISHED/ └── 05-CLAUDE/ ├── CLAUDE.md ├── skills/ └── context/

Every folder has a single job. None of them overlap.

00-INBOX is where raw captures land. No organization at capture time. The goal is speed. You sort it later.

01-CAPTURES is organized by note type, not by topic. This is the most important architectural decision in the whole system. When you organize by topic, a note about AI content strategy and a note about how attention works psychologically never meet. When you organize by type, they both land in the patterns folder and Claude Code finds the connection between them automatically. Topic organization creates silos. Type organization creates collisions. You want collisions.

02-CONNECTIONS is where synthesized insights live. These are not raw captures. They are new ideas that emerge from the relationship between two or more captured notes. This is where your best content comes from. A note here should reference at least two source notes and say something neither of them says alone.

03-BRIEFS is your production queue. Every file in here is a piece of content ready to write. Hook written. Closer written. Source notes linked. Nothing in this folder should require creative work to execute, only craft.

04-PUBLISHED archives everything you have shipped with performance data attached. Impressions. Bookmarks. What worked. This is the memory layer that makes the system compound.

05-CLAUDE is the intelligence layer. This is where Claude Code lives when it is working inside your vault.

### Step 2: Install the Four Essential Plugins

Go to Settings in Obsidian. Community Plugins. Turn off Safe Mode. Browse.

Install these four and nothing else to start:

Templater runs dynamic templates with real logic inside them. You will use this for automated capture templates that tag and timestamp notes without you touching the metadata manually.

Dataview queries your vault like a database. Surfaces notes by tag, date, link count, or any property you define. This is how you ask questions like "show me every note tagged pattern from the last 14 days that has no connection yet."

QuickAdd captures a new note with one keyboard shortcut. Zero friction at capture time is non-negotiable. If opening a new note takes more than two seconds you will stop capturing.

Obsidian Git backs up your entire vault to GitHub automatically every hour. Set it once and never think about it again. Your vault is too valuable to trust to a single machine.

### Step 3: Build the CLAUDE.md File

This is the most important file in the system. Not the skills. Not the folder structure. This file.

CLAUDE.md tells Claude Code everything it needs to know about who you are, what your vault contains, how it is organized, and exactly what you want it to do when it works inside your vault. Without it, Claude Code treats your vault like a random folder. With a strong CLAUDE.md, it treats your vault like a system it has been managing for months.

The mistake most people make is filling this with vague placeholders and moving on. Vague CLAUDE.md files produce vague output. The voice section especially. Every line you write there directly determines how closely the output matches your actual writing.

Create this file at 05-CLAUDE/CLAUDE.md. The sections in brackets are the ones you must fill with real specifics, not descriptions of what specifics would look like:

## JARVIS SYSTEM, CLAUDE.md

### Identity

My name is [YOUR NAME]. I create content at the intersection of [YOUR TOPICS]. My audience is [DESCRIBE THEM SPECIFICALLY, not "people interested in X" but "builders and traders who are already using AI tools and want to go deeper"]. My content pillars are [LIST 2-3, be specific enough that two different pieces would clearly fall into different pillars].

### This Vault

This is my second brain and content production system. Every note is raw material for content, thinking, or decision-making. Nothing here is decoration. If a note has not been processed or connected in 30 days, flag it.

### Vault Structure

- 00-INBOX: unprocessed captures, always check here first before doing anything else
- 01-CAPTURES/observations: things I noticed, raw and unpolished
- 01-CAPTURES/reactions: my honest gut response to something I read or heard
- 01-CAPTURES/patterns: the same principle appearing in two different domains
- 01-CAPTURES/questions: things I genuinely do not know the answer to yet
- 01-CAPTURES/numbers: real data points, always includes the specific number and the source
- 02-CONNECTIONS: synthesized insights from two or more captured notes, references source notes always
- 03-BRIEFS: content ready to write, hook written, closer written, source notes linked
- 04-PUBLISHED: archived content with impression and bookmark data attached
- 05-CLAUDE: your working directory, read, write, and operate from here

### My Voice

[This section determines everything. Fill it with real instructions, not examples of what instructions would look like.]

Example of a weak voice section: "Conversational and direct. No fluff." Example of a strong voice section: "Short sentences. One idea per paragraph. Hard stops, not semicolons. Never use the word 'leverage' or 'utilize'. Real numbers always beat vague claims '443,000 impressions' not 'strong performance'. Every piece needs one line the reader will screenshot. The closer is written before the middle, always."

Write your actual voice instructions here. Pull from your best-performing posts if you are not sure what to say.

### Hard Rules

- Never read, access, or modify any .env files or files containing API keys
- Never modify files in 04-PUBLISHED without explicit instruction from me
- Never create folders outside the established structure without asking first
- Never use filler phrases like "it is worth noting" or "in conclusion" in any content you write for me
- When in doubt about which folder a note belongs in, ask before filing

### Your Primary Jobs

1. Process INBOX — read raw captures, sharpen them, file them correctly
2. Run connection sessions — find non-obvious relationships between recent captures
3. Generate briefs — turn strong connections into structured content briefs
4. Write content — produce finished posts in my exact voice from approved briefs
5. Log performance — update PUBLISHED notes when I provide data and surface patterns monthly

The more specific this file is, the more the system feels like it knows you. Spend 45 minutes on it before you move to the next step. It is the highest-leverage 45 minutes in this entire build.

### Step 4: Connect Claude Code to Your Vault

Open your terminal. Navigate to your Obsidian vault:

cd ~/path/to/your/JARVIS-vault

Launch Claude Code:

claude

Claude Code will automatically find your CLAUDE.md file and load everything in it as context for every conversation you have inside that directory.

Test it immediately with this prompt:

Read my CLAUDE.md and tell me in two sentences what you understand about this vault, then tell me one thing that is missing or unclear in my setup that would limit your effectiveness.

That second part matters. If Claude Code can identify a gap in your CLAUDE.md on the first read, your CLAUDE.md needs more work. A well-written file should produce a summary that is accurate enough to be useful and specific enough to be surprising.

If the summary is vague, your CLAUDE.md is vague. Go back and add specificity before moving on.

### Step 5: Build the Four Core Skills

A skill in Claude Code is a reusable workflow stored as a markdown file in your skills folder. You call it by name and Claude Code executes the full process every time without you re-explaining it.

Four skills cover 90 percent of everything this system does.

Skill 1: Process Inbox

Create 05-CLAUDE/skills/process-inbox.md:

## Skill: Process Inbox

### Trigger phrases

"process my inbox" / "run morning capture" / "clear the inbox"

### Process

1. Read every note in 00-INBOX/
2. For each note: a. Determine which CAPTURES subfolder it belongs in based on note type b. Sharpen the raw note into one punchy sentence specific enough that a stranger understands exactly what was observed without additional context c. Add exactly three tags content pillar, note type, and one topical tag d. Move the sharpened note to the correct subfolder with today's date in the filename
3. After processing all notes, deliver:Total notes processed and where each landed
Any patterns noticed across today's captures
One connection worth exploring between today's batch and anything in the last 14 days

### Quality bar

If the sharpened note still needs explanation it is not sharp enough. Rewrite it until it stands completely alone. A good sharpened note reads like a headline, not a sentence from a paragraph.

Here is what this looks like in practice. A raw capture might say: "noticed that the best performing posts this week all had a number in the first line." After the process-inbox skill runs, that becomes: "Posts with a specific number in the first line outperformed numberless hooks 3:1 this week across all content pillars." Tagged: content-performance, numbers, hook-strategy. Filed: 01-CAPTURES/numbers/2024-01-15-hook-numbers.md.

That is the difference between a capture and an asset.

Skill 2: Weekly Connections

Create 05-CLAUDE/skills/weekly-connections.md:

## Skill: Weekly Connections

### Trigger phrases

"run connection session" / "find this week's connections" / "weekly connections"

### Process

1. Read all notes added to 01-CAPTURES/ in the last 7 days
2. Search for connections across ALL subfolders simultaneously do not stay within one subfolder
3. A strong connection is one of these four types: TYPE A: Same underlying principle appearing in two different domains TYPE B: Contradiction between two notes that creates productive tension TYPE C: A pattern connecting three or more notes into one unnamed insight TYPE D: A question from one note that another note accidentally answers
4. For each strong connection found: a. Name the connection type b. Write one sentence that bridges the two ideas this is the thesis of a potential piece c. Write one potential content hook using this connection d. Create a new note in 02-CONNECTIONS/ that links both source notes

### Quality bar

If the connection is obvious it does not qualify. Only surface connections that would genuinely surprise the person who wrote the notes. Minimum: 3 connections. Maximum: 5. Quality over quantity, always. A useful test: would the writer have found this connection themselves eventually? If yes, it is too obvious. The system earns its keep by finding what the writer would miss.

This is the most important skill in the system. A connection session run on a full week of captures will surface ideas that feel genuinely original because they are they come from the intersection of things you noticed separately, not from trying to think of something new.

Skill 3: Generate Brief

Create 05-CLAUDE/skills/generate-brief.md:

## Skill: Generate Brief

### Trigger phrases

"generate a brief for [topic]" / "brief this connection" / "make a brief"

### Process

Create a content brief with exactly these five fields:

ONE THING The single insight this piece is built around. One sentence maximum. If it cannot be stated in one sentence the idea is not ready. Push back if the one thing is fuzzy.

PROOF The most specific real example, number, or result that proves the one thing. Vague proof invalidates the brief. "Performed well" is not proof. "443,000 impressions and 11,678 bookmarks" is proof.

READER TRANSFORMATION What does the reader know or believe at the end that they did not before? If this cannot be stated clearly the piece has no reason to exist.

THREE HOOKS (ranked by scroll-stopping power) Hook one: aggressive challenges an assumption the reader holds right now Hook two: curious surfaces something the reader did not know they wanted to know Hook three: personal specific result or experience that proves the one thing

THREE CLOSERS (ranked by urgency and memorability) The closer is written before the middle. Always. Rank by how much the reader feels behind after reading it.

### Output

Save as a new note in 03-BRIEFS/ with today's date and topic as the filename. Tag it [#ready](https://x.com/search?q=%23ready&src=hashtag_click)

-to-write

Skill 4: Write Content

Create 05-CLAUDE/skills/write-content.md:

## Skill: Write Content

### Trigger phrases

"write the brief for [topic]" / "write this brief" / "produce content from brief"

### Process

1. Read the specified brief from 03-BRIEFS/
2. Read all source notes linked in the brief
3. Write the full piece using the voice instructions in CLAUDE.md exactly
4. Structure: hook, proof, body, closer in that order
5. Every paragraph adds specific value. If a paragraph could be cut without the reader noticing, cut it.
6. Include at least two real prompt examples or concrete build steps where the topic calls for it
7. End with the standard CTA

### Voice check before delivering

Read the draft against the voice section of CLAUDE.md. Flag any sentence that sounds like it came from a generic AI writing tool. Rewrite flagged sentences before delivering. The output should be indistinguishable from something the writer produced themselves.

### Output

Save the draft in 03-BRIEFS/ next to the source brief. Tag it [#written](https://x.com/search?q=%23written&src=hashtag_click)

### Step 6: The Daily 20-Minute Ritual

This is how the system runs every morning. The order matters.

Minutes 1 to 5 capture. Before you open anything else, add raw captures to 00-INBOX. Voice memo transcriptions. Something you noticed during your commute. A number you saw. A reaction you had to something you read last night. Raw and unpolished. The goal is to get it in before the day overwrites it.

Minutes 6 to 10 process. Run the process inbox skill. Read the report. Note what got filed and what patterns Claude Code noticed across today's batch.

Minutes 11 to 15 connect. Ask:

Are there any strong connections between today's captures and anything in my vault from the last 14 days?

This is the moment where the system earns its name. You are asking it to think across your entire recent history and surface what belongs together. The answer is usually one thing. That one thing is usually the most original idea you will encounter that day.

Minutes 16 to 20 brief. Run the brief skill on whichever connection surprised you most. By minute 20 you have a fully structured content brief with three hooks and three closers ready before you have opened a single social media platform.

The rest of the day is execution, not ideation.

### Step 7: The Weekly Connection Session

Every Sunday run this in full:

Run the weekly connections skill on all captures from the last 7 days.

Let Claude Code read the full week of captures across all subfolders at once. The connections it surfaces from a full week of inputs will be stronger and more surprising than anything the daily session finds. Daily connections come from adjacent notes. Weekly connections come from ideas that seemed unrelated until they were all in the same room.

Review the connection notes created in 02-CONNECTIONS. Pick the two strongest. Run the brief skill on both.

You now have two fully briefed content pieces ready to write before Monday morning. Neither of them started as a deliberate attempt to think of something to write. Both of them came from things you noticed during the week, connected by the system while you were doing other things.

### Step 8: The Performance Loop That Makes Everything Compound

This is the step that separates this system from every other second brain setup you have read about. Most vaults capture and retrieve. This one learns.

Every time a piece of content performs, open the corresponding note in 04-PUBLISHED and log the data:

impressions: 443,000 bookmarks: 11,678 engagement_rate: 0.04% hook_used: [paste the exact hook that ran] top_comment: [paste the comment that generated the most replies] what_worked: [your honest one-line assessment of why this performed]

Once a month run this session:

Read everything in my 04-PUBLISHED folder.

Tell me:

1. Which topics drove the most bookmarks per impression not just impressions
2. Which hook formats outperformed their topic average
3. What three content angles my best performing posts suggest I have not tried yet
4. Which topic and format combinations I should double down on this month

Only give me insights that come directly from the data in this vault. No generic content advice. Only patterns specific to my actual performance.

The reason this prompt specifies "bookmarks per impression" rather than raw impressions is signal quality. Impressions measure reach. Bookmarks measure whether the reader intended to return. A post with 50,000 impressions and 2,000 bookmarks tells you more about what your audience values than a post with 500,000 impressions and 400 bookmarks.

After six months of consistent logging, this monthly session becomes the most valuable 30 minutes in your content operation. The vault is reading your ideas and your results simultaneously. It surfaces patterns you would never find by looking at a dashboard because dashboards show you numbers without context. This shows you what the content actually was, who responded, and what they said all at once.

That is what makes it compound. Not the capture. Not the connection. The loop.

### What Breaks and What to Watch

Three things will go wrong and it is better to know about them now.

The vault gets noisy if you stop sharpening captures. Raw notes that never got processed accumulate in INBOX and the connection sessions start surfacing obvious relationships instead of surprising ones. The fix is ruthless: anything in INBOX older than 48 hours that has not been processed gets deleted, not filed. If it was worth keeping you will encounter the idea again.

Claude Code loses context in long sessions. If you are running a connection session on a large vault and the session has been open for an hour, the output quality drops. The fix is simple: close the session and reopen it before running any skill that requires reading across the full vault. Fresh context produces sharper connections.

The CLAUDE.md drifts from your actual voice over time. As your writing evolves, the instructions in your CLAUDE.md need to evolve with them. Every 60 days, read a piece of content the system produced and compare it against your most recent original writing. If the gap is widening, update the voice section before you do anything else.

### What the System Produces Over Time

After 30 days you will notice you are never stuck for ideas. The brief queue in 03-BRIEFS will have more ready-to-write pieces than you have time to execute.

After 90 days the connections will start to surprise you. The system will surface relationships between things you wrote three months apart that you had completely forgotten about. Those connections produce the most original content you will make because they could not have come from deliberate ideation. They came from the accumulated record of what you actually noticed over time.

After six months the performance loop will start telling you things your own instincts would have taken years to learn. Not trends. Not what is working for other people in your space. What is working for your specific voice with your specific audience based on your actual numbers.

Most people are starting from zero every day.

Every day you run this system you are starting from everything you have ever noticed, connected, and shipped.

That gap does not stay small for long.

Follow [@damidefi](https://x.com/@damidefi)

 on X for daily Claude AI tools, crypto analysis, and the full journey to 100K. Bookmark this. Share it with one person building something.

> Original article: https://x.com/i/article/2052313324927258628

---

## Commentary from Other Bookmarks

### @alphabatcher (Alpha Batcher) - 2026-05-08

> Most Obsidian vaults fail at the same place:
> 
> capture works, return never happens.
> 
> You save ideas, highlights, numbers, hooks, screenshots.
> 
> Then 6 months later the vault has 400 notes and no idea what to write next.
> 
> Build the return path instead:
> 
> 1. Use 5 folders
> 
> 00-INBOX
> 01-CAPTURES
> 02-CONNECTIONS
> 03-BRIEFS
> 04-PUBLISHED
> 
> 2. Sort captures by type, not topic
> 
> > observations
> > reactions
> > patterns
> > questions
> > numbers
> 
> Topic folders hide useful collisions. Type folders help Claude connect "attention psychology" to "X hook performance."
> 
> 3. Put Claude Code files where Claude actually reads them
> 
> > ./CLAUDE.md or ./.claude/CLAUDE.md
> > .claude/skills/process-inbox/SKILL.md
> > .claude/skills/weekly-connections/SKILL.md
> > .claude/skills/generate-brief/SKILL.md
> > .claude/skills/write-content/SKILL.md
> 
> 4. Log performance in every published post
> 
> > impressions
> > bookmarks
> > hook_used
> > top_comment
> > what_worked
> 
> Build the path that turns saved notes into briefs, posts, and performance data:
> 
> capture -> connection -> brief -> post -> result -> next brief

[View quote tweet](https://x.com/alphabatcher/status/2052753374160838896)

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2052751586602971144/img/5p64bc3PbKDCaL5T.jpg)

[Watch video](https://video.twimg.com/amplify_video/2052751586602971144/vid/avc1/640x360/4l4SuTjgfLkSz3KL.mp4?tag=27)

*Video - see MEDIA-REVIEW.md*

