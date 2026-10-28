# Domains: design from what the app is for

A look is right only if it serves what this kind of app is *for*. Before picking a direction, read the domain: what the person is trying to do, how they feel while doing it, what the information looks like, and what the domain rewards. The concept, palette, type, density and motion follow from that. Two apps in the same domain still differ (check the ledger in [directions.md](directions.md)); two apps in different domains should never look like siblings.

## Read any domain in five questions

Answer these in the brief's `Domain` line before choosing a family. They work for domains not listed below.

1. **The job.** What does the person come to do, in one verb, and how often? (Check a number daily. Log one thing nightly. Skim 40 headlines. Rehearse for an hour.)
2. **The state.** How do they feel arriving? (Anxious about money, tired at night, curious, under time pressure.) The UI should answer that state: calm the anxious, speed up the hurried, reward the curious.
3. **The shape of the information.** Numbers over time? A ranked list? A streak of days? A graph of people? Prose? The data's shape picks the structure.
4. **What the domain rewards.** Precision, trust, momentum, recency, depth, delight, focus. Pick two. They become the design's principles and the tie-breakers for every choice.
5. **The conventions and the clichés.** What people already expect here (keep it), and the domain's stock visual clichés (avoid them).

The answers give you: **principles** (from 4), **structure** (from 3), **register** (calm, brisk, warm, rigorous; from 2), **density and motion** (from 1), and **what not to do** (from 5).

## Domain playbook

Each entry: what it rewards, how that shows, structures that fit, conventions to keep, and its own clichés to avoid. Structures are starting points; combine with a family from [directions.md](directions.md) that isn't already in the ledger.

### Money: net worth, budgets, subscriptions, markets

- **Rewards:** precision and calm. The person is often anxious; the screen should feel exact and unhurried, like a good statement or an instrument.
- **Shows as:** tabular figures everywhere, right-aligned, consistent decimals and currency (₹ with Indian grouping when the data is Indian); the one number that matters largest, with its change and period; time as a first-class axis (month, quarter, since the last brief); muted ground, one data accent; gains and losses shown by sign and a restrained semantic colour, never a wall of red and green.
- **Structures:** a statement or passbook (line items building to a balance), a timeline hung on real events (closes, pay days, renewals), a chart recorder, a balance sheet with assets left and liabilities right, a calendar of renewals, a "what-if" sliders bench beside a fixed baseline.
- **Keep:** dates and amounts the person would recognise from their bank; totals that add up; the source and as-of time of every figure.
- **Avoid:** crypto-casino neon, gauges and speedometers, glowing green up-arrows, KPI tiles with sparklines repeated on every page, fake precision (12 decimals), stock "fintech blue".

### Habits, journaling, health, rehab, daily check-ins

- **Rewards:** momentum and low friction. Used daily, often tired; the core action must take seconds, and the screen should make continuity visible and forgive misses.
- **Shows as:** today's single action first and huge; the run of days as the signature (a strip, rings, a calendar, a chain); one tap to log; gentle, warm register; misses shown neutrally, never shamed; progress over weeks rather than per-day scores.
- **Structures:** a chronograph or dial of the day, a training log, a wall calendar with marks, a seed-to-plant growth record, an almanac (day by day with columns), a two-page spread for morning and evening (picked for paper-logbook), a physio plan as a sequence of cards with sets and reps.
- **Keep:** the day boundary the person lives by; streaks that survive a sick day if the person says so; reminders that are easy to snooze or switch off.
- **Avoid:** guilt copy ("You broke your streak!"), gamified confetti on every tap, dense analytics on the logging screen, clinical hospital blue for personal health.

### News, briefs, feeds, reading inboxes

- **Rewards:** recency and hierarchy. The person skims many items fast and wants to know what matters and what's new since last time.
- **Shows as:** a strong editorial type scale (one display, one text face), clear ranking by size and position, timestamps and sources on every item, a visible "since you last looked" line, generous measure for reading, compact list for scanning, keyboard and swipe triage.
- **Structures:** a front page with a lead story and columns, a morning paper with sections, a wire ticker, a reading list ranked by read time, a triage inbox with keep / skip / later bays, a timeline of a developing story.
- **Keep:** source names and publication times; headlines unchanged from the source; a way to open the original.
- **Avoid:** card grids of equal thumbnails, infinite scroll with no "caught up" state, clickbait type tricks, the 1920s broadsheet costume when the content is a modern feed.

### Learning, study, languages, quizzes, courses

- **Rewards:** focus and visible progress. Sessions are effortful; the screen removes everything but the current question, then shows how far the person has come.
- **Shows as:** one prompt at a time in a reading-size face; immediate, specific feedback; spaced-repetition state (due, new, learned) as the main progress signal; a map of the curriculum so the person knows where they are; long-form notes set for reading (60–75ch, serif or humanist text face).
- **Structures:** a metro or curriculum map, a deck with a due pile, a dictionary or glossary filling in (picked for language-learning-lab), a periodic table of concepts, a league table for self-competition, a notebook of worked examples, a cue-card drill.
- **Keep:** the source of every claim or card; the ability to see the answer after an attempt; keyboard-only drilling.
- **Avoid:** childish gamification for an adult learner, dashboards of percentages on the drilling screen, a chat bubble UI for everything.

### Careers, jobs, interviews, résumés

- **Rewards:** confidence and organisation. The person is under pressure and juggling many threads; the UI should make the pipeline obvious and the next action clear.
- **Shows as:** a pipeline by stage with counts, deadlines and next steps; documents shown as the real documents (a résumé looks like a résumé); interview practice focused on one question with a timer and a calm, serious register.
- **Structures:** a case file per application, a departure board of deadlines, a kanban of stages with dates, a rehearsal room with a cue card and a clock, a dossier for a company.
- **Keep:** dates, contact names and links to the originals; exportable documents that print well.
- **Avoid:** LinkedIn-blue corporate sameness, motivational slogans, scorecards that judge the person.

