---
title: "Everyone is raving about Ralph. What is it?"
author: "Ryan Carson"
username: "@ryancarson"
date: "2026-01-06"
tweet_url: "https://x.com/ryancarson/status/2008548371712135632"
tweet_type: "original"
likes: 4936
retweets: 408
replies: 142
bookmarks: 12159
views: 1908717
has_media: false
extraction_quality: full
article_id: "2008496235791929345"
tags: ["twitter-bookmark", "claude", "agents"]
---

# Everyone is raving about Ralph. What is it?

> **Source:** [@ryancarson](https://x.com/ryancarson) · 2026-01-06 · 👍 4936 · 💬 142 · 🔖 12159 · 👁 1908717

> 🔗 [View tweet on X](https://x.com/ryancarson/status/2008548371712135632)

## Article Content

Everyone is raving about Ralph. What is it?

Ralph is an autonomous AI coding loop that ships features while you sleep.

Created by [@GeoffreyHuntley](https://x.com/@GeoffreyHuntley)

 and announced in [his original post](https://ghuntley.com/ralph)

, it runs [@AmpCode](https://x.com/@AmpCode)

 (or your agent of choice) repeatedly until all tasks are complete.

Each iteration is a fresh context window (keeping Threads nice and small). Memory persists via git history and text files.

I ran it for the first time and shipped a feature last night. I love it.

https://x.com/ryancarson

****Ryan Carson****

@ryancarson

Â·

[6 Jan](https://x.com/ryancarson/status/2008383176339579040)

Didn't even get to bed yet. Already done.

Impressed.

https://x.com/ryancarson/status/2008383176339579040/photo/1

Quote

****Ryan Carson****

@ryancarson

Â·

6 Jan

GIF

Going to kick off a Ralph session in Amp tonight to see if it can build a pretty complete feature while I sleep.

Currently chatting with Amp to build the PR, which we'll use to populate the user stories json.

Then I'll start the script and go to bed.

### How It Works

(Here's a [complete GitHub repo](https://github.com/snarktank/ralph)

 for you to download and try.)

A bash loop that:

1. Pipes a prompt into your AI agent
2. Agent picks the next story from prd.json
3. Agent implements it
4. Agent runs typecheck + tests
5. Agent commits if passing
6. Agent marks story done
7. Agent logs learnings
8. Loop repeats until done

****Memory persists only through:****

- Git commits
- progress.txt (learnings)
- prd.json (task status)

****File Structure****

```bash
scripts/ralph/
â”œâ”€â”€ ralph.sh
â”œâ”€â”€ prompt.md
â”œâ”€â”€ prd.json
â””â”€â”€ progress.txt
```

### ralph.sh

The loop:

```bash
#!/bin/bash
set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname \
  "${BASH_SOURCE[0]}")" && pwd)"

echo "ðŸš€ Starting Ralph"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo "â•â•â• Iteration $i â•â•â•"
  
  OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" \
    | amp --dangerously-allow-all 2>&1 \
    | tee /dev/stderr) || true
  
  if echo "$OUTPUT" | \
    grep -q "<promise>COMPLETE</promise>"
  then
    echo "âœ… Done!"
    exit 0
  fi
  
  sleep 2
done

echo "âš ï¸ Max iterations reached"
exit 1
```

Make executable:

```bash
chmod +x scripts/ralph/ralph.```sh

****Other agents:****

- Claude Code: `claude --dangerously-skip-permissions`

### prompt.md

Instructions for each iteration:

```markdown
# Ralph Agent Instructions

## Your Task

1. Read `scripts/ralph/prd.json`
2. Read `scripts/ralph/progress.txt`
   (check Codebase Patterns first)
3. Check you're on the correct branch
4. Pick highest priority story 
   where `passes: false`
5. Implement that ONE story
6. Run typecheck and tests
7. Update AGENTS.md files with learnings
8. Commit: `feat: [ID] - [Title]`
9. Update prd.json: `passes: true`
10. Append learnings to progress.txt

## Progress Format

APPEND to progress.txt:

## [Date] - [Story ID]
- What was implemented
- Files changed
- **Learnings:**
  - Patterns discovered
  - Gotchas encountered
---

## Codebase Patterns

Add reusable patterns to the TOP 
of progress.txt:

## Codebase Patterns
- Migrations: Use IF NOT EXISTS
- React: useRef<Timeout | null>(null)

## Stop Condition

If ALL stories pass, reply:
<promise>COMPLETE</promise>

Otherwise end normally.
```

### prd.json

Your task list:

```json
{
  "branchName": "ralph/feature",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add login form",
      "acceptanceCriteria": [
        "Email/password fields",
        "Validates email format",
        "typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

****Key fields:****

- `branchName` â€” branch to use
- `priority` â€” lower = first
- `passes` â€” set true when done

### progress.txt

Start with context:

```markdown
# Ralph Progress Log
Started: 2024-01-15

## Codebase Patterns
- Migrations: IF NOT EXISTS
- Types: Export from actions.ts

## Key Files
- db/schema.ts
- app/auth/actions.ts
---
```

Ralph appends after each story.

Patterns accumulate across iterations.

### Running Ralph

```bash
./scripts/ralph/ralph.sh 25
```

Runs up to 25 iterations.

Ralph will:

- Create the feature branch
- Complete stories one by one
- Commit after each
- Stop when all pass

### Critical Success Factors

****1. Small Stories****

Must fit in one context window.

plaintext

```
âŒ Too big:
> "Build entire auth system"
âœ… Right size:
> "Add login form"
> "Add email validation"
> "Add auth server action"
```

****2. Feedback Loops****

Ralph needs fast feedback:

- `npm run typecheck`
- `npm test`

Without these, broken code compounds.

****3. Explicit Criteria****

plaintext

```
âŒ Vague:
> "Users can log in"
âœ… Explicit:
> - Email/password fields
> - Validates email format
> - Shows error on failure
> - typecheck passes
> - Verify at localhost:$PORT/login (PORT defaults to 3000)
```

****4. Learnings Compound****

By story 10, Ralph knows patterns from stories 1-9.

Two places for learnings:

1. ****progress.txt**** â€” session memory for Ralph iterations
2. ****AGENTS.md**** â€” permanent docs for humans and future agents

Before committing, Ralph updates AGENTS.md files in directories with edited files if it discovered reusable patterns (gotchas, conventions, dependencies).

****5. AGENTS.md Updates****

Ralph updates AGENTS.md when it learns something worth preserving:

plaintext

```
âœ… Good additions:
- "When modifying X, also update Y"
- "This module uses pattern Z"
- "Tests require dev server running"
âŒ Don't add:
- Story-specific details
- Temporary notes
- Info already in progress.txt
```

****6. Browser Testing****

For UI changes, use the [dev-browser skill](https://github.com/SawyerHood/dev-browser)

 by [@sawyerhood](https://x.com/@sawyerhood)

. Load it with `Load the dev-browser skill`, then:

```bash
# Start the browser server
~/.config/amp/skills/dev-browser/server.sh &
# Wait for "Ready" message

# Write scripts using heredocs
cd ~/.config/amp/skills/dev-browser && npx tsx <<'EOF'
import { connect, waitForPageLoad } from "@/client.js";

const client = await connect();
const page = await client.page("test");
await page.setViewportSize({ width: 1280, height: 900 });
const port = process.env.PORT || "3000";
await page.goto(`http://localhost:${port}/your-page`);
await waitForPageLoad(page);
await page.screenshot({ path: "tmp/screenshot.png" });
await client.disconnect();
EOF
```

Not complete until verified with screenshot.

### Common Gotchas

****Idempotent migrations:****

```sql
ADD COLUMN IF NOT EXISTS email TEXT;
```

****Interactive prompts:****

```bash
echo -e "\n\n\n" | npm run db:generate
```

****Schema changes:****

After editing schema, check:

- Server actions
- UI components
- API routes

****Fixing related files is OK:****

If typecheck requires other changes, make them. Not scope creep.

### Monitoring

```bash
# Story status
cat scripts/ralph/prd.json | \
jq '.userStories[] | {id, passes}'
# Learnings
cat scripts/ralph/progress.txt
# Commits
git log --oneline -10
```

### Real Results

We built an evaluation system:

- 13 user stories
- ~15 iterations
- 2-5 min each
- ~1 hour total

Learnings compound. By story 10, Ralph knew our patterns.

### When NOT to Use

- Exploratory work
- Major refactors without criteria
- Security-critical code
- Anything needing human review

For a great video walkthrough of how to use Ralph, checkout the video from [@mattpocockuk](https://x.com/@mattpocockuk)

 ...

https://x.com/mattpocockuk

****Matt Pocock****

@mattpocockuk

Â·

[5 Jan](https://x.com/mattpocockuk/status/2008200878633931247)

My Ralph Wiggum breakdown went viral.

It's a keep-it-simple-stupid approach to AI coding that lets you ship while you sleep.

So here's a full explanation, example code, and demo.

![](https://pbs.twimg.com/amplify_video_thumb/2008199065901703168/img/RL13KJK9DQjyi8iI.jpg)

> 📄 Original article URL: https://x.com/i/article/2008496235791929345

