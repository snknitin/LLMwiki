---
title: "He feeds expired patents to Claude. $0 for the blueprint. $1.80 to manufacture. $11.99 on Amazon."
author: "Gipp 🦅"
username: "@gippp69"
date: "2026-04-28"
tweet_url: "https://x.com/gippp69/status/2049131801780658541"
tweet_type: "original"
likes: 1851
retweets: 159
replies: 66
bookmarks: 6308
views: 3422219
has_media: false
extraction_quality: full
article_id: "2049082537717190656"
tags: ["twitter-bookmark", "claude", "mcp", "agents"]
---

# He feeds expired patents to Claude. $0 for the blueprint. $1.80 to manufacture. $11.99 on Amazon.

> **Source:** [@gippp69](https://x.com/gippp69) · 2026-04-28 · 👍 1851 · 💬 66 · 🔖 6308 · 👁 3422219

> 🔗 [View tweet on X](https://x.com/gippp69/status/2049131801780658541)

## Article Content

## He feeds expired patents to Claude. $0 for the blueprint. $1.80 to manufacture. $11.99 on Amazon.

I feed expired patents to Claude. Found 6 products nobody manufactures anymore. First one is already in production.

Most people use AI to write emails and summarize PDFs.

I pointed it at the US Patent Office.

The idea came from a rabbit hole.

I was reading about a company that got sued for patent infringement on a kitchen gadget. Lost $2.3 million in settlement.

Then I checked the patent filing date.

It expires in 18 months anyway.

That got me thinking.

What happens to all the patents that already expired?

Not the big ones. Not pharma blockbusters or chip designs.

The small ones. The boring ones. The ones filed by a guy in Ohio who invented a better planter insert and then went bankrupt before it mattered.

I looked it up.

Over 4.2 million US patents expired in the last decade alone.

Not rejected. Not failed. Expired.

The owners either went bankrupt, forgot to renew, or decided the product was not worth protecting anymore.

Every single one of those patents is now public domain.

Free to use. Free to manufacture. Free to sell.

Nobody cares. Nobody looks at them.

Part 1 — The Pipeline

The problem was never access.

The USPTO publishes everything through their Bulk Data portal — full text, full drawings, full claims. Every detail you need to rebuild a product from scratch.

USPTO Bulk Data — full patent database, public domain, free https://bulkdata.uspto.gov

The problem was volume.

Nobody reads 4 million patents for fun.

I decided Claude would.

The first week was just infrastructure. Nothing fancy.

A Python scraper pulling expired utility patents from the Bulk Data API.

The filter logic:

python

# patent_filter.py — first pass

FILTERS = {

"status": "expired",

"type": "utility",          # skip design patents

"assignee_size": "small",   # no IBM, no Samsung

"categories": [

"household",

"tools",

"pet_products",

"office_supplies",

"garden",

"kitchen"

],

"expired_after": "2014-01-01",

"min_claims": 3,

"max_claims": 25           # too many claims = too complex

}

I specifically wanted patents from small to mid-size companies.

Not IBM. Not Samsung. Not Qualcomm.

Small companies where the tech is simple enough to manufacture independently. Consumer products. Hardware. Tools. Home goods.

To convert the raw patent files into something Claude could actually process, I used markitdown — strips any document format down to clean Markdown.

microsoft/markitdown — convert any file to Markdown for Claude context, 38K+ stars https://github.com/microsoft/markitdown

That first filter gave me roughly 340,000 candidates.

Still way too many to read manually.

Part 2 — The Claude Filter

This is where it gets interesting.

I built a scoring pipeline. Each patent goes through Claude with a structured prompt.

The system prompt:

plaintext

ROLE: Patent Commercial Viability Analyst

INPUT: Expired US utility patent (full text + claims)

ANALYZE AND RETURN:

─────────────────────────────────────────

1. PLAIN_ENGLISH:    What does this actually do?

2. CONSUMER_VIABLE:  Could a consumer version exist? (yes/no)

3. BOM_ESTIMATE:     Bill of materials at 1000 MOQ (Alibaba)

4. AMAZON_GAP:       Does any current listing use this exact mechanism?

5. REVIEW_SIGNAL:    What do competing product reviews complain about?

6. SCORE:            Commercial viability 1-10

REJECT IMMEDIATELY:

- Requires FDA/FCC clearance

- Needs custom semiconductor fab

- Chemical formulation patents

- Software/algorithm patents

- Requires tooling over $50K

RETURN FORMAT: JSON only. No commentary.

I ran batches of 50 patents at a time.

Each batch took about 90 seconds to process.

For batching the files into prompt-ready chunks, I used files-to-prompt.

simonw/files-to-prompt — pack your entire project into a single prompt for Claude, 3K+ stars https://github.com/simonw/files-to-prompt

Sample output:

json

{

"patent_id": "US8,234,811",

"plain_english": "Self-watering planter insert with passive

felt wick. Pulls moisture from reservoir to soil via

capillary action. No pump, no battery.",

"consumer_viable": true,

"bom_estimate": "$1.60-2.10 at 1000 MOQ",

"amazon_gap": true,

"review_signal": "Competing products: water pools at bottom,

wicks clog after 2 weeks, not optimized for small pots",

"score": 8

}

The results were mostly noise.

Score 1. Old semiconductor layouts nobody can use.

Score 2. Obscure chemical formulations that require lab equipment.

Score 1. Telecom switching protocols from 2004.

Score 1. Medical imaging calibration tools that need FDA clearance.

Score 1. Score 1. Score 2. Score 1.

Hundreds of patents. All garbage for consumer products.

But roughly 1 in 80 came back with a score of 7 or higher.

Those were the ones.

Part 3 — The Hits

Hit #1 — Self-watering planter insert

Passive wicking system. No pump. No battery. No moving parts.

Originally patented in 2009 by a garden tools company out of Ohio. Small operation, 12 employees.

The company went bankrupt in 2016.

Patent renewal fee: $1,600. Nobody paid it. Patent lapsed.

Nobody picked it up.

I checked Amazon.

Plenty of self-watering planters on the market. Dozens of listings.

But none of them used this specific wicking design.

The patented version was simpler to mold, cheaper per unit, and actually performed better for indoor herbs because the wick diameter was optimized for small soil volumes.

The reviews on competing products told the story.

"Water pools at the bottom." "My basil still died." "Wick stopped working after 2 weeks."

The patented design solved exactly those problems. The inventor had clearly tested it.

And the patent document said so — with diagrams, measurements, and material specifications.

I found the original patent on Google Patents, which lets you filter by expiration status and see the full filing with drawings.

Google Patents — searchable patent index with expiration status filters https://patents.google.com

I contacted three manufacturers on Alibaba.

Sent the patent drawings directly.

Because that is the thing about patents.

They are literally manufacturing instructions written in legal language.

Dimensions. Tolerances. Materials. Assembly order. Everything a factory needs to quote production.

First quote came back: $1.80 per unit at 1,000 MOQ.

Current Amazon average price for "self-watering planter insert": $14 to $22.

Monthly search volume for the category: 118,000.

I ordered samples.

Hit #2 — Collapsible pet water bowl

Not just any collapsible bowl. This one had a one-hand locking mechanism.

Snap open. Snap closed. No hinges. No silicone folding. No moving parts that break.

Patented in 2011 by a pet products startup out of Austin, Texas.

The startup raised a small seed round. Built the product. Got it into a few stores.

Then ran out of money in 2019. Shut down. Patent lapsed.

I checked Amazon again.

The pet travel bowl category is massive. Thousands of listings.

But every single one uses either cheap silicone folding or plastic hinges.

The reviews on the top sellers are brutal.

"Hinge broke after a month." "Silicone stinks and my dog won't drink from it." "Collapsed in my bag and leaked everywhere."

The patented lock design fixes all of this. One snap. Rigid when open. Flat when closed. No parts to fail.

plaintext

Product Comparison — Collapsible Pet Bowls

──────────────────────────────────────────────

Patent Design    Amazon Top 5

Mechanism:          snap-lock        silicone fold

Moving parts:       0                2-4

Failure rate:       ~2%              ~31% (per reviews)

Unit cost (1K MOQ): $0.95            $1.40-2.20

Holds shape:        yes              collapses under weight

One-hand use:       yes              no

Alibaba quote: $0.95 per unit.

Amazon price range for collapsible pet bowls: $8 to $15.

The margins are absurd.

Hit #3 — Cable management clip

Adhesive base. Ratcheting jaw that adjusts to cable width automatically.

Patented in 2007 by an office supplies brand.

The brand got acquired in 2013. The new owner looked at the patent portfolio, decided half of it was not worth renewing, and let it lapse.

Including this one.

The ratchet design holds cables from 2mm to 12mm without swapping clip sizes.

Every cable clip on Amazon right now is either fixed-size or uses a generic flexible rubber slot that loosens after a few months.

I checked the reviews on the top 10 cable clip listings.

Same complaint. Over and over.

"Doesn't hold my thick charging cable." "Too loose for thin earphone wires." "Keeps popping out."

The patented ratchet jaw solves this mechanically. No rubber. No stretching. Just a stepped angle that grips tighter as the cable gets thicker.

plaintext

Unit Economics — Cable Clip (30-pack)

──────────────────────────────────────────

Production (30x $0.12):     $3.60

Packaging + label:          $0.40

Shipping to FBA:            $0.85

Amazon FBA fee:             $3.20

PPC (estimated):            $1.10

─────────────────────────────

Total cost:                 $9.15

Sale price:                 $11.99

Net margin:                 $2.84 (23.7%)

At 800 units/month:         $2,272/mo net

Part 4 — The Results

I found 6 products like this in 3 weeks of running the pipeline.

Three are in sample stage right now.

One — the planter insert — is already approved. Production run started. Amazon listing in prep.

Target price: $11.99.

Projected margin after PPC and FBA fees: 44%.

From an expired patent that cost $0 to access.

Part 5 — The System

The setup looks simple from the outside.

A scraper. A filter. Claude. A prompt. Alibaba.

No proprietary data. No expensive software. No team. No office. No research lab.

The full pipeline:

plaintext

USPTO Bulk Data API

│

▼

Python Scraper (filter by category, assignee, date)

│

▼

markitdown (convert to clean Markdown)

│

▼

files-to-prompt (batch into context payloads)

│

▼

Claude Scoring Pipeline

┌─────────────────────────────┐

│ System: Patent Analyst      │

│ Input: 50 patents/batch     │

│ Output: JSON scored 1-10    │

│ Filter: score >= 7          │

└─────────────────────────────┘

│

▼

Google Patents (verify + pull drawings)

│

▼

Alibaba (send drawings, get quotes)

│

▼

Amazon Listing

The Claude workflow itself was built using the Skills framework — reusable prompt templates that turn a one-off experiment into a repeatable system.

anthropics/claude-code-skills — official Skills/SKILL.md framework by Anthropic https://github.com/anthropics/claude-code-skills

For connecting Claude to external tools — the scraper, the supplier lookup, the review analysis — I used MCP.

anthropics/model-context-protocol — MCP, the standard for connecting tools to Claude https://github.com/anthropics/model-context-protocol

punkpeye/awesome-mcp-servers — catalog of 500+ ready-made MCP servers, 27K+ stars https://github.com/punkpeye/awesome-mcp-servers

And for the overall Claude Code agentic environment:

obra/superpowers — superpowers for Claude Code, 160K+ stars https://github.com/obra/superpowers

Part 6 — Why This Works

Here is what most people miss about patents.

They think of patents as legal shields. Something lawyers deal with.

But a patent is also an engineering document.

To get a patent granted, you have to disclose enough technical detail that someone skilled in the field could reproduce the invention.

Dimensions. Materials. Assembly steps. Performance specs.

That is the entire point of the patent system. You get temporary protection. In exchange, you give the public a complete blueprint.

When the patent expires, the blueprint stays.

It becomes a free manufacturing manual.

But nobody reads them.

Because patent documents look like this:

plaintext

"A fluid-wicking apparatus comprising a porous fibrous

member disposed within a reservoir cavity, wherein said

member maintains capillary continuity with a growth

medium positioned superiorly, characterized in that

the fibrous member exhibits a mean pore diameter of

between 40 and 120 micrometers..."

That is the planter insert.

Normal people see that and close the tab.

Claude reads it and returns:

json

{

"plain_english": "Felt wick inside a water tray that

pulls moisture up into soil. Optimized for small

indoor pots. Simple to injection-mold.",

"bom_estimate": "$1.80",

"score": 8

}

That is the entire edge.

Not a better product idea. Not a smarter market thesis. Not some secret Amazon hack.

Just the ability to read documents that humans skip because they look like legal noise.

Four million expired patents.

Each one is a detailed instruction manual for a product that once worked.

Most of them are genuinely useless.

But some of them are products that sold well, had real demand, solved real problems — and simply stopped being made because the company behind them died.

The product did not fail.

The business did.

And nobody went back to check.

Most people search for things to sell by browsing Amazon trending pages.

They look at what is already popular and try to compete.

I do the opposite.

I search for products that were once valuable enough to spend $15,000 protecting — and that nobody remembered to keep making.

The ugly products. The boring products. The ones nobody scrolls back far enough to find.

That is a different game.

Gipp

@gippp69

Follow

18 / ai workflows print money / vibe coding / dm open

> 📄 Original article URL: https://x.com/i/article/2049082537717190656

---

## Commentary from Other Bookmarks

### @RetroChainer (RetroChainer) — 2026-04-28

> &gt; lawyers see a patent close the tab
> &gt; Claude sees a patent calculates margin
> &gt; Mac Mini. Claude Code. one evening.
> &gt; $1.80 to make. $11.99 to sell.
> &gt; 44% margin. zero R&amp;D budget.
> &gt; vibes don't compound. patents do.

[→ View quote tweet](https://x.com/RetroChainer/status/2049197712612942329)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