### Agents, ops, runs and monitoring

- **Rewards:** situational awareness and trust. The person checks status and acts on what needs them; the screen must answer "is everything fine, and what needs me?" in one glance.
- **Shows as:** state encoded in form (a pill, a stripe, a position), not only colour; what needs attention at the top; live elements updated in place without layout jumps; times as relative and absolute; dense rows, keyboard actions, logs one click away.
- **Structures:** an air-traffic strip board, a departure board, a mixing desk of lanes, a broadcast cue sheet, a terminal, a building directory of projects.
- **Keep:** every run's start, end and result; links to logs and commits; nothing moves without the person seeing why.
- **Avoid:** a sea of identical status cards, blinking dots, spinner-heavy screens, mission-control cosplay with no real data.

### People, relationships, contacts, events

- **Rewards:** warmth and memory. The person is keeping relationships alive; the UI should bring the right person and context back at the right time.
- **Shows as:** faces or initials as anchors (real avatars when available), the last and next contact as the key data, notes in a readable text face, gentle reminders, groups by circle rather than by database table.
- **Structures:** concentric circles of closeness, a dossier per person, a birthday almanac, an event badge wall, a seating plan, a constellation of people and links.
- **Keep:** privacy cues for sensitive notes; dates people care about.
- **Avoid:** sales-CRM funnels and deal stages for friendships, gradient initial avatars, cold spreadsheets.

### Research, analysis, discovery workbenches

- **Rewards:** rigour and traceability. The person is weighing evidence; every claim must show its source and every number its method.
- **Shows as:** evidence next to the conclusion; source chips; confidence and recency on findings; comparison tables with aligned figures; a clear distinction between data, inference and the person's own notes.
- **Structures:** a lab notebook, a specimen drawer of evidence, a case board, a ledger of experiments with results, a comparison matrix, a radar or scope of signals.
- **Keep:** citations and links; dates collected; reproducible filters.
- **Avoid:** AI-sounding summaries without sources, decorative charts, a hero metric that hides the evidence.

### Places, maps, travel, groups

- **Rewards:** orientation and agreement. The person needs to see where things are and get a group to a decision.
- **Shows as:** the map as the primary surface, with lists synced to it; travel times and distances as real units; each person's position or vote visible; one clear "decided" state.
- **Structures:** a transit map, a meeting-point compass, a postcard rack of options, a voting board, a route card.
- **Keep:** familiar map controls; addresses and times people can copy.
- **Avoid:** maps as decoration beside the real content, pins without labels, stock travel photography.

### Media, watching, listening, lean-back

- **Rewards:** immersion and ease. Used from a sofa or across the room; big targets, few choices, the content itself as the interface.
- **Shows as:** large artwork, very few controls, remote- or keyboard-friendly focus states, what's on now and next, dark ground for video rooms.
- **Structures:** a TV guide grid of channels by time, a record crate, a cinema marquee, a radio dial.
- **Keep:** resume where I left off; clear focus for remote navigation.
- **Avoid:** streaming-service clones, autoplay trailers, dense metadata on the browse screen.

### Games, simulations, sandboxes

- **Rewards:** delight and legibility of state. The person plays; the rules and the current state must be readable while the world feels alive.
- **Shows as:** a strong world identity (this is where costume is welcome), a HUD that stays readable, motion that rewards actions, clear turn or time state.
- **Structures:** the game's own physical analogue (board, table, stage, puppet theatre, case file for a mystery), a control room for a simulation.
- **Keep:** pause, save and undo; a way to inspect any agent or piece.
- **Avoid:** generic dark sci-fi panels for every game, unreadable stylised fonts in the HUD.

### Creative tools and studios (content, video, images, writing)

- **Rewards:** flow and focus on the work. The canvas or draft is the hero; tools recede until needed.
- **Shows as:** a large work area, tool panels that collapse, versions and comparisons side by side, a neutral ground so the work's colours read true, keyboard shortcuts.
- **Structures:** a light table, an editing bay, a storyboard wall, a printer's proof sheet, a writer's desk with drafts.
- **Keep:** undo and version history; export in the formats the person needs.
- **Avoid:** a coloured, busy shell around colour-sensitive work; wizards that hide the canvas.

### Commerce, landing pages, product pages

- **Rewards:** clarity and desire. The visitor decides fast whether this is for them; one path to act.
- **Shows as:** the product itself, large and real; a headline that says what it is and who it's for; proof (reviews, numbers) that is real; one primary action repeated in the same words.
- **Structures:** see [pages.md](pages.md); the product's own world (a record sleeve, a spec sheet, a shop window).
- **Keep:** price, shipping and returns where people look for them.
- **Avoid:** the SaaS template (centred hero, three cards, logo cloud) when the product is physical; invented testimonials.

## Turning the domain into the brief

In the brief, write: `Domain: <the job> · <the state> · rewards <two values>`. Then check every later line against those two values: does this palette, type and composition serve *precision and calm* (money) or *momentum and low friction* (habits)? If a choice serves neither, it's a default; change it.

Example. A subscriptions tracker: job "see what I pay and cut waste, monthly"; state "mildly guilty about money"; rewards *precision* and *calm*. So: a statement structure with renewals on a calendar, tabular ₹ figures with Indian grouping, one accent for "renews soon", no red alarm states, a quiet "worth it?" control beside each line. A habit app with the same palette would be wrong; its rewards are momentum and low friction.
