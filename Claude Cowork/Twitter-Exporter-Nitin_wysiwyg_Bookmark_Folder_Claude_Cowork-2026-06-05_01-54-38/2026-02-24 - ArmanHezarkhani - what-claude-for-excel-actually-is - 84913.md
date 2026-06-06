---
title: "What Claude for Excel Actually Is"
author: "Arman Hezarkhani"
username: "@ArmanHezarkhani"
date: "2026-02-24"
tweet_url: "https://x.com/ArmanHezarkhani/status/2026308695399784913"
tweet_type: "original"
likes: 6903
retweets: 1223
replies: 92
bookmarks: 21453
views: 4117514
has_media: false
extraction_quality: full
article_id: "2026301424724754432"
tags: ["twitter-bookmark", "claude", "mcp", "agents"]
---

# What Claude for Excel Actually Is

> **Source:** [@ArmanHezarkhani](https://x.com/ArmanHezarkhani) · 2026-02-24 · 👍 6903 · 💬 92 · 🔖 21453 · 👁 4117514

> 🔗 [View tweet on X](https://x.com/ArmanHezarkhani/status/2026308695399784913)

## Article Content

I've helped hundreds of companies through their AI transformation. The single most common question I get—from CFOs, ops leads, analysts, founders—is some version of the same thing:

"How do I automate Excel?"

Everyone's been promised this. A dozen startups have tried. And every time, the result was the same: a tool that could write a VLOOKUP for you but couldn't actually understand your workbook.

The moment is here.

Anthropic quietly shipped Claude for Excel, an AI sidebar that doesn't just sit next to your spreadsheet. It ****reads your entire workbook****. Every tab. Every formula. Every cell dependency. It builds a structural map of how your model works, then lets you have an intelligent conversation about it.

I watched it trace a 14-tab financial model, revenue assumptions feeding into headcount plans, piping into opex forecasts across three scenario tabs, in thirty seconds. With clickable cell references I could verify one by one. It found hardcoded values that should have been variables and a circular reference the original analyst probably didn't know existed.

This isn't autocomplete for formulas. This is a data analyst that already read the entire file before you asked your first question.

## What Claude for Excel Actually Is

Let me clear up the most common misconception: Claude for Excel is ****not**** a cell formula like =GPT(). It's not autocomplete for spreadsheets. It's not a chatbot that happens to live near your data.

It's a ****structural analyst that reads your entire workbook, ****every tab, every formula, every cell dependency, and builds a mental model of how it all connects. Then you have a conversation with that analyst.

This distinction matters. Microsoft Copilot helps you write formulas faster. Claude for Excel helps you ****understand, audit, build, and transform**** entire models.

Anthropic launched it as a research preview in October 2025 for Enterprise users, then opened it to Pro subscribers ($20/month) in January 2026. It runs as a sidebar inside Excel, you chat on the right, it reads and modifies your workbook on the left.

Every explanation comes with ****cell-level citations****. When Claude says "Revenue in B12 is calculated by multiplying the unit price in B10 by the projected volume in B11," you can click those references and verify. It's not a black box. It shows its work.

## Getting Started

### What You Need

- A ****Claude Pro**** ($20/month), ****Max**** ($100–$200/month), ****Team****, or ****Enterprise**** subscription
- Microsoft Excel desktop app (Mac or Windows)
- A .xlsx or .xlsm file

The free tier doesn't include Excel access.

### Installation

1. Go to the [Microsoft Marketplace](https://marketplace.microsoft.com/en-us/product/saas/wa200009404)

 and install "Claude by Anthropic for Excel"
2. Open Excel
3. Activate the add-in: ****Tools > Add-ins**** (Mac) or ****Home > Add-ins**** (Windows)
4. Sign in with your Claude account
5. Open any spreadsheet and launch the sidebar: ****Ctrl+Option+C**** (Mac) or ****Ctrl+Alt+C**** (Windows)

That's it. Claude immediately reads your entire workbook and is ready to work.

### For IT Admins

You can deploy org-wide through the Microsoft 365 Admin Center: ****Settings > Integrated apps > Add-ins****, search for Claude, and push to your users or groups. No API keys, no per-seat configuration for the add-in itself.

## What Claude Actually Sees

This is what separates Claude for Excel from every other AI spreadsheet tool. When you open the sidebar, Claude reads:

- ****Every tab**** in your workbook, not just the active sheet
- ****Every formula**** and its dependencies across tabs
- ****Cell relationships ****which cells feed into which calculations
- ****Named ranges and references****
- ****Conditional formatting rules****
- ****Data validation constraints****

It doesn't just read cells. It understands the ****architecture**** of your model.

This means you can ask questions like:

> "If I change the growth rate in B5, what else in this workbook is affected?""Which cells in the P&L tab depend on assumptions in the Inputs tab?""Are there any hardcoded values that should be linked to the assumptions sheet?"

And it answers with specific cell references, not vague summaries.

## The Workflows That Matter

### 1. Understanding Inherited Models

This is Claude's killer app. Every analyst, every finance professional, every operator has been handed a spreadsheet built by someone else—someone who didn't document anything—and been expected to work with it immediately.

****What to ask:****

> "Give me a summary of each tab and how they connect to each other.""Explain the formula in D15 in plain English.""Trace the revenue calculation from raw assumptions to the final number on the Summary tab.""Find all circular references in this workbook and explain what's causing them.""Identify every hardcoded value that should probably be a variable."

Claude's cell-level citations make this trustworthy. You're not taking its word for it—you're clicking through and verifying. It's like having a co-analyst who already read the whole model before the meeting.

### 2. Building Models From Scratch

You can describe what you need in natural language and Claude will build it.

> "Build a 3-statement financial model for a SaaS company. Assumptions: $5M ARR, growing at 30% YoY. 90% gross margin. Headcount growing from 40 to 65 over 3 years. Average fully loaded cost per employee: . Include an income statement, balance sheet, and cash flow statement. Link all three statements. Add a sensitivity table for growth rate vs. gross margin."

Claude creates the tabs, writes the formulas, links the dependencies, and formats the output. You get a working draft in minutes—not a final deliverable, but a structural starting point that would have taken hours to set up manually.

****Important:**** Claude builds the scaffolding. You verify the logic and refine the assumptions. Think of it as a first draft from a junior analyst who's very fast and very literal.

### 3. Scenario Analysis

This is where the structural awareness pays off. Because Claude knows which cells are assumptions and which are calculations, it can change inputs without breaking anything.

> "Run three scenarios: (1) Base case: current assumptions. (2) Bear case: revenue misses by 20%, churn increases by 2%. (3) Bull case: revenue beats by 15%, hiring delayed by one quarter. Create a summary tab comparing all three scenarios side by side."

Claude updates the assumptions, preserves every formula dependency, and highlights every cell it changed with an explanation of why. You can review the changes before accepting them.

### 4. Debugging Formulas

> "Why is cell D15 showing [#REF](https://x.com/search?q=%23REF&src=hashtag_click)
> 
> !? Trace the error to its source and fix it.""Cell G22 should be showing $1.2M but it's showing . Walk me through the calculation and find where it diverges from what I expect.""Find all [#VALUE](https://x.com/search?q=%23VALUE&src=hashtag_click)
> 
> ! errors in the Revenue tab and fix them."

Claude traces errors through the dependency chain—across tabs if necessary—and identifies the root cause. For [#REF](https://x.com/search?q=%23REF&src=hashtag_click)

! errors that point to deleted ranges, it can suggest the most likely intended reference based on the surrounding formula structure.

### 5. Data Cleaning and Transformation

Drop messy data into a spreadsheet and let Claude organize it.

> "Column A has dates in mixed formats (MM/DD/YYYY, DD-Mon-YY, and some text dates). Standardize them all to YYYY-MM-DD.""This dataset has duplicate entries. Flag duplicates in a new column and create a deduplicated version on a new tab.""Split the full names in column B into First Name and Last Name in columns C and D."

You can also drag in external files—CSVs, PDFs, even images of tables—directly into the Claude sidebar. Claude extracts and organizes the data into your spreadsheet.

### 6. Formatting and Presentation

> "Add conditional formatting: green for positive growth rates, red for negative, in columns D through H.""Create a chart showing revenue by quarter for the last 8 quarters.""Prepare this workbook for printing: add headers, page breaks, and freeze the top row on every tab."

Claude handles pivot tables, charts, conditional formatting, sorting, filtering, and data validation. Its formatting isn't beautiful—you'll want to polish it—but the structural work is solid.

## Prompting Patterns That Work

After a few weeks of daily use, these patterns consistently produce the best results.

### Pattern 1: Orient Before You Operate

Before modifying anything, ask Claude to explain the model. This is faster than manually clicking through cells and gives you a shared understanding to reference in later prompts.

> "Before we make any changes, give me: (1) A summary of each tab's purpose. (2) The main calculation flow (which tabs feed into which). (3) Any formulas that look unusual or potentially broken. (4) All hardcoded assumptions I should know about."

### Pattern 2: Be Specific About Scope

Prevent unintended changes by telling Claude exactly where to operate.

> "Only modify cells in column E, rows 5 through 50. Do not touch any other columns or rows.""Add the sensitivity table on a NEW tab called 'Scenarios'. Do not modify any existing tabs."

### Pattern 3: Ask for a Plan First

For complex operations, have Claude outline its approach before executing.

> "I want to restructure the revenue model to support per-product revenue streams instead of a single blended number. Before making any changes, outline: which cells you'll modify, what new formulas you'll create, which existing dependencies might break, and your recommended approach."

### Pattern 4: Quantitative Criteria, Not Vibes

> ****Bad:**** "Find the underperforming products."****Good:**** "Flag every product where revenue declined more than 10% QoQ and margin is below 15%. Add a column with the flag."

> ****Bad:**** "Clean up this data."****Good:**** "Remove rows where column C is blank, column D contains non-numeric values, or column E has dates before 2024-01-01."

### Pattern 5: Specify Your Data Sources

If you have MCP connectors configured (more on this below), name them explicitly.

> "Using Daloopa, retrieve Microsoft's revenue, operating margin, and free cash flow for Q1 2023 through Q4 2024.""From S&P Global via Kensho, pull Tesla's last 8 quarters of EBITDA and revenue growth."

## The MCP Connectors

This is the feature most people don't know about, and it's significant.

Claude for Excel supports ****Model Context Protocol (MCP) connectors****—integrations that let Claude pull live data from external sources directly into your spreadsheet without leaving Excel.

If you have connectors configured in your Claude account, they automatically work in the Excel sidebar. No additional setup.

****Available connectors include:****

- ****S&P Global / Kensho**** — Capital IQ financial data
- ****LSEG**** — Live market data: equities, fixed income, FX, macro
- ****Moody's**** — Credit ratings, data on 600M+ companies
- ****Daloopa**** — Financial data extraction
- ****PitchBook**** — Private equity and VC data
- ****FactSet**** — Financial data and analytics
- ****Aiera**** — Real-time earnings call transcripts
- ****Morningstar**** — Investment research data
- ****Egnyte**** — Secure data room access

This turns Claude from "AI that reads your spreadsheet" into "AI that reads your spreadsheet AND pulls live financial data into it." For finance teams, this is the moat.

You can ask things like:

> "Pull revenue and EBITDA for MSFT, AAPL, GOOG, and AMZN for the last 12 quarters using Daloopa. Organize in a comp table with YoY growth rates calculated."

And Claude retrieves the data, organizes it, and writes the growth rate formulas, all in one operation.

## Pre-Built Skills For Finance Teams

Anthropic has built six pre-configured agent skills specifically for financial services:

1. ****Comparable Company Analysis: ****valuation multiples, operating metrics, peer comps
2. ****Discounted Cash Flow Models:**** FCF projections, WACC calculations, scenario toggles, sensitivity tables
3. ****Due Diligence Data Packs:**** converts data room documents into structured Excel output
4. ****Company Teasers and Profiles:**** condensed overviews for pitch books
5. ****Earnings Analyses: ****quarterly transcript research with key metrics and guidance changes
6. ****Initiating Coverage Reports:**** industry analysis with valuation frameworks

These aren't prompts you have to write yourself. They're pre-built workflows that execute multi-step analyses. Select a skill, provide the company or dataset, and Claude runs the full workflow.

## The Model Selection Strategy

You can switch between two Claude models in the sidebar:

- ****Sonnet 4.6:**** Faster. Good for simple questions, quick formatting, routine operations.
- ****Opus 4.6:**** More powerful. Use for complex multi-tab models, deep analysis, and anything requiring sophisticated reasoning.

My default: Sonnet for orientation questions and simple edits. Opus when I need it to build something, debug something tricky, or trace complex dependencies. The difference in reasoning quality on hard problems is noticeable.

## The Security Thing You Need to Know

A vulnerability called ****CellShock****, discovered by PromptArmor, demonstrated that malicious instructions can be hidden in spreadsheet cells—blue text on a blue background, invisible Unicode characters—that manipulate Claude into collecting sensitive data and exfiltrating it through formulas like WEBSERVICE.

Anthropic has responded with protections. A warning modal now appears when Claude attempts to insert protected functions (WEBSERVICE, IMPORTDATA, INDIRECT, and others). You have to approve these explicitly.

****The practical rule:**** Only use Claude for Excel with ****trusted spreadsheets****. If someone you don't know sends you an Excel file, don't open the Claude sidebar on it. This applies to downloaded templates, vendor files, and data imports from unknown sources.

For files you create yourself or receive from trusted colleagues, which is most use cases, this isn't a concern. But it's worth knowing.

## Current Limitations

****No VBA or macro support.**** Claude can't read, write, or modify macros. If your workflow depends on VBA, Claude won't help with that part.

****No Power Query or Power Pivot.**** These advanced Excel features aren't supported. (Though Claude can generate M code for Power Query—it just can't execute it within the add-in.)

****Chat history doesn't persist.**** When you close and reopen the sidebar, your conversation is gone. Save prompts that work well in a separate document. This is annoying and will hopefully be fixed.

****Usage burns fast.**** Intensive sessions—building models, running multi-tab analyses—consume your Claude plan's usage allocation quickly. On a Pro plan, expect to hit rate limits during heavy work. Max plans ($100–$200/month) give you significantly more headroom.

****Still in beta.**** Features are actively evolving. Things break occasionally. It's improving fast, but don't treat it as production-grade tooling for audit-critical work without verification.

****Formatting is functional, not beautiful.**** Claude's formatting output is fine for working models but not polished enough for client deliverables. Build the structure with Claude, then manually polish the presentation.

## Power User Tips

### 1. Enable the Claude Log Tab

In settings, turn on session logging. Claude creates a "Claude Log" tab in your spreadsheet that records every action it took during the session. This is invaluable for audit trails and for understanding what changed if something looks off later.

### 2. Use "Ask Before Edits" Mode

Keep this on for important workbooks. Claude will describe what it plans to do and wait for your approval before modifying any cells. For routine work on low-stakes files, you can switch to "Accept All Edits" mode to move faster.

### 3. Save a Backup First

Before starting a Claude session on any workbook that matters, save a copy. Claude's changes are highlighted and explained, but it's easier to compare against a clean backup than to undo a complex set of operations.

### 4. Pre-Format, Then Fill

Claude's data and formula work is strong. Its formatting is mediocre. Set up your workbook structure and formatting first—headers, column widths, number formats, colors—then have Claude populate the data and formulas. This produces better-looking results than having Claude do everything.

### 5. Break Large Operations Into Steps

Don't ask Claude to "build a complete financial model with sensitivity analysis and scenario comparison." Instead:

1. "Create the revenue projection tab with these assumptions."
2. Verify it looks right.
3. "Now create the expense forecast based on the headcount plan."
4. Verify.
5. "Link these into an income statement on a new Summary tab."
6. Verify.

Each step is verifiable. Errors don't compound.

### 6. Drag In Reference Materials

You can drop PDFs, CSVs, images, and other Excel files directly into the Claude sidebar. Working from a PDF report? Drag it in. Claude extracts tables and data from it and can organize them in your spreadsheet. This works with JPEG, PNG, GIF, and WebP images too—Claude can interpret charts and diagrams via its vision capabilities.

## Quick Reference

### Keyboard Shortcuts

- ****Open Claude sidebar (Mac):**** Ctrl+Option+C
- ****Open Claude sidebar (Windows):**** Ctrl+Alt+C

### What Claude Can Do

- Read and explain any formula with cell-level citations
- Build financial models from natural language descriptions
- Run scenario and sensitivity analysis while preserving dependencies
- Debug formula errors across tabs
- Create pivot tables, charts, and conditional formatting
- Clean and transform messy data
- Extract data from PDFs and images
- Pull live financial data via MCP connectors
- Audit model structure and identify issues

### What Claude Cannot Do

- Read or write VBA macros
- Use Power Query or Power Pivot
- Connect to external databases
- Work with Excel's native Data Tables (What-If Analysis)
- Save chat history between sessions
- Work with .xls files (only .xlsx and .xlsm)

### Pricing

- ****Free**** ($0/month) — No Excel access
- ****Pro**** ($20/month) — Yes
- ****Max 5x**** ($100/month) — Yes, with 5x usage
- ****Max 20x**** ($200/month) — Yes, with 20x usage
- ****Team**** ($25–$150/seat) — Yes
- ****Enterprise**** (Custom pricing) — Yes

### Prompt Cheat Sheet

****Orientation:****

> "Summarize each tab and how they connect.""Explain the formula in [cell] in plain English.""Trace the calculation from [input cell] to [output cell]."

****Building:****

> "Build a [model type] with these assumptions: [list them].""Create a sensitivity table for [variable A] vs [variable B].""Add a new tab that summarizes [specific metrics] from [source tabs]."

****Debugging:****

> "Why is [cell] showing [error]? Trace it and fix it.""Find all circular references and explain what's causing them.""Identify hardcoded values that should be linked to assumptions."

****Data:****

> "Standardize dates in column A to YYYY-MM-DD.""Flag duplicate rows based on columns A and C.""Using [connector name], retrieve [metrics] for [companies] over [period]."

## TL;DR

****Claude for Excel is a structural analyst, not a formula autocomplete.**** It reads your entire workbook—every tab, every formula, every dependency—and lets you have an intelligent conversation about it.

****The killer use case is understanding inherited models.**** What used to take hours of cell-tracing archaeology now takes 30 seconds and comes with clickable citations you can verify.

****It builds, too.**** Financial models, scenario analyses, sensitivity tables, comp tables—describe what you need and Claude creates the structure with all formulas linked. Verify the logic, refine the assumptions, and you have a working draft in minutes instead of hours.

****MCP connectors are the enterprise moat.**** Pulling live data from S&P Global, LSEG, Moody's, and PitchBook directly into your spreadsheet—without leaving Excel—is something Copilot can't do.

****The honest assessment:**** It's not a replacement for knowing Excel. It's a force multiplier for people who already do. Chat history doesn't persist, usage burns fast on Pro plans, and VBA isn't supported. But for model auditing, scenario analysis, and building first drafts of complex workbooks, nothing else comes close.

****Start here:**** Install the add-in, open a complex spreadsheet you've been meaning to understand, and type "Walk me through how this model works." You'll be convinced in 30 seconds.

> 📄 Original article URL: https://x.com/i/article/2026301424724754432

---

## Commentary from Other Bookmarks

### @ArmanHezarkhani (Arman Hezarkhani) — 2026-02-24

> This is a huge deal for nerds

[→ View quote tweet](https://x.com/ArmanHezarkhani/status/2026308832394170641)

