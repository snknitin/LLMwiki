---
title: "Build Claude a Tool for Thought"
source: "https://x.com/arscontexta/status/2015201046469943660"
author:
  - "[[@arscontexta]]"
published: 2026-01-25
created: 2026-06-09
description: "vibe note-taking has the same problem like vibe coding before ralpha few ideas works fine but dump hundreds and you're drowning in slopwhat'..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/G_dNXTIXYAErXyO?format=jpg&name=large)

vibe note-taking has the same problem like vibe coding before ralph

a few ideas works fine but dump hundreds and you're drowning in slop

what's the "testing" for knowledge work?

what catches drift before it compounds?

humans hit this wall too

they built tools for thought to create external systems to think in

claude code needs the same thing but native to how agents work

it should use what agents already have:

- markdown files and wiki links for structure
- yaml and embeddings for discovery
- hooks and subagents for automation and separation
- bash, grep, git, mcp servers for tooling
- code it writes itself to extend the system
- ...

but how do you actually build this?

## the meta layer

![Image](https://pbs.twimg.com/media/G_dNeDEXcAAgXrr?format=jpg&name=large)

the first version IS about tools for thought

the system researches tools for thought to build itself a tool for thought

feed claude methodologies on how humans build knowledge systems

claude figures out what applies to agents and adjusts its own instructions

its important to note that this is evolving right now

every rule starts as a hypothesis and observations get logged to learning files that persist across sessions

so theres always something to reflect on

## the foundation

you can build a graph database out of markdown files

- the files are nodes
- wiki links are the edges that connect them
- yaml frontmatter is metadata you can query

its a knowledge graph that an llm can move through naturally

## example: curating the window

together we figured out how to be more selective about what enters context

at session start it gets a file tree injected

the filenames are claims you can use in-sentence

when you write "since \[\[quality is the hard part\]\] the question becomes..." the title IS the argument

so before opening anything theres already a sense of what each note argues

every note has a yaml header with a one sentence description

```yaml
---
description: cognitive science shows memory retrieval activates neighboring concepts with decaying strength which maps to how agents should load context via wiki links
---
```

before claude loads any file he grabs the description and decides if its worth the context

```plaintext
file tree → descriptions → headings → sections → full content
```

most decisions can be made at the description level without loading full files

## the shoulders of giants

![Image](https://pbs.twimg.com/media/G_dbyWJXIAAGcmW?format=jpg&name=large)

humans have been building tools for thought for centuries

llull built rotating wheels to generate truth through combination of fundamental principles

bruno created memory palaces with millions of image combinations

these werent storage systems, they were tools to think WITH

more recently zettelkasten gave you a network of connected ideas, evergreen notes force you to say complete thoughts and MOCs organize clusters of related thinking

but all of them had one thing in common

a human was the operator

a human used the structure to build on top of that

what we built is different

something else is using this architecture

(and it can build its own)

## the self-engineering loop

dump deep research articles about tools for thought into the inbox

claude reads them and extracts claims

"this method argues that X" becomes a note called "X" that can link to other notes

then it tries to apply those claims to how agents work

observations get logged to files that persist across sessions

and the system reflects its own learnings and thinks about what to change

(still exploring, but thats the idea)

## what this looks like in practice

claude found the cornell notes 5 Rs framework while researching and adapted it for agents

claude added a 6th phase for self-improvement

```text
/reduce
extracts claims from raw content

/reflect
finds connections, updates MOCs

/reweave
updates old notes with new connections

/recite
verifies descriptions enable retrieval

/review
health checks: broken links, orphans, sparse notes

/rethink
challenges system assumptions against evidence

/orchestrate
chains all phases into one pipeline

/learn
requests further research to expand on topics
```

when claude wants to know more about a specific topic, it can request deep research to go learn

hooks run automatically

```plaintext
/session-start.sh
injects vault context like file tree

/validate-note.sh
checks quality after every write

/subagent-complete.sh
reminds about MOC updates after agent work

/session-stop.sh
checks for broken links, prompts logging
```

subagents do parallel specialized work

```plaintext
reduce
high-volume claim extraction (sonnet)

reflect
connection finding (sonnet)

recite
description verification (haiku)

review
health check swarm (haiku)
```

## the rough edges

this is a living system

giving complete control to claude code and literally vibe note-take based on what it learns about tools for thought from humans

if you have ideas or want to explore this together, reach out

honestly not sure if any of this makes sense

im 36 hours into a claude code bender with two friends

nevermind forget about everything

heinrich