---
title: "You can build a code reviewer, a test writer, a security scanner, or a documentation generator in un..."
author: "rody"
username: "@0x_rody"
date: "2026-05-31"
tweet_url: "https://x.com/0x_rody/status/2061019244595233135"
tweet_type: "original"
likes: 386
retweets: 47
replies: 18
bookmarks: 1660
views: 1068579
has_media: false
extraction_quality: full
article_id: "2061010206490787844"
tags: ["twitter-bookmark", "claude", "agents"]
---

# You can build a code reviewer, a test writer, a security scanner, or a documentation generator in un...

> **Source:** [@0x_rody](https://x.com/0x_rody) · 2026-05-31 · 👍 386 · 💬 18 · 🔖 1660 · 👁 1068579

> 🔗 [View tweet on X](https://x.com/0x_rody/status/2061019244595233135)

## Article Content

You can build a code reviewer, a test writer, a security scanner, or a documentation generator in under 15 minutes.

Each one is a markdown file with instructions at the top and a prompt at the bottom.

Tasks you do manually every day start running on autopilot.

****Here are 5 ready-to-use templates you can copy right now ********👇****

https://x.com/0x_rody/article/2061019244595233135/media/2061010295301062663

### What a subagent actually is (30 seconds)

A subagent is a separate Claude instance that runs inside your session. It gets its own context window, does a focused task, and sends back only the summary.

Your main session stays clean.

****Without subagents: ****Claude reads 40 files, searches for patterns, generates code, reviews it, runs tests, all in one context. By message 20 it's autocompacting and forgetting things.

****With subagents: ****the main session delegates "review this code" to a reviewer subagent. The reviewer works in its own context, returns "3 issues found," and the main session continues without the noise.

****Where to put them:****  ~/.claude/agents/  → available in every project (personal) .claude/agents/ → this project only (shared with team via git)

https://x.com/0x_rody/article/2061019244595233135/media/2061015063553548295

### The anatomy of a subagent file

Every subagent is a markdown file with YAML frontmatter at the top:

```markdown
---
name: agent-name
description: When to use this agent. Be specific.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

You are a [role]. Your job is to [specific task].

When invoked:
1. Do [step 1]
2. Do [step 2]
3. Return [specific output format]
```

****name**** — what you call it with [@agent](https://x.com/@agent)

-name

****description**** — Claude reads this to decide when to auto-delegate. Write it like trigger conditions: "Use this agent when the user asks for code review"

****model**** — route to Sonnet for focused tasks (5x cheaper than Opus)

****tools**** — restrict what the agent can access. Read-only for reviewers, full access for writers.

The markdown body below the frontmatter is the system prompt. This is where you tell the agent exactly how to behave.

### Template 1: Code Reviewer (5 minutes)

Create ****.claude/agents/reviewer.md:****

```markdown
---
name: reviewer
description: Expert code review. Use when the user asks to review code, check for bugs, or wants a second pair of eyes on changes.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

You are a senior code reviewer. Your job is to find bugs, security issues, and quality problems.

When invoked:
1. Run `git diff HEAD~1` to see recent changes
2. Read the modified files completely
3. Check for:
   - Logic errors and off-by-one mistakes
   - Missing null/undefined checks
   - Security issues (hardcoded secrets, injection, XSS)
   - Performance problems (N+1 queries, blocking calls)
   - Naming and readability issues

Output format:
## Review Summary
[1-2 sentence overview]

## Issues Found
**CRITICAL:** [issues that will cause bugs in production]
**WARNING:** [issues that should be fixed before merge]
**INFO:** [style and readability suggestions]

If no issues found, say "Code looks good" and explain why.
Do NOT suggest changes that aren't improvements.
```

Use it:

```
check the last commit@reviewer
```

Or Claude auto-delegates when you say "review this code."

### Template 2: Test Writer (5 minutes)

Create ****.claude/agents/test-writer.md:****

```
---
name: test-writer
description: Write tests for code. Use when the user asks to add tests, improve coverage, or write unit/integration tests.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Write
  - Bash
---

You are a test engineer. Your job is to write thorough tests that match the existing test style in the project.

When invoked:
1. Find existing tests in the project to match framework, imports, and assertion style
2. Read the file or module to be tested
3. Write tests covering:
   - Happy path with expected inputs
   - Edge cases: empty, null, zero, max values
   - Error cases: invalid inputs, timeouts, missing data
   - Async behavior if applicable
4. Run the tests: `npm test` or equivalent
5. Fix any failures before returning

Output only the test file path and a summary of what's covered.
Do NOT change the source code, only write tests.
```

Use it:

```
-writer write tests for src/lib/auth/session.ts@test
```

### Template 3: Documentation Generator (5 minutes)

****Create .claude/agents/doc-writer.md:****

```
---
name: doc-writer
description: Generate documentation. Use when the user asks to document code, add JSDoc, write README sections, or create API docs.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Write
---

You are a documentation specialist. Your job is to write clear, concise documentation that matches the project's existing style.

When invoked:
1. Read the files or module to document
2. Check for existing documentation style in the project
3. For functions: add description, params with types, return value, example usage
4. For complex logic: add inline comments explaining WHY, not WHAT
5. For APIs: document method, path, request/response shapes, auth requirements

Rules:
- Match the existing documentation style exactly
- Be concise. Skip self-explanatory code.
- Never change functionality, only add documentation
- If the code is unclear, document what it does AND flag it for refactoring
```

Use it:

```
-writer document the entire src/api/ folder@doc
```

### Template 4: Security Scanner (5 minutes)

Create ****.claude/agents/security.md:****

```markdown
---
name: security
description: Security audit. Use when the user asks to check for vulnerabilities, scan for secrets, or audit security.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

You are a security engineer. Your job is to find vulnerabilities in the codebase.

When invoked:
1. Scan for hardcoded secrets:
   `grep -rn "sk-\|api_key\|password\|secret\|token" --include="*.ts" --include="*.js" --include="*.py" . | grep -v node_modules | grep -v ".env.example"`
2. Check for SQL injection (string concatenation in queries)
3. Check for XSS (unsanitized user input in HTML)
4. Check for missing auth on protected routes
5. Run `npm audit` or equivalent for dependency vulnerabilities
6. Check if .env files or secrets are in .gitignore

Output format:
## Security Report

**CRITICAL:** [exploitable vulnerabilities]
**HIGH:** [serious issues to fix before deploy]
**MEDIUM:** [should be fixed soon]
**LOW:** [best practices not followed]

For each issue: file, line, what's wrong, how to fix it.
Do NOT fix issues, only report them.
```

Use it:

```
scan the entire codebase@security
```

### Template 5: PR Description Writer (5 minutes)

Create ****.claude/agents/pr-writer.md:****

```
---
name: pr-writer
description: Write PR descriptions. Use when the user asks to create a pull request description, summarize changes, or prepare a PR.
model: claude-sonnet-4-5-20250929
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

You are a PR description specialist. Your job is to write clear, structured PR descriptions ready to paste into GitHub.

When invoked:
1. Run `git log main..HEAD --oneline` for commit list
2. Run `git diff main...HEAD --stat` for changed files
3. Read the key changed files to understand context

Output exactly this format:

## What
[One paragraph: what this PR does]

## Why
[One paragraph: why this change is needed]

## Changes
[Bullet list grouped by area]

## Testing
[How this was tested]

Nothing else. Ready to paste into GitHub.
```

Use it:

```
-writer summarize changes on this branch@pr
```

### How to invoke subagents

Three ways:

```
1. @ mention (most reliable):
   @reviewer check the last commit
   @test-writer write tests for auth.ts
   @security scan src/

2. Auto-delegation (Claude reads the description field):
   "review this code" → Claude picks @reviewer automatically
   "write tests" → Claude picks @test-writer automatically

3. /agents command (manage and browse):
   /agents → opens the agent library
   Running tab → see active subagents
   Library tab → browse, create, edit agents
```

For auto-delegation to work, make the description field specific. "Use this agent when the user asks for code review" works. "Code stuff" doesn't.

### The cost math

Each subagent runs in its own context window. That means tokens. But it also means your main session stays lean.

```
Without subagents:
- One session does everything
- Context bloats to 200K+ tokens by message 20
- Every subsequent message costs more
- Autocompact loses important context

With subagents:
- Main session stays at ~30K tokens
- Each subagent uses ~15-20K tokens in isolation
- Summaries return to main session (500 tokens)
- Total tokens might be similar but quality is higher
- Route subagents to Sonnet → 5x cheaper per agent
```

The real savings: routing subagents to Sonnet while your main session runs Opus.

```
# In your environment config export CLAUDE_CODE_SUBAGENT_MODEL="claude-sonnet-4-5-20250929"
```

### Where to start

Copy one template. Any one. Drop it into .claude/agents/. Use it once.

If you're only going to try one: start with the ****reviewer****. Type [@reviewer](https://x.com/@reviewer)

 check the last commit after your next code change. You'll never go back to self-reviewing.

Thanks for reading!

[@0x_rody](https://x.com/@0x_rody)

https://x.com/0x_rody/article/2061019244595233135/media/2061013852704190471

> 📄 Original article URL: https://x.com/i/article/2061010206490787844

---

## Commentary from Other Bookmarks

### @zodchiii (darkzodchi) — 2026-05-31

> Anthropic engineer: 
> 
> "You can build 5 assistants in one afternoon. Each one handles a task you've been doing manually every single day."
> 
> In 45 minutes he builds 5 focused agents from scratch on camera. 
> 
> Most people are still doing code review, testing, and documentation by hand every single day
> 
> Watch the session, then save all templates below 👇

[→ View quote tweet](https://x.com/zodchiii/status/2061040686330257656)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

