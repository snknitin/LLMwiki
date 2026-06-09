---
title: "Tohoho's Introduction to Claude Code - Tohoho's Introduction to WWW"
source: "https://www.tohoho-web.com/ai/claude-code.html"
author:
published: 2026-05-10
created: 2026-06-09
description:
tags:
  - "clippings"
---
## Tohoho's Introduction to Claude Code

## What is Claude Code?

- Claude series provided by Anthropic [AI Coding Assistant](https://www.tohoho-web.com/ai/coding-assistant.html) It is.
- OpenAI [Codex](https://www.tohoho-web.com/ai/codex.html) We share the same. ([Trending situation](https://trends.google.co.jp/trends/explore?geo=JP&q=GitHub%20Copilot,Cursor,Claude%20Code,Antigravity,Codex&hl=ja))
- It will fix your code by following instructions such as "Create a program for ○○" and "Fix a bug in ○○".
- These days, it's not just programming, but also working with Gmail and Google Calendar to "let me know if you have any urgent emails," "make plans," or launch it in a folder where you store sales data, "analyze sales," "plan sales improvement measures," etc There have been cases where they have been used as business partners.
- The following usage formats are available:
	- CLI version: This is the most commonly used version. Run Claude Code on the command line.
		- VSCode version: Used as an extension to VSCode.
		- Claude Code Desktop version:[Claude Desktop](https://claude.com/ja-jp/download) Use Claude Code in your app.
		- Web version: from your browser [claude.ai/code](https://claude.ai/code) Access and utilize.
		- Other IDE versions: Use as a plugin for JetBrains IDEs such as IntelliJ IDEA, PyCharm, and WebStorm.
- This book mainly covers the CLI version of Claude Code 2.1.133.
- The specifications change quite a bit depending on the version, so if you have any concerns, just ask Claude.

## Installation

See installation details below. Here we will discuss the CLI version of Claude Code. You can also install the VSCode version from the URL below.

- [https://code.claude.com/docs/ja/overview](https://code.claude.com/docs/ja/overview)

Install Claude Code by running the command according to your OS.

```c
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash

Windows PowerShell
irm https://claude.ai/install.ps1 | iex

Windows CMD
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

If the following message is displayed:`~/.bashrc` に `export PATH="$HOME/.local/bin:$PATH"` Please add the following.

```c
⚠ Setup notes: ● Native installation exists but ~/.local/bin is not in your PATH.  Run: echo 'export PATH="$HOME/.local/bin:$PATH"' >> your shell config file && source your shell config file$ echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc$ source ~/.bashrc
```

`git` 、 `fd` (`find` An enhanced version of),`rg` (`grep` An enhanced version of) is also useful to install. If you want to work with GitHub [`gh`](https://github.com/cli/cli#installation) Commands are also recommended.

```c
# For RHEL series
dnf -y install epel-releasednf -y install git fd-find ripgrep

# For Debian/Ubuntu
sudo apt -y install git fd-find ripgrepsudo ln -s/usr/bin/fdfind/usr/local/bin/fd

# For Windows
winget install Git.Git sharkdp.fd BurntSushi.ripgrep.MSVC
```

Once installed, the project folder (for example `myapp`) and create `claude` Command (`~/.local/bin/claude`) Start.

```c
mkdir myappcd myappclude
```

First you will be asked the theme (color mode). Select your preferred color mode and enter.

```c
1.  Auto (match terminal) ❯ 2.  Dark mode ✔ 3.  Light mode 4.  Dark mode (colorblind-friendly) 5.  Light mode (colorblind-friendly) 6.  Dark mode (ANSI colors only) 7.  Light mode (ANSI colors only)
```

You will be asked how to log in. 1 if you use a fixed-rate plan from Pro, Max, Team, or Enterprise, 2 if you use API pay-as-you-go, or 3 if you use a third-party plan like Amazon. Choose. 1. If you select, a browser will be opened or you can log in to Claude by opening the displayed URL from your browser and attach the displayed code to Claude Code.

```c
❯ 1.  Claude account with subscription Pro, Max, Team, or Enterprise 2.  Anthropic Console account · API usage billing 3. 3rd-party platform · Amazon Bedrock, Microsoft Foundry, or Vertex AI
```

Once you're logged in, they'll tell you to press Enter, so you enter.

```c
Login successful.  Press Enter to continue…
```

Claude Code usage notes are displayed. It says that Claude should only be used with trusted code, as it may be incorrect and users should check it, and there is a security risk of prompt injection. Once you understand, please enter.

```c
1.  Claude can make mistakes You should always review Claude's responses, especially when running code.  2.  Due to prompt injection risks, only use it with code you trust Learn more: https://code.claude.com/docs/en/security
```

You will be asked to verify that the current folder is reliable. If it's a trusted folder 1. Please select and enter.

```c
❯ 1.  Yes, I trust this folder 2.  No, exit
```

The following prompt input field will be displayed, allowing you to instruct "Create ○○" etc.

```c
────────────────────────────────────────────❯ Try "fix lint errors"
────────────────────────────────────────────
```

## Folder Configuration

Home directory (for Linux and Mac `~/.claude`, for Windows `C:\Users\*user-name*\.claude`) Folders and files such as the following will be created under your command:

```c
.claude/
├CLAUDE.md            - Basic Rules
├agent-memory/            - Storage area for subagents
├agents/            - Subagent
├backs/            - Automatic backup
├cache/            - Cache
├commands/            - Command folder
│└command-name.md        - Command
├downloads/            - Download
├ide/                - For IDE integration
├file-history/            - File history
├history.json            - History of prompts entered
├hooks/            - Hook
├plugins/            - Plugins
│└marketplaces/        - Marketplace
│ └claude-plugins-official/    - Official Plugin
│ ├plugins/        - Plugins
│ └external_plugins/    - External plugins
├projects/            - Project
│└-user-project/        - Individual project information
│ ├uuid.jsonl        - Prompt and response history
│ ├memory/            - Memory (Rules)
│ ├MEMORY.md            - Memory (Rules)
│ └feedback_no_borders.md    - Memory (Rules)
├session-env/            - For session environments
├sessions/            - Session Information
├settings.json            - Configuration files
├shell-snapshots/        - Shell execution snapshot
└skills/            - Skills folder
　└skill-name/            - Individual skill folders
　　└SKILL.md            - Skill Entity
```

`myapp` The following folders and files will be created under the project folder:

```c
CLAUDE.md
.claude/
├agent-memory/                 - Storage area for subagents
├agents/                       - Subagent
├commands/                     - Command folder
│└command-name.md             - Command
├settings.json                 - Configuration files (common to projects)
├settings.local.json           - Configuration file (personal)
└skills/                       - Skills folder
```

## Settings

### Settings (settings.json)

Describes the configuration information for Claude Code.

- `~/.claude/settings.json`: Personal Rules
- `<*project*>/.claude/settings.json`: Project Rules
- `<*project*>/.claude/settings.local.json`: Project-specific personal rules (`.gitignore` To register with the

The following is `ls, fd, rg` This is a setting that allows execution without confirmation. For details [Claude Code Settings](https://code.claude.com/docs/ja/settings?utm_source=chatgpt.com) See.

```c
{ "permissions": { "allow": [ "Bash(ls *)", "Bash(fd *)", "Bash(rg *)", "Bash(which *)" ] }}
```

### Basic rules (CLAUDE.md)

It is a Markdown format file that tells Claude Code the basic rules.

- `~/.claude/CLAUDE.md`: Personal Rules
- `<*projectFolder*>/CLAUDE.md`: Project Rules

For example, the following rules are given:

```c
# CLAUDE.md## Basic policy - Answers and explanations should be as concise as possible in Japanese. - Markdown lines and tables should not be used for answers and explanations. - Any revisions of more than 20 lines should be reviewed by presenting the target file and policy before revision. - Review refactoring other than the instructions ordered. -. Never refer to the contents of an env file. ## Development Rules - Coding style follows PEP 8. - Prioritize existing design, naming, and formatting. ## Test rules - Perform syntax checking with pylint on modified code. - Perform coding style checking with flake8 on modified code. - Create test code under the test folder on modified code and perform unit testing with pytest. ## Other rules - Do not commit / push without permission.
```

### Memory (MEMORY.md)

If you provide instructions regarding ground rules, such as "○○Do not," Claude may record them as project rules in the file below. It is not a matter for the user to add.

```c
.claude/projects/<projectName>/memory/MEMORY.md
```

## Function

### Hooks (hooks)

You can execute a hook when some event occurs. For example, to "run log.sh" and log when "Claude Code response has finished (Stop)", set it as follows:

`~/.claude/settings.json`

```
{ : "hooks": { "Stop": [ { "matcher": "", "hooks": [ { "type": "command", "command": "~/.claude/hooks/log.sh" } ] } ] }}
```

`~/.claude/hooks/log.sh`

```
#! /usr/bin/env bashecho "[HOOK] Claude Code executed at $(date)" >> ~/.claude/hooks.log
```

For details [Hooks Reference](https://code.claude.com/docs/ja/hooks) See.

### Commands (commands)

You can extend the / command by placing the command file in the directory below. The extended command is in Claude Code `/*command-name*` It can be called with.

```c
.claude/commands/command-name.md : Project Commands
~/.claude/commands/command-name.md : Personal commands (Linux)
C:\Users\user-name\.claude\commands\command-name.md : Personal Commands (Windows)
```

`*command-name*.md` For example, write the following:

```c
---description: Describe the enhancement points you made today---Describe a summary of the enhancements or fixes you made today.
```

### Skills (skills / SKILL.md)

You can extend your skills by placing the skills file in the directory below.[Command](#commands) It is similar to `SKILL.md` Store not only files but also programs such as shells and Python in folders as needed `SKILL.md` It can be called from. The expanded skills are in Claude Code `/*skill-name*` You can call it with, or Claude Code will call it automatically depending on the conversation.

```c
.claude/skills/skill-name/SKILL.md : Project Skills
~/.claude/skills/skill-name/SKILL.md : Personal Skills (Linux)
C:\Users\user-name\.claude\skills\skill-name\SKILL.md : Personal Skills (Windows)
```

`SKILL.md` For example, write the following:`name` If you omit, the folder name becomes the name. When Claude Code starts `name` と `description` It only loads and uses it to determine which skills to use when.`description` is up to 1024 characters,`SKILL.md` Files should be no longer than 500 lines.

```c
---
name: code-check
description: Check and fix source code style and syntax - Run style-and-lint-check.sh on the file you added or modified to fix the extracted issue.
```

`name` と `description` Other than `allowed-tools` と `model` You can specify. The list of tool names is [Tool Reference](https://code.claude.com/docs/ja/tools-reference) See.

```c
---
name: ...
description: ...
allowed-tools: Read, Grep, Glob, Bash
model: sonnet---
```

For details [Extend Claude with Skills](https://code.claude.com/docs/ja/skills) See.

### Subagents (agents)

You can create subagents as specialized AI assistants that handle specific types of tasks. The subagent will be created in the folder below.

```c
project/.claude/agents/agent-name.md:Project
~/.claude/agents/agent-name.md:Personal Agent (Linux)
C:\Users\user-name\.claude\agents\agent-name.md:Personal Agent (Windows)
```

`*agent-name*.md` can be written directly,`/agents` You can also have Claude Code create it for you with the command: The agent created is `/agents` You can run it from a command, call it in natural language like "run ○○", or Claude Code will call it automatically. For details [Creating a Custom Subagent](https://code.claude.com/docs/ja/sub-agents) See.

### Connectors (MCP server)

It is possible to use the connector (MCP server) from Claude Code, but currently it must be registered from Claude Desktop.[Connector](https://www.tohoho-web.com/ai/claude.html#connectors) See. Registered connectors are `/mcp` You can check the status with the command.`~/.claude.json` You can also write it as follows:

```c
{ "mcpServers": { "my-mcp-server-name": { "type": "http", "url": "https://example.com/mcp" } }}
```

### LSP (LSP Server)

[LSP (Language Server Protocol)](https://microsoft.github.io/language-server-protocol/) is a protocol proposed by Microsoft in 2016. It is a server that teaches programming language parsing, syntax highlighting, variable types, function calling relationships, code completion candidates, and more. You can increase speed and reliability by querying a more LSP server, where coding assistants like Claude Code individually implement language-by-language correspondence, and you can also reduce the thought load on your models. It is an LSP server for Python `pyright-lsp` The steps to install it are shown below.

- `nodejs, npm` Install.
	```c
	# Debian/Ubuntu series
	sudo apt -y install nodejs npm
	# RHEL series
	dnf -y install nodejs npm
	```
- `pyright` Install.
	```c
	npm install -g pyright
	```
- From Claude Code `/plugin` Execute the command.
- `lsp` Search for `pyright-lsp` Select the plugin and enter.
- Select and install the installation range (Personal or Repository or Personal & Repository).
- `/reload-plugins` Run to reload the plugin.
- `/plugin` Run `Installed` The LSP from the tab is `enabled` Make sure that it is.

### Plugins (plugins)

The plugin can be used to [Hook](#hooks) 、 [Command](#commands) 、 [Skills](#skills) 、 [Subagent](#subagents) 、 [Connector](#connectors) 、 [LSP Server](#lsp-server) It combines the above into one package.

```c
plugin-name/
├.claude-plugin/ - Plugin information including plugin.json
├settings.json   - Configuration information
├bin/            - Commands that can be called from plugins
├hooks/          - Hook
├commands/       - Command
├skills/         - Skills
├agents/         - Subagent
├.mcp.json       - Connector (MCP server)
├.lsp-json/      - LSP server
├monitors/       - Background monitor
```

For details [Create a plugin](https://code.claude.com/docs/ja/plugins) See.

## slash command(/command)

In the Claude Code prompt input field `/status` You can use slash commands such as: Some environments may not display it.`**[***mode***]**` etc `**[**...**]**` Subcommands enclosed in mean optional. The command you want to remember is `/exit, /model, /usage, /clear, /compact, /resume` I wonder if around.

- [https://code.claude.com/docs/ja/commands](https://code.claude.com/docs/ja/commands)

### End

/exit (/quit)

Exit Claude Code.

### Conversation history

/context

Displays the current context usage.

/clear (/reset /new)

Clear all conversation history to free up context. A longer conversation history means more tokens to process, which can lead to faster usage limits for monthly purchases or higher costs for pay-as-you-go purchases. When new modifications or modifications are made `/clear` or `/compact` It is recommended that you delete or summarize your conversation history with.

/compact \[*prompt*\]

Summarize your conversation history to free up context.`*prompt*` You can also specify instructions such as "Keep the unaddressed TODO list and priority."

/export \[*file*\]

Export your conversation history to a clipboard or text file.

/copy \[*N*\]

Last `*N*` Copy the answers to your clipboard.`*N*` When omitted, it is considered to be 1.

### Session Management

/rewind (/checkpoint /undo)

A list of checkpoints will appear and you can rewind to the selected checkpoint. Checkpoints are automatically created for each instruction. Claude Code `rm` You cannot rewind the results of a command such as:

/branch \[*name*\] (/fork)

Branch create a session.

/rename \[*name*\] (/name)

Change the session name.

/resume \[*name*\] (/continue)

Resume the session.`/exit` When you end the session with `"claude --resume f33df2e9-1234-5678-9012-abcdefghijkl"` You will see a session ID like this:`claude` Command `--resume` You can also optionally resume it.

/recap

Generates a one-line summary of the session.

/add-dir *path*

Adds a working directory to the current session.

### Setting system

/config (/settings)

Change settings such as theme and model.

/model \[*model*\]

Switch models.

/effort \[*level*\]

Set the effort level for the model.`*level*` In the `**low**, **medium**, **high**, **xhigh**, **max**` Specify one of the following.

/fast \[*mode*\]

Toggle Fast mode on/off.`*mode*` In the `**on**, **off**` Specify one of the following. You'll get a faster response in a mode exclusive to Claude Opus instead of paying more than usual.

/theme

Change the color theme.

/color \[*color*\]

Set the prompt bar color.

/tui *mode*

Change the UI mode of the terminal.`*mode*` In the `**default**, **fullscreen**` Specify one of the following. For details [Fullscreen rendering](https://code.claude.com/docs/ja/fullscreen) See.

/focus

Toggle between focus and non-focus modes. Focus mode only shows the final prompt, final response, etc., and hides unnecessary displays so you can focus on interacting with the model. Only available in full screen mode. For similar functions `Ctrl-o` There is a display detail change by.

/statusline

Customize the status line at the bottom of the prompt input field. For details [Customize your status line](https://code.claude.com/docs/ja/statusline) See.

/extra-usage

Toggle On/Off mode, which allows you to continue processing using the cost of your API pay-as-you-go plan if you exceed the fixed-rate plan limit. A pay-as-you-go plan agreement is required.

/privacy-settings

Toggle whether session data should be allowed to be used to train and improve the Anthropic model.

/fewer-permission-prompts

To analyze past usage and reduce the number of permissions Claude Code asks for `.claude/settings.json` I would like to suggest some improvements on what permission list should be added to.

/update-config

Launch Modify Config File Assistance.

/advisor

When using a lower-level model (e.g., Haiku), allow the higher-level model (e.g., Opus) to be consulted if necessary.

/permissions

Manage permissions for tool execution.

### Information display system

/help

Show Help.

/status

Displays status such as version, model, and account information.

/usage (/cost /stats)

View the cost and usage statistics for the current session.

/heapdump

Prints a heap dump for memory diagnostics.

### Authentication/Account

/login

Sign in to your Anthropic account.

/logout

Sign out of your Anthropic account.

/upgrade

Navigate upgrades to higher plans.

### Code Management and Review

/diff

Opens an interactive diff viewer.

/simplify

We review our recently changed code (git diff HEAD).

/review \[*PR\_number*\]

Review pull requests.

/ultrareview \[*PR\_number*\]

Conduct a multi-agent in-depth review.

/security-review

Review security issues.

/autofix-pr \[*prompt*\]

Monitor and auto-correct pull requests [Claude Code on the Web](https://code.claude.com/docs/ja/claude-code-on-the-web#auto-fix-pull-requests) Generate a session.

/debug \[*description*\]

Enable debug logging to troubleshoot. This is useful when Claude Code itself doesn't work, such as when a skill or connector call fails, or why the Hook didn't start.`*description*` "○○Why did the skill call fail?" Specify questions such as:

### Planning and Task Management

/plan \[*description*\]

`*description*` Enter plan mode to achieve the objectives specified in. Plan mode does not modify files, only an execution plan. The execution plan created is `~/.claude/plans/*plan-name*.md` It will be saved to a file and you can also correct the plan in the editor.`Shift-Tab` You can also switch plan modes with the key.

/ultraplan \[*prompt*\]

When planning a major renovation,[Claude Code on the Web](https://code.claude.com/docs/ja/claude-code-on-the-web#auto-fix-pull-requests) Above we will carry out planning using Opus. In the meantime, the terminal can do other work. Once planning is complete, the terminal will be notified and you will be able to review the plan in your browser.

/tasks (/bashes)

Manage background tasks.

### Cloud Remote Function

/desktop (/app)

Launch the desktop app and continue with the current session.

/remote-control (/rc)

Make this session remotely operable.`/remote-control` When you run it, a URL will be issued, allowing you to interact with this session from the browser that visited the URL or from the Claude app on your smartphone. You can request time-consuming processing and even check the progress from your smartphone. For details [Remote Control to continue local session from any device](https://code.claude.com/docs/ja/remote-control) See.

/teleport (/tp)

[Claude Code on the Web](https://code.claude.com/docs/ja/claude-code-on-the-web#auto-fix-pull-requests) Import the session into this terminal.

/remote-env

`--remote` Optionally select the default environment for the remote session you started.

### Extensions and integrations

/mcp

Manage MCP servers (connectors).

/skills

List available skills.

/ide

Manage your IDE integration environment.

/keybindings

Key Binding Configuration File `~/.claude/keybindings.json` Open the.

/terminal-setup

`Shift+Enter` Assign a line break to instead of sending. It is available in IDE environments such as VSCode.

/chrome

Chrome Extension [Claude in Chrome](https://code.claude.com/docs/ja/chrome) Enable collaboration with.`claude` Command `--chrome` It can also be enabled optionally. You can control Claude in Chrome from the CLI or VSCode's Claude Code.

/voice \[*mode*\]

Toggle voice input On/Off. If voice input is on, you can press and hold the spacebar to enter voice. The language you recognize is `/config` の `Language` You can change it at.`*mode*` In the `**hold**` (hold),`**tap**` (tap),`**off**` You can specify either (off).

/plugin

Manage plugins.

/reload-plugins

Reload the plugin.

/memory

A file that sets the constant instructions (ground rules) that you want Claude Code to remember (`./CLAUDE.md` or `~/.claude/CLAUDE.md`) Open. For details [How Claude remembers your project](https://code.claude.com/docs/ja/memory) See.

/hooks

Displays the hook settings for the tool event. The settings are `~/.claude/settings.json` We will do it at.

/agents

Manage your agents. For details [Creating a Custom Subagent](https://code.claude.com/docs/ja/sub-agents) See.

### Scheduling and Automation

/schedule (/routines)

Manage recurring tasks (routines). For details [https://code.claude.com/docs/ja/routines](https://code.claude.com/docs/ja/routines) See.

/loop \[*interval*\] \[*prompt*\] (/proactive)

Run the prompt repeatedly.`*interval*` In the `5m` (5 minutes),`2h` (2 hours),`1d` (1 day) etc. can be specified.`10s` (10 seconds) can also be specified, but cron accuracy is 1 minute `1m` It will be equivalent to.`*interval*` If you omit it, Claude Code will adjust the interval appropriately.`*prompt*` If we omit `.claude/loop.md` Run. The stop is `CronDelete 5d28fed0` You can stop it by specifying the job ID as in, or you can stop it in natural language as in "Stop looping through ○○". The loop will automatically stop after 7 days. All loops will stop when you end the session. For details [Run prompts according to a schedule](https://code.claude.com/docs/ja/scheduled-tasks) See.

/batch *instruction*

`*instruction*` The large-scale change instructions specified in are executed in parallel by multiple subagents.

### Learning and Support

/init

Based on the current source code `CLAUDE.md` Create and initialize a new one.

/powerup

It's in English, but you can learn the features of Claude Code in interactive lessons.

/release-notes

View Claude Code release notes.

/team-onboarding

Generates an onboarding guide for Markdown formatting that new members of your team should load first, based on their usage history over the past 30 days.

/insights

Analyze past sessions and generate detailed HTML reports, including usage analysis and improvement suggestions.

/doctor

Diagnose installation and configuration status.

/feedback (/bug)

Send Anthropic your feedback on Claude Code.

/stickers

Open the website to order Claude Code stickers.

/claude-api

Help develop Claude API / Anthropic SDK apps.

### External collaboration setup

/install-github-app

Set up the Claude GitHub Actions app.

/install-slack-app

Install the Claude Slack app.

/web-setup

Connect your GitHub account to Claude Code on the web.

/setup-bedrock

Configure Amazon Bedrock.

/setup-vertex

Configure Google Vertex AI.

/mobile (/ios /android)

Mobile app download Show QR code.

### Other

/btw *question*

It stands for by the way. You can ask questions that do not affect the processing during the processing run.

! `<*command*>`

Run shell commands directly to bring the output into the conversation.

## Shortcuts

You can use the shortcuts below while editing the prompt.

```c
?            Shortcut display
!            Shell Mode
/            Command execution
@            File path (filename completion)
&            Background execution
ESC ESC      Input Clear
Shift+Tab    Auto-edit permission mode (toggle)
Ctrl+o       Abbreviated display mode (toggle)
Ctrl+t       Switch tasks (toggle)
Ctrl+Shift+_ Andu
Ctrl+z       Suspend
Ctrl+v       Paste Image
Alt+p        Model Switching
Ctrl+s       Temporarily retreat the prompt and enter a different prompt
Ctrl+g       Prompt $EDITOR Edited with
```

## Config Values

`/config` The following items can be set using the command:

Auto-compact

When the context window is decreasing `/compact` Automatically run to summarize conversation history. Default is true.

Show tips

Specify whether chips should be displayed in rare cases. Default is true.

Reduce motion

Disable UI animations such as spinners and flashes. Default is false.

Thinking mode

Think in a deep thinking mode. Default is true.

Prompt suggestions

Show prompt suggestions in the input box. Default is true.

Session recap

View a summary of the session when you return after being away for a few minutes. Default is true.

Rewind code (checkpoints)

Remember the checkpoints.`/rewind` You can undo the Claude Code fix with the command: Default is true.

Verbose output

It also displays details of tool calls. Default is false.

Terminal progress bar

Display the terminal progress bar in a compatible terminal (ConEmu, Ghostty 1.2.0+, iTerm2 3.6.6+, etc.). Default is true.

Show turn duration

After the response, display a processing time similar to "Cooked for 1m 6s". Default is true.

Default permission mode

Default permission mode default (`Default`), Plan Mode (`Plan Mode`), editing permission (`Accept edits`), no confirmation required (`Don't Ask`). The default is Default.

Respect.gitignore in file picker

`@` When completing filenames with`.gitignore` It does not cover files excluded by. Default is true.

Skip the /copy picker

`/copy` When the command is executed, the UI for selecting a destination is skipped. Default is false.

Auto-update channel

Claude Code auto-updates to the latest version (`latest`), stable version (`stable`). Default is latest.

Theme

Select a color theme. The default is Dark mode.

Local notifications

Notify the terminal. Compatible terminals include iTerm2, Ghostty, and Kitty. The default is Auto.

Push when actions required

Send push notifications when action is needed. Default is false.

Push when Claude decides

A push notification will be sent when Claude Code determines that the process is complete. Default is false.

Output style

Output mode is standard (`default`), descriptive (`Explanatory`), practical training type (`Learning`) Select from. The default is default.

Language

Select your language. To specify Japanese `Japanese` Or specify Japanese. The default is Default (English).

Editor mode

Normal keybindings on prompt input (`normal`), Vim series (`vim`). The default is normal.

Show last response in external editor

`Ctrl+g` Plug the previous response of Claude Code as a comment into the editor that opens with. Default is false.

Show PR status footer

When a pull request is issued, display the PR status badge in the footer. Default is true.

Model

Specify the model to use. The default is Default (recommended).

Auto-connect to IDE (external terminal)

Auto-connect to the IDE and display file change diffs in VSCode etc., such as when starting Claude Code from an external terminal with VSCode open. Default is false.

Claude in Chrome enabled by default

Claude Code auto-connects with Claude in Chrome on startup. You can also use Claude Code to have Claude in Chrome test access from your browser. Default is true.

Enable Remote Control for all sessions

`/remote-control` By default, even if you don't hit the command `claude.ai/code` Make your session operational from the Claude app on your phone. The default is default.

## Command Options

`claude` Describe the main arguments and options of the command. Details of available arguments and options are available [CLI Reference](https://code.claude.com/docs/ja/cli-reference) See.

claude --help (-h)

Displays command help.

claude --version (-v)

Displays version information.

claude " *prompt* "

Specify the first prompt to run `claude` Start.

claude -p " *prompt* " (--print)

Run the prompt, print the execution result to standard output, and exit.

claude -c (--continue)

Starts with the previous session continued.

claude -r \[*session*\] (--resume)

If there are no arguments, a list of past sessions will be displayed and the selected session will continue to be launched.`*session*` If specified, it will start with the specified session continuing.`*session*` Specify the session ID or session name.

claude -y (--yes)

We will proceed with all minor matters as answered Yes. We ask for confirmation regarding any matter that is deemed dangerous.

claude --dangerously-skip-permissions

Starts in a mode where all operations are performed without confirmation. Git operations are also performed automatically. Be careful when using it as it is a dangerous option, such as using it in a container environment where it is safe to break.

claude --verbose

Start in advanced log display mode.

claude --debug

Start in debug information display mode.

## Tips

### Make it seem like you can't be asked to confirm multiple times

When you are asked to confirm multiple times and it is difficult to answer Yes,`Shift+Tab` You can switch between confirmation modes with the key. Toggle the mode that allows editing without confirmation (accept edits), the mode that only allows planning and not file editing (plan mode), and the default mode (default).`/fewer-permission-prompts` Using commands `.claude/settings.json` There is also a way to generate a list of permissions that should be written in.

### We'll pick up where we left off the previous day

Once you log out of Claude Code, it will start with a new session when you resume `claude` を `-c` や `--resume` Launch with options or after launch `/resume` You can resume the previous session by running the command:

### Monitor task completion on your phone

When you request a time-consuming process,`/remote-control` (`/rc`) When you run the command, the browser (`claude.ai/code`) and the Claude app on your phone to monitor the status of your tasks. The top left \[ of the Claude app on your phone `☰`\] Running \[code\] from the icon will display a list of sessions for which remote control is allowed.

### Claude Code on the Web

- Run Claude Code in your web browser.
- From your browser `https://claude.ai/code` Get started by accessing.
- You need to integrate it with GitHub in the \[Customization\]-\[Connector\] on the left menu.
- Deploy and work with GitHub repositories on Anthropic's cloud VM.
- For details [Using Claude Code on the Web](https://code.claude.com/docs/ja/claude-code-on-the-web) See.

---