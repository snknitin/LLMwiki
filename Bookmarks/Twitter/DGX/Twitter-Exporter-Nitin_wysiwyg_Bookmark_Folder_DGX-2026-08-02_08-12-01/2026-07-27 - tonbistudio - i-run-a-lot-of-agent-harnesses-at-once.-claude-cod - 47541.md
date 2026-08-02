---
title: "I run a lot of agent harnesses at once. Claude Code, Hermes Agent, Codex, Grok Build, all of them. A..."
author: "tonbi"
username: "@tonbistudio"
date: "2026-07-27"
tweet_url: "https://x.com/tonbistudio/status/2081616282131247541"
tweet_type: "original"
likes: 339
retweets: 27
replies: 24
bookmarks: 696
views: 25234
has_media: false
extraction_quality: full
article_id: "2081601574628151296"
tags: ["twitter-bookmark", "claude", "agents"]
---

# I run a lot of agent harnesses at once. Claude Code, Hermes Agent, Codex, Grok Build, all of them. A...

> **Source:** [@tonbistudio](https://x.com/tonbistudio) · 2026-07-27 · 👍 339 · 💬 24 · 🔖 696 · 👁 25234

> 🔗 [View tweet on X](https://x.com/tonbistudio/status/2081616282131247541)

## Article Content

I run a lot of agent harnesses at once. Claude Code, Hermes Agent, Codex, Grok Build, all of them. And for the longest time my "multi-agent setup" was really just a pile of terminal windows I kept alt-tabbing through, trying to remember which one was stuck waiting on me to answer some question (that it could probably answer itself) and which one had quietly finished twenty minutes ago with a block of text telling me what it did (or most likely, what it didn't do).

Two tools fixed that for me, and they turn out to be a perfect pair. Herdr gives me one place to see every agent at a glance. Hermes Agent gives me one agent that can actually drive all the others. Put them together and you get something genuinely close to a control room for a whole fleet of agents.

Now there are lots of ways to pull off multi-agent setups and I'm not saying you have to do it this way or you're ngmi, but here's the thing: I'm lazy and this is easy and works. And that's all you need sometimes!

### Why Herdr?

Herdr ([@herdrdev](https://x.com/@herdrdev)

) is an agent multiplexer by [@lumendriada](https://x.com/@lumendriada)

 that lives in your terminal. The easiest way to describe it: it's tmux, but for AI coding agents instead of shells. One Rust binary, no Electron, runs inside whatever terminal you already use.

The reason it matters for a multi-agent setup is three things.

First, it orchestrates across agents and across harnesses. You can have Claude Code, Codex, Grok Build, Hermes and more all running in their own panes in one window, and Herdr detects each one and rolls its state up into a sidebar. Every agent shows as working, blocked, done, or idle. So instead of hunting through windows, you glance once and know exactly who needs you.

Second, it has real tmux-style persistence. Herdr runs your agents in a background server, and the terminal you look at is just a client attached to it. Close the terminal, close the laptop, drop your SSH connection, and the agents keep running. Then reattach later from any terminal, or over SSH from your phone, and everything is right where you left it. That server/client split is the whole reason nothing dies when you walk away.

Third, it's just easy. It's mouse-first, so you click panes to focus them and drag borders to resize, no shortcut memorization required to get going. Install is one line and then you just run `herdr`.

### Why Hermes Agent?

Hermes makes this whole setup work, and unlike a lot of the other agent harnesses, I'm in control.

Hermes Agent is an open-source agent harness by [@nousresearch](https://x.com/@nousresearch)

, and that open part is the whole point for me. I can write my own skills, plug in my own models and provider stack, and script it however I want. It's not a black box I'm renting (and perhaps sending data to), it's a harness I actually own and can bend to whatever I'm building.

That's what makes it the ideal HQ agent in this setup. It can hold my orchestration logic as reusable skills, run on a schedule with cron, and talk to the other agents through Herdr. It's also a first-class Herdr integration, so it reports its own state cleanly rather than getting guessed at. One agent I fully control, sitting at the center, running the show.

### Why all Those Agents to Begin With?

I like Hermes Agent because it's an open source harness, I own it, I develop it and make it fit my workflows, and I can use whatever model I want.

I like ClaudeCode because Fable is still the king in terms of raw intelligence, plus I like claude design as well.

I like Codex because I get the bigger context window for long-coding tasks, and Sol is a really great model that just gets to work and won't quit until the job is done.

I like Grok Build because Grok 4.5 in genuinely good (especially at visual design and game dev), I can generate images and videos, and their team is actively making it better all the time.

### Trick 1: Basic orchestration

This is the one I demo in the video I put out on Friday, and it really impressed me (if you couldn't tell from my voice).

Herdr isn't just something you drive. Agents can drive Herdr too, through a socket API. It's newline-delimited JSON over a local socket, the CLI wraps it, and there's an official agent skill so your agent can herd the other agents. That means my Hermes HQ, sitting in its own pane, can spin up sibling panes, read what the other agents are doing, and send them instructions.

https://x.com/tonbistudio/article/2081616282131247541/media/2081607231892865024

So Hermes can start an agent, hand it a task, wait until it either finishes or gets blocked, then read its output back and decide what to do next. One agent viewing and instructing another, instead of me tabbing through a sea of windows that I forgot the status of (and I'm not going to read 10 paragraphs of your life history, Codex).

### Trick 2: Skill creation

Here's where owning your HQ pays off.

Because Hermes is skill-based and open source, any orchestration you pull off once can be captured as a reusable skill. Anywhere. You don't re-explain the workflow every time. You do it, you like how it went, and you turn it into a one-command skill you can fire whenever.

https://x.com/tonbistudio/article/2081616282131247541/media/2081606638591770624

The part I find genuinely cool is that Hermes can learn from the other harnesses. Say Codex works through a tricky migration in its pane. Hermes can read that pane, see how it actually got solved, and I can distill that into a Hermes skill with /learn (or just ask it to make the skill). So the HQ gets smarter over time by watching the agents it manages.

Now I don't need to flip through endless claude or codex sessions in a billion workspaces trying to remember that one workflow I did that worked so well (when was it? weeks ago? was it in this directory? or maybe it was in grok build?). I can just create the skills myself, or even have Hermes review the panes for any workflows that would make good skills (like it already does with it's self-evolving feature).

### Trick 3: A status-check skill that reports back

This is my favorite, because like I said earlier, I am lazy, and have no desire to read some of these novels these models write for me after doing a simple task.

I built a Hermes skill whose only job is to walk every agent in the setup and send me one clean message. It checks each agent's state, reads their recent output, and reports back: who's actively working, who's blocked, what progress they've made on the current project, whether any of them have a question for me, and whether anything needs my approval. All of it in a single concise summary.

https://x.com/tonbistudio/article/2081616282131247541/media/2081606912865689600

It leans on the exact same pieces from Trick 1. Herdr already knows each agent's lifecycle state, and `herdr agent read` pulls their recent output, so Hermes just gathers all of that and writes the summary.

Now you can trigger this manually, or set up a cron to report in at regular intervals.

That flips the whole dynamic. I'm not babysitting a wall of terminals anymore. The agents run, the HQ watches them, and I only step in when the digest says something actually needs me.

I've open sourced this skill here: [https://github.com/tonbistudio/flock-check](https://github.com/tonbistudio/flock-check)

### Putting it together

That's the setup. Herdr sees every agent, Hermes drives them, skills make your workflows repeatable, and flock-check reports in.

None of the three tricks are complicated on their own. Stacked together they turn a chaotic pile of terminal windows into an actual system, one where you're managing the manager instead of chasing individual agents around.

Herdr is at [herdr.dev](https://x.com//herdr.dev)

 (built by ogulcancelik), and Hermes Agent is the harness I cover in depth on my channel. If you want to see the orchestration running live, my full Herdr walkthrough is up [on YouTube channel, Tonbi's AI Garage.](https://youtu.be/Oa2BXTerhtY)

> 📄 Original article URL: https://x.com/i/article/2081601574628151296

