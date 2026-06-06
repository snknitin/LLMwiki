---
title: "How to Figure Out What to Use Hermes Agent For"
author: "vmiss"
username: "@vmiss33"
date: "2026-05-03"
tweet_url: "https://x.com/vmiss33/status/2050984556790939731"
tweet_type: "original"
likes: 1912
retweets: 167
replies: 81
bookmarks: 5304
views: 547139
has_media: false
article_id: "2050983909576294400"
tags: ["twitter-bookmark", "agents"]
---

# How to Figure Out What to Use Hermes Agent For

> **Source:** [@vmiss33](https://x.com/vmiss33) · 2026-05-03 · 👍 1912 · 💬 81 · 🔖 5304 · 👁 547139

> 🔗 [View tweet on X](https://x.com/vmiss33/status/2050984556790939731)

## Article Content

I have been running a multi agent setup for Hermes agent for the last several weeks.  Honestly?  It took me a while to get here.  I installed OpenClaw in the midst of the hype, stared at it for an hour, and never went back to it.  Why?  I didn’t know what to use it for.  I watched the timeline on X about all these things going on and the Mac Mini crazy and sat there scratching my head, but I really wanted to get in on it.

When you ask “What do you use your AI agent for?”, many people out there will give answers like “anything” or “everything” or “coding”, and I have been known to give those answers too.  Today, I want to walk through some ideas for how you get started with what to use Hermes Agent for, so you can make the most of it.  I’ll give you some examples on how you can start using it for yourself, going into some of my weird use cases as examples.

## How to Figure Out What to Use Hermes Agent For

My personal philosophy when it comes to AI is I treat AI as my assistant.  I don’t use it to replace my thinking, I use it to point me in the right direction.  I make it do grunt work, then I verify and proceed.  For automated tasks, I only have AI automate and execute things I already understand how to do.  This is my personal philosophy and your milage may vary based on the way you do things.

So what things do you use a personal AI agent for?  That’s the question we all ask.

What I have found to be extremely helpful was writing down things I did for a day, then taking a good look at that list.  After, I went further and added and expanded to the list over the course of a week or so.

I asked myself things like “What are the things that took a lot of time?” and “What are things that  I have to do, but didn’t provide a lot of value to my workflow?”.

Make that list, and start playing with Hermes.

### The Softer Stuff

Here’s another thing to ask yourself, “What are some issues in your life day to day?”.  I don’t mean figuring out which model to run on your local hardware, I mean the softer stuff, the stuff that impacts your life as a human being.  Are there things you forget to do?  Are there things that you have to deal with that just make your life harder to deal with?

I ended up coming up with a couple of more really helpful ideas when I asked this question.

After some brainstorming, I got to work.

## The Agent Crew

Of course, I didn’t just start with one agent, I started with a bunch.  One great thing about Hermes is that you can configure different profiles, each using a different provider/model, and change that model easily from the TUI at any time.  I like to tinker so this was a huge plus for me, to compare how models responded side by side.

Here is a break down of my current agent crew, and what provider/model they use currently.  I access them using the Hermes TUI and over Telegram.

### Tech Research Agent

Generally I use this agent a topic and ask for a research brief, along with citations.  For me, citations are key, because I want to go read the academic papers / source material.  For example, I used this agent to help me learn how to do model quantizations, I didn’t have to agent do it for me, but I had it teach me how to do it myself.

This agent uses on the Nous portal currently, with MiniMax M2.7, but I’ve had it use other models/providers in the past such as models off of NVIDIA NIM.

### Tech Task Master Agent

I use this agent for building skills for Hermes, and I also had it do all my TUI customizations for all of my agents yesterday.  This is really the anything agent.

This agent currently uses GPT 5.5 via my ChatGPT Plus Codex SUBSCRIPTION, not the API.  I will most likely keep using GPT 5.5 for this agent, and come up with a backup for if/when I run out of quota.

A note on Tech Agents: I was using them interchangeably at one point for lots of model/provider testing, but I think I’ll be continuing to use them this way going forward, one as the researcher, and one as the executor so to speak.

### Lifestyle Agent

At the risk of being roasted, I have an agent that’s job is to remind me to drink water at certain points throughout the day.  Ridiculous?  Yes.  Game changing?  Absolutely.  As I’m writing this I think I’m going to have it also prompt me to check my posture (I’ve spent the last six months trying to fix what I’ve wrecked spending years hunched over a computer) and take movement breaks.  It sends me messages on Telegram to remind me.

This agent runs off of OpenRouter using a free model – NVIDIA Nemotron 3 Super.

### Lifestyle / Research Agent

I’m stuck with a chronic health condition, a variation of MCAS / severe food allergies.  I use this agent to scour the internet for studies and news related to this, as well as for simple stuff like ugh what should I make for dinner tonight since I cook every meal I eat myself.  Something simple like giving it a list of recipes, and having it respond with one, or giving it a list of things I want to cook with and having it give me ideas on what to do with it, because some days I’m just like oh no not again I have to make dinner.

This agent runs off of a local model believe it or not, on my 8GB RTX 4070 card, hosted in a random gaming laptop.  Hermes agent gets to it over the wireless network.  I would say I’ve been the most “impressed” with this agent since I’m running it on a small local model.  I’m using a Qwen 3.5 9B quant with 64k context.

### The Providers / Models

I am on a personal mission to do this as cheap as possible, to the point where I may be shooting myself in the foot.  I’ve seen too many what I call horror stories of people just connecting to the Anthropic API and spending hundreds of dollars a day.  No thank you.

Here are some of the models and providers I currently use.

### A Note On Providers/Models/Cost

A lot of personal agents AI is knowing what model will do what you need it too, and that is somewhat personal and subjective, some trial and error is often required.  Many providers are subsidizing costs, or providing models for free upon release.  Many of the free models do have a bit of a trade off such as speed, but hey, the price is right.

I have also built skills and simply ask my agents to show me current pricing on Nous Portal / OpenRouter if I want to play around more with what is cheap or free currently.

****Open Router - Free Models****

I added 10 dollars in credits that I don’t actually use to get 1,000 requests per day and 20 requests per minute on free models, the totally free account gets you 50 requests per day which goes very very fast.  My free model of choice here is currently nvidia/nemotron-3-super-120b-a12b:free

****Nous Portal - 10 Dollar a Month Sub****

I got the 10 dollar a month Nous Portal subscription to experiment with, and it has been working well.  Since it is an API based subscription I use it pretty sparingly, but it does also include tool calling.  Right now I’m using MiniMax M2.7.

****Local Models****

My local equipment is meh, but it works surprisingly well.  I use a laptop with a NVIDIA RTX 4070 that has 8GB of VRAM, and llama.cpp to serve with 64k context.  Right now my favorite small model is a Qwen 3.5 9B quant, but I like to experiment with other random distilled and abliterated models too.

Honestly, this setup works very well, I have also run this same model on my M1 MacBook with 16GB of RAM.  You would be surprised at what you can run locally with what you already have.  Everyone should try it.  LMStudio is the easiest way to get started, and guess what, you can connect to it easily from Hermes now.

****ChatGPT Plus subscription - 20 a month****

Connecting via my subscription and using gpt5.5 is working very well, and I have not run into any quota issues.  I only did this a day or two ago, and I’m wondering why I waited this long.  This is almost flawless.

****NVIDIA NIM – Free Models****

If you head over to [https://build.nvidia.com/models](https://build.nvidia.com/models)

, you will see that quite a number of models are free.  Sign up for an account and you can get an API key.  This is a great way to get exposure to a bunch of modes and see what they “feel” like.

****DeepSeek v4 via DeepSeek API****

I haven’t tried this yet, but numerous people on twitter have told me to try the DeepSeek v4 API, the pricing is incredible right now at a 75% discount through the end of May (remember I mentioned subsidies?)

### Getting Started With Hermes Agent

If you are stating and wondering what to do with an AI agent, I hope this article gave you some brain storming ideas, and showed you that you can get started pretty quickly and easily without breaking the bank.

The biggest mistake I see people make with agents is starting with the tech instead of the problem.  You don’t need to get a stack of 3090s to get started (but hey if you can grab some go for it).

Just start doing.

Start with your life. Your workflow. Your friction points. Then build agents around that.

That’s where this actually becomes useful.

> 📄 Original article URL: https://x.com/i/article/2050983909576294400

---

## Commentary from Other Bookmarks

### @vmiss33 (vmiss) — 2026-05-03

> 100% human generated.  Includes what I use Hermes agent for (since I've seen a lot of people wondering what to do with this thing), and what models/providers I use to keep things cheap. @NousResearch

[→ View quote tweet](https://x.com/vmiss33/status/2050984822168830302)

