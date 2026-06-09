---
title: "Vibe Note-Taking 101: Editing Workflow"
source: "https://x.com/arscontexta/status/2015909609999941965"
author:
  - "[[@arscontexta]]"
published: 2026-01-27
created: 2026-06-09
description: "editing long content with claude code sucksthe normal way looks like this:read through your draftnotice paragraph 3 needs workcopy that para..."
tags:
  - "clippings"
---
![Image](https://pbs.twimg.com/media/G_npF0tXsAAyzdN?format=jpg&name=large)

editing long content with claude code sucks

the normal way looks like this:

- read through your draft
- notice paragraph 3 needs work
- copy that paragraph
- paste it to claude with your comment
- scroll to paragraph 7
- copy that one too
- paste it with another comment
- scroll to paragraph 12
- same thing

the edits work fine

its the back and forth thats annoying

same problem when you have edits across multiple files that need to stay consistent with each other

> "hey claude in this file i need you to change the part where it says vaults are cool to something more specific, and then in the other file update the reference to match, oh and also in that third file..."

## spatial editing

instead of bringing text TO claude you leave instructions WHERE they belong

curly braces mark your **{thoughts and edit instructions}**

each comment applies to its surrounding text, or points somewhere else if you say so

here is an example:

```markdown
# why vaults matter

vaults give claude memory
{feels abstract}

without persistent storage claude forgets everything between sessions
{this is the key point, make it hit harder}

the solution is simple
{dont say simple, show}
```

output:

```markdown
# why vaults matter

vaults give claude persistent memory across sessions by storing context in files it can read and write

without persistent storage claude starts fresh every conversation, you re-explain the same context, rebuild the same understanding, lose the compound effect of accumulated knowledge

the solution: store everything in markdown files that claude can traverse
```

the command outputs a summary so you know what changed:

```plaintext
processed 3 edits in why-vaults-matter.md:
1. "feels abstract" → added concrete mechanism
2. "make it hit harder" → expanded with specific pain points
3. "dont say simple" → replaced with direct statement
```

## the command

```plaintext
/edit
currently open file

/edit draft.md
specific file

/edit draft.md notes.md
multiple files
```

if you run **/edit** with nothing open it searches your vault for **{thoughts}**:

```bash
rg "\{[^}]+\}" --type md -l
```

then lets you pick which files to edit

## the workflow

1. write your draft without stopping
2. do a quick read and drop **{thoughts}** wherever something feels off
3. run **/edit**
4. review changes

position IS context

you dont need to explain what youre referring to because the comment knows where it lives

if you want to build something similar, use the skill-creator skill that comes with claude code plugins and paste in this article

heinrich