---
title: "Obsidian & Claude Code 101: Context Engineering"
source: "https://x.com/arscontexta/status/2015585363318743071"
author:
  - "[[@arscontexta]]"
published: 2026-01-26
created: 2026-06-09
description: "vibe note-taking works better if you force claude code to be selective about what it readsby default claude reads full files whenever they s..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/G_jMEFMXEAAhxVM?format=jpg&name=large)

vibe note-taking works better if you force claude code to be selective about what it reads

by default claude reads full files whenever they seem useful for the task

use 4 layers to be more selective

the pattern is called progressive disclosure

## 1\. file tree

a session start hook injects the full file tree before claude touches anything

```json
"hooks": {
    "SessionStart": [{
        "hooks": [{
            "type": "command",
            "command": "tree -L 3 -a -I '.git|.obsidian' --noreport"
        }]
    }]
}
```

this gives claude the map before it starts exploring

filenames are descriptive so they work as a first impression

**"queries evolve during search so agents should checkpoint md"**

tells you more than "**search notes md"**

just reading the tree already shows what notes are about

## 2\. yaml descriptions

every note has a one sentence description in the frontmatter

```yaml
---
description: Memory retrieval in brains works through spreading activation where neighbors prime each other. Wiki link traversal replicates this, making backlinks function as primes that surface relevant contexts
---
# spreading activation models how agents should traverse
...
```

the description elaborates the title

if something seems interesting claude queries it with ripgrep

```bash
rg "^description:" 01_thinking/*.md
```

## 3\. outline

if a note passes the description filter claude checks the outline

sometimes you only need one section and loading the full file would create noise

```text
grep -n "^#" "01_thinking/knowledge-work.md"
# output:
# 5:# knowledge-work
# 13:## Core Ideas
# 19:## Tensions
# 23:## Gaps
```

now claude knows where to look and can read what it needs

## 4\. full content

if everything seems relevant for the task claude loads the full file

but only for notes that passed all three filters

most notes never get here but thats the point

when claude has to justify each read it curates better

## the mcp parallel

this isnt a new pattern

mcp tool discovery works the same way

when you have 50+ tools claude doesnt load all definitions into context upfront

tool specs are available but deferred until claude actually searches for them

```plaintext
tool list → tool search → tool references → full definitions
```

same structure:

```plaintext
file tree → descriptions → outline → full content
```

## implementation

the whole thing is just:

1. a SessionStart hook that runs \`tree\`
2. yaml frontmatter with a description field
3. instructions in claude md telling claude to check descriptions before reading

just a few constraints that force selectivity

heinrich