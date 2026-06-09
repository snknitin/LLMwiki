---
title: "Yapping to PRDs: Claude Code & Obsidian"
source: "https://x.com/arscontexta/status/2013718955576250466"
author:
  - "[[@arscontexta]]"
published: 2026-01-21
created: 2026-06-09
description: "meetings used to be overhead, now yapping is workwhen my coworker and i yap about a project we record itan hour later the transcript gets pr..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/G_InEPfXAAIsk7Q?format=jpg&name=large)

meetings used to be overhead, now yapping is work

when my coworker and i yap about a project we record it

an hour later the transcript gets processed and suddenly theres documentation, feature ideas in the backlog, decisions captured with their reasoning, the project status updated and even a few notes about our working philosophy got extracted

everything is connected with wikilinks to all the notes we had before

(ralph is also happy because he gets his polished PRDs right after the meeting)

![Image](https://pbs.twimg.com/media/G_InNlNWQAElKO9?format=jpg&name=large)

this is what a processed project structure could look like:

```markdown
team-vault/
├── 01_Inbox/
│   └── README.md
├── 02_Projects/
│   ├── README.md
│   ├── Habit-Tracker-App/
│   │   ├── Habit-Tracker-App.md
│   │   ├── Ideas/
│   │   │   ├── Streak Notifications.md
│   │   │   └── Social Accountability.md
│   │   └── Meetings/
│   │       ├── 2026-01-08 Kickoff.md
│   │       └── 2026-01-15 MVP Scope.md
│   ├── Recipe-Manager/
│   │   ├── Recipe-Manager.md
│   │   ├── Docs/
│   │   │   └── Database Schema.md
│   │   ├── Ideas/
│   │   │   └── AI Meal Planning.md
│   │   └── Meetings/
│   │       └── 2026-01-12 Feature Prioritization.md
│   └── Workout-Logger/
│       ├── Workout-Logger.md
│       └── Meetings/
│           └── 2026-01-10 Technical Planning.md
├── 03_Areas/
│   ├── README.md
│   ├── Design-System/
│   │   └── Component Library.md
│   ├── Infrastructure/
│   │   ├── Deployment Pipeline.md
│   │   └── Monitoring Setup.md
│   └── User-Research/
│       └── Interview Insights.md
├── 04_Knowledge/
│   ├── README.md
│   ├── Frameworks/
│   │   └── React Native Patterns.md
│   └── Tools/
│       └── Supabase.md
├── 05_Archive/
│   ├── README.md
│   └── Transcripts/
│       ├── 2026-01-08 Kickoff Transcript.md
│       ├── 2026-01-10 Technical Planning Transcript.md
│       ├── 2026-01-12 Feature Prioritization Transcript.md
│       └── 2026-01-15 MVP Scope Transcript.md
└── CLAUDE.md
```

these are not random meeting summaries

this is a structured system where every piece of knowledge lives in a specific place and wikilinks connect ideas across the whole network

(the folder system is basically the PARA system from tiago forte which is usually thought for personal knowledge management but works great for team projects too)

whats the most efficient way to build this?

transcript mining

ill break down the command i use for this at the end

## documentation is for agents now

this only works if you learn to manage context and structure knowledge for retrieval so claude can actually find what it needs

when claude needs to understand your deployment setup it loads \`03\_Areas/Infrastructure/Deployment Pipeline\`, when it needs the database schema it loads \`02\_Projects/Recipe-Manager/Docs/Database Schema\`, when it needs to understand a past decision it loads the meeting where you discussed it

everything is defined in claude md which tells claude the vault philosophy, folder structure, how to navigate and how to take notes

each folder has a README that goes deeper into that specific folder philosphy (more on this setup in another post)

without structure you just have a pile of meeting notes

with structure you have a knowledge system that claude can build on

and most importantly that you can build on together with claude

feature brainstorming becomes way better when claude has all the context, all the ideas youve had before, all the decisions youve made, all the competitor research and all the user feedback

product steering becomes a real conversation when the context window is decorated with everything relevant

thats what i mean by ars contexta

## why yapping?

when people say llms arent there yet its usually a context problem

the knowledge exists somewhere but the model cant access it

some of that is locked in slide decks and pdfs

but thats basically solved with vision models now

the harder problem is tacit knowledge

the stuff thats hard to articulate because it lives in your head as intuition

i noticed this when building automated note-taking systems

my philosophy of how i write notes, connect them and structure knowledge was way more complex than i thought and a lot of it happened subconsciously

i couldnt write it down because i didnt know i was doing it

transcripts help to externalize that

when you talk through something you naturally include your reasoning path, your uncertainties, the alternatives you considered

you explain things in depth because youre responding to another person

all of that becomes capturable context

## the command

this is what a command like this could look like but to work efficiently it needs a LOT of your note taking philosophy in the claude md as well

the core idea is simple: this is mining not summarizing

a rich 1-hour meeting can yield 10+ ideas, multiple frameworks, a dozen decisions and state changes across multiple projects

if youre producing a short summary with 3-4 bullet points youre not going deep enough

first i like to define a role:

```markdown
<role>
you are the knowledge architect for this vault. 

you process meeting transcripts with exhaustive depth, mining every valuable insight, idea, philosophy, decision and status update.

meetings are the primary sync mechanism between reality and vault state. 

missing content is unacceptable.
</role>
```

then tell it what to look for:

```markdown
as you read, actively hunt for:

- feature ideas ("wouldnt it be cool if...", "we could also...")
- project sparks (new tool concepts, standalone initiatives)
- frameworks (mental models, principles, ways of thinking)
- philosophies (team beliefs, working principles)
- decisions (explicit choices made, direction set)
- status updates ("X is now live", "Y is on hold")
- action items (tasks assigned, next steps)
- blockers (what is preventing progress)

look for implicit content too:
- ideas embedded in problem discussions ("the issue is we dont have X" → X is an idea)
- philosophies expressed as asides ("we always say..." → philosophy)
- decisions made by NOT deciding ("lets not wait for..." → decision)
```

before writing anything make it plan all extractions:

```markdown
before writing anything, plan all extractions:

example todo list for a complex meeting:
1. archive raw transcript
2. create meeting summary
3. update project A status (now live)
4. update project B status (blocked on X)
5. create idea: feature X for project A
6. create idea: feature Y for project A
7. create idea: new tool concept Z
8. add philosophy to team hub
9. update project hubs with new decisions
```

the key insight is vault state synchronization

```markdown
meetings reveal new reality. update the vault to match.

for each project mentioned:
1. read the current hub to understand existing state
2. identify discrepancies between hub and meeting discussion
3. update status if changed (active → paused, prototype → live)
4. add decisions to key decisions section
5. add meeting link to recent meetings
6. link new ideas in ideas section
```

and set quality standards so it doesnt just skim:

```markdown
before marking processing complete, verify:

- read entire transcript (no skimming)
- all explicit decisions captured
- all implicit decisions captured
- all feature ideas extracted (even casual mentions)
- all frameworks/philosophies captured
- all status changes reflected in project hubs
- state sync complete (vault reflects post-meeting reality)

red flags (processing incomplete):
- meeting summary is shorter than 1 page for hour+ meeting
- only 1-2 ideas extracted from brainstorming discussion
- no state changes identified in status-heavy meeting
```

what does good output look like?

for a 1h 20m weekly coordination meeting:

- 1 archived transcript
- 1 comprehensive meeting summary
- 7 feature idea notes across multiple projects
- 2 framework notes
- 4 philosophy additions to team hub
- 3 project hub status updates
- 9 hub updates across projects and areas
- 20+ files created or modified

yapping IS work

heinrich