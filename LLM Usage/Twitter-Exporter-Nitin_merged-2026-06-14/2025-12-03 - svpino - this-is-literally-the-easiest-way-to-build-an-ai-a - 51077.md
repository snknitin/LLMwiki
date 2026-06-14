---
title: "This is literally the easiest way to build an AI agent."
author: "Santiago"
username: "@svpino"
date: "2025-12-03"
tweet_url: "https://x.com/svpino/status/1996209124573651077"
tweet_type: "original"
likes: 920
retweets: 107
replies: 34
bookmarks: 1621
views: 140733
has_media: true
extraction_quality: full
tags: ["twitter-bookmark", "agents"]
---

# This is literally the easiest way to build an AI agent.

> **Source:** [@svpino](https://x.com/svpino) · 2025-12-03 · 👍 920 · 💬 34 · 🔖 1621 · 👁 140733

> 🔗 [View tweet on X](https://x.com/svpino/status/1996209124573651077)

## Tweet Content

This is literally the easiest way to build an AI agent.

Zero code. You only need to run a couple of commands.

(I've said this before, but Google ADK is my favorite way to build code-first agents.)

Here is what you need to do:

1. Open your terminal and create an empty folder

2. Run `uv init` inside the folder (if you don't have uv installed, you are really missing out!)

3. Install the google-adk library using the following command: `uv add google-adk`.

4. At this point, you can use the ask to create your agent with a single command: `uv run adk create --type=config my_agent`. This will ask you a couple of questions, including your GEMINI_API_KEY (you can create one online).

5. The command above will create a my_agent/root_agent.yaml file. Open it and add the following two lines at the end of the file so your agent can use Google to search for stuff:

tools:
  - name: google_search

6. You have everything you need now. Run the adk web interface and start playing with your agent: `uv run adk web`

That's it!

Literally zero code. The agent works off the YAML configuration file.

Very easy. I do it all the time. 

Personally, I'm always using LiteLLM for that, but you don't have to.

This is an AI-generated reply.

## Media

![Video thumbnail](https://pbs.twimg.com/amplify_video_thumb/1996209065643606016/img/XY8QB8WOrrUfUtOk.jpg)

**Video:** [▶ Watch](https://video.twimg.com/amplify_video/1996209065643606016/vid/avc1/1002x720/zZUWdX0jQ15_nMtg.mp4?tag=14) (duration: 93s)

⚠️ Video content — see [[MEDIA-REVIEW]] for full list.

## Reply Thread Summary

*Top replies and discussion captured from the tweet thread.*

### @david_nix (David Nix)

> How easy is it to use non-Gemini models with ADK?

### @Nate1601 (Nate Nguyen)

> Zero code AI? Sounds like magic!  If I mess this up, can I blame you?

### @AIxBlock (AIxBlock)

> Crazy how fast agent-building is becoming a config problem instead of a coding problem.

