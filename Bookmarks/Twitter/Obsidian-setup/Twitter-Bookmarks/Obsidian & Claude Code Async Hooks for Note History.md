---
title: "Obsidian & Claude Code: Async Hooks for Note History"
source: "https://x.com/arscontexta/status/2016587691505164749"
author:
  - "[[@arscontexta]]"
published: 2026-01-29
created: 2026-06-09
description: "imagine being able to time travel through your notesyou wrote something three weeks ago and since then youve edited it a dozen timeswith obs..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/G_xRwgPWMAAqpwU?format=jpg&name=large)

imagine being able to time travel through your notes

you wrote something three weeks ago and since then youve edited it a dozen times

with obsidian you only see the current version

what if you could travel back in time and see exactly how your thinking evolved

git can track all of this, but who actually commits after every small edit...

claude code just released async hooks

now you can auto-commit after every edit without slowing anything down and then read that history in a way thats actually useful

## Example

heres what that looks like:

```text
# run the skill with claude code

/note-history @small-world-topology.md
```

the output looks like that:

```plaintext
## small-world topology requires hubs and dense local links

created: jan 20
last edit: jan 28
versions: 6

### timeline

jan 28 | +12 -3  | added uncertainty section, acknowledged that benchmarks
are extrapolations from network science, not validated at
vault scale yet

jan 26 | +18 -8  | connected to spreading activation and checkpoint notes,
the topology argument now links to WHY it matters for
agent traversal

jan 24 | +25 -0  | added architectural implications, quality gates for when
notes have too many or too few links

jan 22 | +15 -4  | refined power-law distribution, sharpened the distinction
between hub nodes (MOCs) and peripheral nodes (claims)

jan 20 | +45     | initial draft from network science research

### evolution pattern

started as research extraction, developed practical implications,
connected to related concepts, added epistemic humility about uncertainty
the note matured from "heres what network science says" to "heres how
we apply it and heres what we dont know yet"
```

the skill doesnt just list commits

it interprets what changed and identifies patterns in how thinking developed

## how it works

you need git set up in your vault, could be github or gitlab or just local

once thats done the rest is automatic

a hook runs silently after every edit and commits the changes in the background while claude keeps working

heres the hook **(.claude/hooks/auto-commit.sh)**:

```bash
#!/bin/bash
cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}"

git add -A 2>/dev/null || exit 0

if git diff --cached --quiet 2>/dev/null; then
    exit 0
fi

CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -5)
FILE_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
STATS=$(git diff --cached --stat 2>/dev/null | tail -1)

if [ "$FILE_COUNT" -eq 1 ]; then
    MSG="Auto: $(echo "$CHANGED_FILES" | head -1)"
else
    MSG="Auto: $FILE_COUNT files"
fi

MSG="$MSG | $STATS"

git commit -m "$MSG" --no-verify 2>/dev/null || true
```

the **async: true** is what makes it work

without that claude would wait for every commit to finish (which is really annoying)

## why this matters

notes are living documents not finished artifacts

what you believed three weeks ago might be wrong now and sometimes understanding why you changed your mind is as valuable as knowing where you landed

the history is the journal of your thinking process and with auto-commits its captured automatically

but raw git history is useless if you cant read it

the interpretation layer is what makes it work

thats what the **/note-history** skill does

claude reads the diffs and explains what changed conceptually not just syntactically

## building your own

create **(.claude/skills/note-history/SKILL.md)**:

```markdown
---
name: note-history
description: Show how a note evolved via git history with interpretation
user-invocable: true
argument-hint: "[note name]"
allowed-tools: Bash,Read
---

# Note History

## Workflow

1. Find the note file from the argument
2. Get git log for that file
3. For each significant commit, read the diff
4. Interpret what changed, not just lines added/removed but what it means
5. Identify patterns in how the thinking evolved
6. Summarize the evolution arc

## Key Commands

git log --follow --format="%h %ad %s" --date=short -- "path/to/note.md"
git diff HASH1..HASH2 -- "path/to/note.md"
git show HASH:"path/to/note.md"

## Output

- When created
- How many versions
- Timeline with interpreted changes
- Evolution pattern summary
```

(this is a simplified version, make this more sophisticated if needed)

## the bigger picture

![Image](https://pbs.twimg.com/media/G_xY2yNWoAEN9cn?format=jpg&name=large)

every note in your vault now has a complete history

when you look back at a note from six months ago you wont just see what it says now

youll see how it got there

your vault becomes a timeline of how your thinking evolved and you can reconstruct any point in that timeline node by node

thats a journal of your thoughts that writes itself

isnt that beautiful?

heinrich