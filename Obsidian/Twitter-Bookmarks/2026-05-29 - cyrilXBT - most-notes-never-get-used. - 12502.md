---
title: "Most notes never get used."
author: "CyrilXBT"
username: "@cyrilXBT"
date: "2026-05-29"
tweet_url: "https://x.com/cyrilXBT/status/2060163007783612502"
tweet_type: "original"
likes: 918
retweets: 115
replies_count: 28
bookmarks: 2722
views: 863614
has_media: false
article_id: "2059468437504602112"
tags: ["twitter-bookmark", "obsidian", "claude"]
---

# Most notes never get used.

> **Source:** [@cyrilXBT](https://x.com/cyrilXBT) - 2026-05-29 - Likes: 918 - Bookmarks: 2722 - Views: 863614

> [View on X](https://x.com/cyrilXBT/status/2060163007783612502)

## Article Content

Most notes never get used.

Not because the information was not valuable when you captured it.

Because capturing and using are two completely different activities and almost every note-taking system optimizes for the first one while completely ignoring the second.

You read an interesting article. You take a note. The note sits in a folder. Six months later you search for something vaguely related and find the note by accident. You read it, think "I should have remembered this," and move on.

The note never became anything.

The Obsidian system in this guide is designed from the opposite end.

Instead of asking how do I capture this information it asks how will I use this information.

Every structural decision, every workflow, every Claude integration is optimized for one outcome: notes that produce output, inform decisions, and compound into genuine intelligence rather than accumulating as an expensive archive.

### The Gap Between Capturing and Using

Before the build understand why the gap exists.

Capturing is easy because it has no stakes.

You highlight a passage, write a quick note, and save it somewhere. The act feels productive. You have not lost the information. It is safe.

Using requires something harder. It requires you to actively retrieve specific information at the moment you need it, synthesize it with what you currently know, and turn it into something: a decision, a piece of writing, an action, a framework.

The gap between capturing and using is the gap between passive collection and active synthesis.

Most note-taking systems are designed for collection. Files, folders, tags, search. All of it optimized for the moment of capture and the retrieval of specific information you already know exists.

The system in this guide is designed for synthesis. It is built around the question: what should I produce from what I know, and how does the system surface the right information at the right moment to make that production possible.

### The Four Uses Every Note Should Have

Start by defining what using a note actually means.

A note has been used when it contributes to one of four outcomes.

****Decision support.**** The note surfaces when you are making a decision and provides relevant context, evidence, or perspective that improves the quality of the decision.

****Writing fuel.**** The note contributes content, evidence, structure, or insight to something you are writing: an article, a report, an email, a proposal.

****Conversation material.**** The note gives you something specific to say in a conversation, meeting, or presentation that you would not have had without it.

****Action trigger.**** The note surfaces an idea or information at the moment when acting on it is possible, rather than at the random moment you happened to capture it.

Every note in your vault should be able to contribute to at least one of these four outcomes.

Notes that cannot contribute to any of them should not be in your vault.

This is a more demanding standard than most systems apply.

It is also the standard that separates a vault that compounds from a vault that accumulates.

### The Architecture: Three Zones

The system has three zones. Each zone holds a different type of note at a different stage of processing. Notes move through the zones as they become more useful.

****Zone 1: Capture****

Raw material. Everything that might be worth using but has not been processed into a usable form yet. The inbox of your thinking.

Notes in Zone 1 are not useful yet. They are candidates for usefulness.

****Zone 2: Active****

Processed notes that are immediately useful. Permanent notes written in your own words. Project notes connected to active work. Reference notes organized for retrieval.

Notes in Zone 2 are useful now. They contain your understanding, not just your captures.

****Zone 3: Deep Archive****

Completed projects. Resolved decisions. Historical records. Notes that are no longer immediately useful but contain information worth preserving for future reference.

Notes in Zone 3 are potentially useful in the future. They are indexed for retrieval but not actively maintained.

VAULT/
    00 - CAPTURE/
        [raw unprocessed captures]
    
    01 - ACTIVE/
        permanent/
            [atomic notes in your own words]
        projects/
            [current project folders]
        decisions/
            [active decisions being made]
        references/
            [information you retrieve regularly]
    
    02 - ARCHIVE/
        projects/
        decisions/
        references/
    
    03 - OUTPUT/
        writing/
        [finished pieces produced from notes]
    
    04 - SYSTEM/
        CLAUDE.md
        skills/
        templates/

The Output folder is what most note-taking systems never include.

It is where finished work lives. The articles, reports, decisions, and frameworks that your notes contributed to.

Including the Output folder in your vault creates a visible connection between the notes you capture and the work they produce. Over time it shows you which notes were generative and which were never used, informing how you capture in the future.

### The CLAUDE.md That Makes Notes Useful

The CLAUDE.md is the document that tells Claude what usefulness means for you specifically.

# Note Usage System — CLAUDE.md

## What I Use Notes For
Primary: [YOUR PRIMARY USE CASE — writing/decisions/work/research]
Secondary: [YOUR SECONDARY USE CASE]
What I produce: [WHAT YOU CREATE WITH YOUR KNOWLEDGE]

## My Active Projects
[LIST ACTIVE PROJECTS THAT NOTES SHOULD FEED INTO]

## Current Active Decisions
[LIST DECISIONS YOU ARE CURRENTLY MAKING]
[These are the questions your notes should be answering right now]

## My Writing Topics
[TOPICS YOU WRITE ABOUT REGULARLY]
[When processing notes, connect them to these topics]

## What Makes a Note Useful For Me
Useful: [SPECIFIC DESCRIPTION OF USEFUL NOTES FOR YOUR CONTEXT]
Not useful: [SPECIFIC DESCRIPTION OF NOTES THAT NEVER GET USED]

## Processing Standards
A note is ready for Zone 2 when:
- It is written in my own words not copied from a source
- It connects to at least one other note in Zone 2
- It could contribute to at least one active project or decision
- It has a clear title that describes the idea not the source

A note should be archived when:
- The project or decision it related to is complete
- The information is outdated
- It has never been accessed in 6 months

## Output Goals
[WHAT YOU WANT TO PRODUCE FROM YOUR NOTES]
[Be specific: "one article per week on AI topics" or 
"monthly decision reviews for my team"]

### The Five Workflows That Turn Notes Into Output

Five workflows form the active production layer of the system. Each one converts passive notes into active output.

Workflow 1: The Daily Processing Run

Every evening this workflow processes notes that accumulated in Zone 1 during the day.

The goal is not to file everything neatly. The goal is to identify what is worth processing into Zone 2 and to make the connections that make future retrieval automatic.

The Claude prompt:

Process all notes in 00 - CAPTURE from today.

For each captured note:

1. USEFULNESS ASSESSMENT
   Can this note contribute to:
   - Any active project listed in CLAUDE.md?
   - Any active decision listed in CLAUDE.md?
   - Any writing topic listed in CLAUDE.md?
   
   If yes to any: mark as PROCESS
   If no to any: mark as ARCHIVE DIRECTLY

2. FOR NOTES MARKED PROCESS
   Rewrite the note in my own words.
   Not a summary of the source. My understanding 
   of the idea in my voice.
   
   Then identify:
   - What existing permanent notes does this connect to?
   - Which active project or decision does it feed?
   - What is the most likely future use case?

3. CREATE PERMANENT NOTE
   Title: the idea, not the source
   Content: my understanding in my words
   Links: connections to existing permanent notes
   Tags: relevant active projects and topics

4. ARCHIVE ORIGINAL CAPTURE
   Move the raw capture to 02 - ARCHIVE

5. LOG
   Report what was processed, what was archived 
   directly, and what connections were made.

Workflow 2: The Active Decision Feeder

Every time you open a decision note or ask a question about a current decision, this workflow scans your entire vault for relevant information.

I am working on this decision: [DECISION DESCRIPTION]

Scan all of Zone 2 in my vault.

Find every note that is relevant to this decision.
Not just notes explicitly tagged with this decision.
Notes that contain information, perspectives, or 
evidence that a thoughtful person would consider 
when making this decision.

For each relevant note found:
- State the note title
- State what the note contains that is relevant
- State whether it supports, challenges, or 
  adds nuance to the decision

Then synthesize everything relevant into a 
decision brief that gives me the full picture 
of what my accumulated notes know about this topic.

Do not add information from outside my vault.
Only synthesize what is already in my notes.

This workflow embodies the core principle of the system. The answer to your current question might already be in your past captures. Claude reads across them and surfaces it.

Workflow 3: The Writing Activator

Before starting any piece of writing, trigger this workflow:

I am about to write about: [TOPIC/TITLE]

Scan Zone 2 of my vault for everything relevant.

Produce a writing brief containing:

STRONGEST ARGUMENT: The most defensible claim 
my notes support on this topic.

EVIDENCE: Specific notes that provide evidence 
for that argument with note titles.

COUNTERARGUMENTS: Notes that challenge or 
complicate the argument.

SPECIFIC DETAILS: Any specific statistics, 
examples, or quotes in my notes that belong in this piece.

GAPS: What is missing from my notes that I should 
research before writing.

STRUCTURE SUGGESTION: Based on what my notes 
contain, what structure would make the strongest piece.

Do not suggest what I should write. 
Show me what my notes already know.

Writing from this brief is fundamentally different from writing from scratch. You are articulating what you already know rather than trying to generate ideas in real time.

Workflow 4: The Connection Surface

Once per week this workflow scans all notes created in the past seven days and finds connections to older notes.

Read all permanent notes created or modified 
in the last 7 days.

For each new note, scan the entire Zone 2 vault 
for existing notes that share a meaningful connection.

Meaningful connections include:
- The same underlying principle applied in 
  different domains
- Contradictory claims worth examining together
- One note providing evidence for or against 
  a claim in another
- A pattern that appears across multiple notes 
  that no individual note names explicitly

For each connection found:
- Name both notes
- Describe the specific connection
- Explain why connecting them would make 
  both notes more useful

Only surface connections that are genuinely 
non-obvious. Skip anything already linked.

This is the workflow that makes the vault compound. Connections you did not intentionally create become visible when Claude reads across your full knowledge base.

Workflow 5: The Output Generator

When a piece of writing, a decision summary, or a project report is ready to produce, this workflow synthesizes the notes into the finished output.

I need to produce: [OUTPUT TYPE AND DESCRIPTION]

Read all notes tagged with [PROJECT/TOPIC] 
in Zone 2 of my vault.

Also read any notes the Connection Surface 
has linked to this topic.

Produce a complete draft of [OUTPUT TYPE] 
that:
- Uses only information from my vault notes
- Is written in my voice as described in CLAUDE.md
- Synthesizes across notes rather than 
  summarizing each one
- Produces an insight that no individual note 
  contains but that the combination of notes supports

Save the draft to 03 - OUTPUT/[FOLDER]/[DATE]-[TITLE].md

The Output Generator is the moment the entire system justifies itself. Months of captured notes synthesized into a finished piece in minutes rather than hours.

### The Capture Conventions That Make Notes Usable

The processing workflows only work if captures are rich enough to process.

Three capture conventions dramatically improve the usability of everything you take in.

****The Connection Capture****

When you capture something, note the connection that made it worth capturing:

[THE IDEA OR INFORMATION]
CONNECTS TO: [What this reminds you of or relates to]
MIGHT USE FOR: [The first use case that comes to mind]

This three-part capture takes thirty additional seconds and doubles the value of the note because it preserves the context of relevance that was present at capture time.

****The Question Capture****

When a note prompts a question, capture the question explicitly:

[THE INFORMATION]
THIS RAISES THE QUESTION: [The question this generates]

Questions are often more useful than answers in a knowledge system. The question surface workflow can search for notes that might answer your captured questions.

****The Application Capture****

When a note has an immediate application, capture the application:

[THE IDEA]
COULD APPLY TO: [Specific situation in your current work]
ACTION IF TRUE: [What you would do if this idea is correct]

Application captures are the ones most likely to trigger actual use. They come pre-loaded with the use case that makes retrieval automatic.

### The Weekly Note Audit

Once per week a brief audit identifies notes that have been sitting in Zone 2 without being used.

Read all permanent notes in Zone 2 that have not 
been accessed in the last 14 days.

For each unaccessed note:

1. Can this note contribute to any active project 
   or decision in my CLAUDE.md?
   If yes: create a connection note in the relevant 
   project folder pointing to this permanent note.
   
2. Does this note connect to anything in active 
   production in Zone 2?
   If yes: add the link.
   
3. If the note connects to nothing active: 
   flag it with REVIEW tag.

REVIEW-tagged notes get one more chance in the 
following week's audit. If still disconnected 
after two consecutive audits: archive them.

The audit enforces the core principle. Notes that do not connect to anything active are not currently useful. They belong in the archive until something makes them relevant.

### What Happens After 90 Days

The gap between the system in week one and the system in month three is significant.

At week one you have a structured vault with five workflows and a CLAUDE.md. The workflows produce outputs but the vault does not have enough accumulated notes for the connection surfaces to surface surprising results.

At month two the Connection Surface starts producing genuinely useful links. Notes you wrote about one topic connect to notes you wrote about a different topic in ways you did not consciously intend. The Writing Activator starts producing briefs that contain material you had forgotten you captured.

At month three the Decision Feeder becomes the most valuable workflow in the system. You are making a decision and Claude finds eight notes across three months of captures that all bear on the decision. Notes from different contexts, different sources, different weeks. All relevant. None of which you would have manually retrieved.

At month six the Output folder has enough finished pieces that you can see which notes were generative and which were never used. You update your capture conventions to capture more of what has been generative and less of what has been consistently unused.

The system is not just accumulating knowledge.

It is learning what kind of knowledge is useful for you.

That calibration is what separates a system that compounds from one that just grows.

### The Only Metric That Matters

Most people measure their note-taking system by the number of notes they have.

The only metric that matters is the number of times a note contributed to something.

A vault with 500 notes that each contributed to a decision, a piece of writing, or an action is dramatically more valuable than a vault with 5,000 notes that were captured and never used again.

The system in this guide is designed around the second metric.

Every workflow is designed to increase the contribution rate of captured notes.

Every capture convention is designed to preserve the context that makes future contribution possible.

Every Claude integration is designed to surface the right note at the right moment rather than requiring you to know it exists and remember to search for it.

Build this system and you will find yourself writing faster, deciding better, and acting on knowledge you would previously have captured and forgotten.

That is what a note-taking system is actually for.

Build it this weekend.

The contribution rate compounds from the first processed note.

Follow [@cyrilXBT](https://x.com/@cyrilXBT)

 for every Obsidian system, Claude integration, and knowledge architecture that makes your notes compound into genuine output.

> Original article: https://x.com/i/article/2059468437504602112

---

## Commentary from Other Bookmarks

### @leopardracer (leopardracer) - 2026-05-29

> THIS CHINESE DEVELOPER’S NEURAL NETWORK VISUALIZATION IS EXACTLY HOW YOUR OBSIDIAN VAULT SHOULD WORK
> 
> every node connects to every other node and the whole thing gets smarter the more data flows through it, same way a real knowledge system should work but almost nobody builds it like that
> 
> most people throw everything into folders and tags and call it a second brain but what they actually built is an archive that gets harder to use every month
> 
> claude reads across everything you ever captured and finds the connection you need right when you need it
> 
> here’s how to build the version that actually compounds ↓

[View quote tweet](https://x.com/leopardracer/status/2060291475036889506)

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/2060291384645459973/img/gNoP6JYEeSkc6Nf_.jpg)

[Watch video](https://video.twimg.com/amplify_video/2060291384645459973/vid/avc1/576x1024/CJbZUJcSGKb-pYJm.mp4?tag=27)

*Video - see MEDIA-REVIEW.md*

