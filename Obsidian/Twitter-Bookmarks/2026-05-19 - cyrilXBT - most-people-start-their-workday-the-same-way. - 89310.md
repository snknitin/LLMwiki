---
title: "Most people start their workday the same way."
author: "CyrilXBT"
username: "@cyrilXBT"
date: "2026-05-19"
tweet_url: "https://x.com/cyrilXBT/status/2056555832805089310"
tweet_type: "original"
likes: 1185
retweets: 135
replies_count: 37
bookmarks: 3004
views: 407594
has_media: false
article_id: "2056174105821401090"
tags: ["twitter-bookmark", "obsidian", "claude", "mcp"]
---

# Most people start their workday the same way.

> **Source:** [@cyrilXBT](https://x.com/cyrilXBT) - 2026-05-19 - Likes: 1185 - Bookmarks: 3004 - Views: 407594

> [View on X](https://x.com/cyrilXBT/status/2056555832805089310)

## Article Content

Most people start their workday the same way.

Open email. Check Slack. Browse through project folders trying to remember where things stand. Pull up the calendar. Check the task list. Try to mentally assemble a picture of what actually needs to happen today.

Forty-five minutes later you have a rough sense of your priorities and the morning is already compromised.

The problem is not that the information does not exist.

It exists in your project notes. Your client files. Your daily notes. Your task list. Your calendar.

The problem is that accessing it requires you to be the integration layer between all of it.

You are the system that connects the information.

The Obsidian dashboard removes you from that role.

It pulls every piece of relevant information from across your vault and surfaces it in one place before you open a single project file.

You open one note. You see everything that matters today. You start working.

This guide is the complete build from zero to a fully operational dashboard that updates itself automatically and connects to Claude Code for intelligent morning briefings.

### The Core Principle: Read Not Store

Before you write a single query understand what an Obsidian dashboard is and is not.

A dashboard is not another place to put information.

It is a single note that reads information from everywhere else in your vault and displays what is relevant right now.

This distinction is what makes the dashboard valuable.

Because the dashboard reads from your other notes rather than storing its own information, you never have to maintain it manually. You update your project files, your client notes, and your daily notes the way you always have. The dashboard reflects those updates automatically every time you open it.

The dashboard has no content of its own.

It has queries.

Each query pulls specific information from specific parts of your vault based on rules you define.

When the underlying notes change the dashboard changes.

You do one update in one place. The dashboard stays current everywhere it references that information.

### What the Dashboard Shows

A complete business dashboard surfaces six categories of information.

****Today's priorities**** — Tasks due today or overdue, sorted by priority. The ten most important things that need action right now.

****Active project status**** — Every active project with its current completion percentage, deadline, and the specific next action that moves it forward.

****Upcoming deadlines**** — Everything with a deadline in the next seven days across all note types. Projects, tasks, and client deliverables in one view.

****Client health**** — Every active client with their relationship health status, last contact date, and next scheduled touchpoint. At-risk clients appear at the top automatically.

****Open loops**** — Unfinished items from yesterday's daily note that still need closing. The things that fall through the cracks in most systems.

****Revenue pulse**** — Every active client sorted by monthly revenue contribution with a live total.

Six sections. One note. Everything that matters.

### The Technical Foundation

Two Obsidian features make a live dashboard possible.

****Dataview**** is a community plugin that functions as a query engine for your vault. It lets you write queries inside any note that pull information from other notes based on their properties, tags, or content. Results render live every time the note is opened.

****Properties**** are structured metadata fields at the top of every note written in YAML format. A task note has a due date property, a status property, and a priority property. Dataview reads these properties and the dashboard displays them.

The setup requires one plugin and a consistent approach to how every note in your vault is structured.

Install Dataview from Obsidian Settings → Community Plugins → Browse. Search for Dataview. Install and enable it.

That is the only plugin the core dashboard requires.

### Structuring Your Notes for Dashboard Queries

Before building the dashboard every note type needs consistent properties that Dataview can read.

Inconsistent properties produce incomplete query results. The discipline of maintaining consistent structure across every note of a given type is what makes the dashboard reliable.

```
Project Notes — stored in 01 - PROJECTS:
---
type: project
status: active
client: ClientName
deadline: 2026-06-15
priority: high
next_action: Write the campaign brief
completion: 40
---
Task Notes — stored in 02 - TASKS:
---
type: task
status: in-progress
project: ProjectName
due: 2026-05-20
priority: high
energy: deep
---
Client Notes — stored in 03 - CLIENTS:
---
type: client
status: active
mrr: 3000
last_contact: 2026-05-15
next_touchpoint: 2026-05-22
health: healthy
---
Daily Notes — stored in 04 - DAILY:
---
type: daily
date: 2026-05-18
energy: high
focus: Launch campaign review
---
```

The property names must match exactly between your notes and your queries. Type, status, priority, due, deadline — these exact strings appear in both places. One typo in a property name means that note becomes invisible to the query.

Start with the minimum viable properties. Add more as you identify what information you want the dashboard to surface.

### Building the Dashboard Section by Section

Create a new note in the root of your vault called Dashboard.md.

This note will never contain manually typed content after the initial build. Everything in it is a header or a Dataview query that pulls live information from the rest of your vault.

Section 1: Today's Priorities

TABLE WITHOUT ID
  [file.link](https://x.com//file.link)

 as "Task",
  due as "Due",
  project as "Project",
  priority as "Priority"
FROM "02 - TASKS"
WHERE type = "task"
AND status != "complete"
AND (due = date(today) OR due < date(today))
SORT priority DESC, due ASC
LIMIT 10

This query pulls every task due today or earlier that has not been completed. It sorts by priority first so the highest-leverage items appear at the top. The LIMIT 10 is intentional.

A dashboard showing 40 overdue tasks creates anxiety rather than clarity.

Limiting to ten forces prioritization at the properties level. If more than ten tasks are due today the ones that do not make the dashboard need their due dates adjusted or their priority re-evaluated. The dashboard becomes a forcing function for honest prioritization.

Section 2: Active Projects

TABLE WITHOUT ID
  [file.link](https://x.com//file.link)

 as "Project",
  client as "Client",
  completion + "%" as "Done",
  deadline as "Deadline",
  next_action as "Next Action",
  priority as "Priority"
FROM "01 - PROJECTS"
WHERE type = "project"
AND status = "active"
SORT priority DESC, deadline ASC

Every active project appears here with its completion percentage, deadline, and the specific next action.

The next_action property is the most valuable column in this table. It surfaces what each project needs right now without you opening any project file. Combined with the deadline and completion columns you can assess the full status of every active project in under two minutes.

When you update the next_action property in a project file the dashboard reflects the change immediately.

Section 3: Next Seven Days

TABLE WITHOUT ID
  [file.link](https://x.com//file.link)

 as "Item",
  type as "Type",
  deadline as "Deadline",
  status as "Status",
  client as "Client"
FROM ""
WHERE (deadline >= date(today) AND deadline <= date(today) + dur(7 days))
AND status != "complete"
SORT deadline ASC

This section queries everything in the vault with a deadline in the next seven days regardless of note type. Projects, tasks, and client deliverables all appear together sorted by date.

The seven-day window is short enough that everything in this list is genuinely relevant to near-term planning. Long enough that you can act ahead of deadlines rather than only reacting to them.

Section 4: Client Health Monitor

TABLE WITHOUT ID
  [file.link](https://x.com//file.link)

 as "Client",
  health as "Health",
  mrr as "MRR ($)",
  last_contact as "Last Contact",
  next_touchpoint as "Next Touchpoint"
FROM "03 - CLIENTS"
WHERE type = "client"
AND status = "active"
SORT health ASC, last_contact ASC

Sorting health ascending means at-risk clients appear at the top.

Sorting last_contact ascending within each health tier means the clients you have not spoken to most recently appear first within their group.

The combination makes the action obvious without any additional thought. Red health with a three-week-old contact date requires immediate action. Green health with a contact date from yesterday does not.

The health property uses three values: healthy, attention, and atrisk. Maintain this consistently and the dashboard sorts itself into a CRM review that would otherwise take 20 minutes of manual checking.

Section 5: Open Loops

This section requires a simple convention in your daily notes.

Any item you want to surface on the following day's dashboard gets prefixed with OPEN: when you write it in your daily note.

OPEN: Follow up on revised proposal from client
OPEN: Decision on Q3 content pillars
OPEN: Review contract terms before Thursday call

The query:

LIST
FROM "04 - DAILY"
WHERE type = "daily"
AND date = date(today) - dur(1 day)
FLATTEN file.lists AS item
WHERE contains(string(item), "OPEN:")

Every item prefixed with OPEN: in yesterday's daily note appears in today's dashboard automatically.

The open loops section captures the items that are important enough to note but not formal enough to be a task. These are the things that fall through the cracks in systems that only track formal tasks. The OPEN: convention surfaces them at the right moment without requiring a separate tracking system.

Section 6: Revenue Pulse

TABLE WITHOUT ID
  [file.link](https://x.com//file.link)

 as "Client",
  mrr as "MRR ($)",
  health as "Health",
  status as "Status"
FROM "03 - CLIENTS"
WHERE type = "client"
AND status = "active"
SORT mrr DESC

Add this inline query below the table to display the total:

**Total MRR:** `$= dv.pages('"03 - CLIENTS"').where(p => p.type === "client" && p.status === "active").map(p => p.mrr).array().reduce((a,b) => a + b, 0)`

This table and total give you the current revenue picture in 15 seconds. Every active client. Their monthly contribution. Their health status. The running total.

No spreadsheet. No manual calculation. The numbers update every time you change a client property.

### The Complete Dashboard Template

# Dashboard
> `$= [dv.date](https://x.com//dv.date)

("today").toFormat("EEEE, MMMM d, yyyy")`

---

## Today's Priorities

[DATAVIEW QUERY — SECTION 1]

---

## Active Projects

[DATAVIEW QUERY — SECTION 2]

---

## Next 7 Days

[DATAVIEW QUERY — SECTION 3]

---

## Client Health

[DATAVIEW QUERY — SECTION 4]

---

## Open Loops

[DATAVIEW QUERY — SECTION 5]

---

## Revenue Pulse

[DATAVIEW QUERY — SECTION 6]

**Total MRR:** [INLINE QUERY]

Replace each bracketed placeholder with the corresponding query from the sections above.

The inline date at the top renders today's date automatically so you always know which day the dashboard is showing without checking your calendar.

### Connecting Claude Code via MCP

The dashboard built above is already more useful than most business management setups.

Connected to Claude Code via the Filesystem MCP it gains two capabilities that change the morning experience completely.

****Intelligent morning briefing.**** Instead of reading six tables of raw data Claude reads the dashboard, synthesizes the information across all six sections, and produces a natural language briefing. Not what the data shows. What the data means for today.

The morning briefing prompt:

Read my Obsidian dashboard note and every file it references.

Synthesize a morning briefing that tells me:
1. The single most important thing to accomplish today
2. What requires my attention before noon and why
3. What is at risk if I do not act on it today
4. The client relationship that most needs attention right now
5. One decision sitting open that I should make before I start

Do not describe the tables. Tell me what they mean.
Keep the briefing under 300 words. Start with the most urgent thing.

This briefing runs automatically via N8N every morning at 6AM. It reads the live dashboard data and deposits the briefing in your daily note before you open your laptop.

****Automatic property updates.**** When you complete work Claude updates the corresponding properties in your project and task files automatically.

The completion convention in your daily note:

DONE: [project name] — [specific deliverable]
UPDATE: [project name] — completion: 65

Claude reads these entries, finds the corresponding files in the vault, updates the properties, and logs the changes. The dashboard reflects the updates immediately.

### The Daily Workflow With the Dashboard Running

Here is what the first ten minutes of your day looks like.

6:00 AM: Your phone receives a Telegram notification. The morning briefing is ready in your daily note.

6:02 AM: You read the briefing. It tells you the one thing that matters most today and the one client relationship that needs attention. It is 180 words.

6:05 AM: You open the dashboard. You confirm the priorities the briefing surfaced match what the tables show. You add any new tasks with the correct properties.

6:10 AM: You start working.

No email first. No Slack first. No 45-minute orientation across five tools.

You start working because you already know what matters.

The dashboard delivers this every morning without you maintaining it, compiling it, or updating it manually.

### Making the Dashboard Accurate Over Time

The dashboard is only as good as the data underneath it.

Three habits make the data reliable.

****Update properties the moment something changes.**** When a project moves from active to complete update the status property immediately. When a client's health changes update the health property that day. Stale properties produce stale dashboard data.

****Use the OPEN: convention consistently.**** Every time something needs to carry forward to tomorrow write it in your daily note with the OPEN: prefix. Do not rely on memory to carry it forward manually.

****Review the dashboard at day end as well as day start.**** A 3-minute end-of-day dashboard review identifies what to update before tomorrow's morning briefing runs. Five property updates at 5PM produce a more accurate briefing at 6AM than five updates made while already reading the briefing.

### Troubleshooting

****Queries returning empty results:**** The property names in your notes do not exactly match the property names in the query. Check for typos, capitalization differences, and missing quotes.

****Properties not displaying:**** The YAML frontmatter block must appear at the very top of the note before any other content. A single character before the opening --- breaks the entire properties block.

****Date queries not working:**** Dates in properties must follow YYYY-MM-DD format exactly. 2026-5-18 breaks the query. 2026-05-18 works.

****Dashboard loading slowly:**** Too many notes match the query criteria. Add folder filters to narrow the scope. Querying FROM "01 - PROJECTS" is faster than querying FROM "" across the entire vault.

****Inline calculations showing errors:**** The MRR property must contain a number not a string. mrr: 3000 works. mrr: "$3,000" does not.

### What Changes After 30 Days

The dashboard delivers immediate value from the first morning you use it.

The compounding effect shows up at month two.

Every property update you make trains a discipline of keeping your vault data current. That discipline compounds into a system where the dashboard is genuinely accurate rather than partially accurate.

Every OPEN: item you capture closes the gap between what you intended to do and what you actually tracked. Over 30 days you stop losing the important but non-urgent items that used to fall through the cracks.

Every morning briefing Claude generates from the dashboard data gets more calibrated to your actual work patterns as the underlying data gets richer.

By month two you will not remember how you started your mornings before the dashboard existed.

By month three you will not start your day without it.

The build takes one afternoon.

The compounding starts the first morning.

Build it today.

Follow [@cyrilXBT](https://x.com/@cyrilXBT)

 for the exact Dataview queries, Claude prompts, and vault templates that make this entire system run.

> Original article: https://x.com/i/article/2056174105821401090

