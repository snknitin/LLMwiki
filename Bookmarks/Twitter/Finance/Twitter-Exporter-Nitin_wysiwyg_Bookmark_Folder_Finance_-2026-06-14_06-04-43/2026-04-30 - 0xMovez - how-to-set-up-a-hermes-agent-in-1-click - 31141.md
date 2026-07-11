---
title: "How to set up a Hermes agent in 1 click"
author: "Movez"
username: "@0xMovez"
date: "2026-04-30"
tweet_url: "https://x.com/0xMovez/status/2049891014249431141"
tweet_type: "original"
likes: 699
retweets: 101
replies: 47
bookmarks: 2233
views: 1335263
has_media: false
extraction_quality: full
article_id: "2048428835230683136"
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# How to set up a Hermes agent in 1 click

> **Source:** [@0xMovez](https://x.com/0xMovez) · 2026-04-30 · 👍 699 · 💬 47 · 🔖 2233 · 👁 1335263

> 🔗 [View tweet on X](https://x.com/0xMovez/status/2049891014249431141)

## Article Content

Trading bots/agents on Polymarket generated over $60M in profit in 2025-2026. 77% of that came from the Crypto UP/DOWN market - driven by persistent inefficiencies in this segment.

The market keeps evolving: to stay profitable, you need to either continuously hunt for new inefficiencies or build self-learning agents that do it automatically.

That's why ****Hermes**** is the ideal foundation for our agent - an open-source, self-learning agent that gained over 100,000 GitHub stars in under 2 months.

Developers are already using it across a wide range of applications, from writing code to building trading algorithms.

By April 27, Hermes Agent GitHub repo surpassed Anthropic's Claude Code in total stars - a clear signal of how useful this framework is for real developers, and exactly why we're choosing it as the foundation for our trading bot.

https://x.com/0xMovez/article/2049891014249431141/media/2049359746470404096

At the same time Polymarket crypto UP/DOWN market has several inefficiencies, which is exactly how trading bots are classified:

- ****Arbitrage (Pair Cost)**** - buys both sides (YES + NO) when their combined price is below $1, locking in a risk-free $0.02–$0.04 profit per pair. Win rate reaches 95–98%
- ****DCA Bot**** - waits for one side to drop below $0.35, then averages down until the combined average cost is under $0.99
- ****Momentum / Latency Bot**** - monitors BTC spot price on Binance/Coinbase and enters Polymarket during the repricing delay
- ****Market Maker**** - places two-sided orders on the 5-minute BTC market, capturing the spread
- ****AI/ML Bot (Synth SDK)**** - uses Bittensor AI to forecast probabilities 20 minutes before market close with an edge of 10%+

****Examples of successful bots:****

• Gabagool22 - legendary arbitrage bot turned $1.2K → $868K on Polymarket
>Profile: [https://polymarket.com/@gabagool22?via=following](https://polymarket.com/@gabagool22?via=following)

https://x.com/0xMovez/article/2049891014249431141/media/2049363119042912256

• Sharky6999 - most consistent bot, made $852K PnL with 95.2% win rate.
> Profile: [https://polymarket.com/@sharky6999?via=following](https://polymarket.com/@sharky6999?via=following)

https://x.com/0xMovez/article/2049891014249431141/media/2049364222459678720

• [@0xe1d6](https://x.com/@0xe1d6)

 - fresh HFT crypto-trading bot which made $728K in a month
> Profile: [@0xe1d6b51521bd4365769199f392f9818661bd907](https://polymarket.com/@0xe1d6b51521bd4365769199f392f9818661bd907?via=following)

https://x.com/0xMovez/article/2049891014249431141/media/2049365045616771072

Today we'll learn how to launch and build the core trading logic for our Hermes Agent on crypto UP/DOWN markets - and then, through live trades and its built-in self-learning capability, let the AI do the heavy lifting for us.

### 

## How to set up a Hermes agent in 1 click

Let's shortly discuss what is Hermes agent and why its so good.

Hermes Agent is open-source autonomous agent by NousResearch (an AI research lab funded by Paradigm with $70M), creators of Nomos & Psyche - released on February 25, 2026, with a built-in self-learning loop that makes it more capable the longer it runs.

As I mentioned earlier, it's the fastest-growing framework due to several factors built into its core logic:

https://x.com/0xMovez/article/2049891014249431141/media/2049370440054013952

- ****Knowledge Layer: ****Built-in memory, session search, LLM-Wiki skill, optional Honcho integration. Agent doesn't just answer -  it accumulates knowledge over time
- ****Execution Layer: ****Multi-agent profiles, child agents, tool system, MCP support, persistent machine access. Agent doesn't just respond - it decomposes tasks, runs them in parallel, and delegates
- ****Output Layer: ****Cron jobs, gateway delivery to Telegram/Slack/Discord, Web UI, file outputResults flow back into your real workflow - not trapped in a chat window.

All these factors together make Hermes the brain (not just the hands) of your trading setup - letting it adapt to market conditions rather than blindly following instructions you set once.

### Setting up Hermes in 1 click with Atomic

In my previous article on the Hermes weather trading bot, many readers ran into issues installing Hermes via CLI - so I found a more convenient framework for managing your agents.

[Atomic Hermes](https://atomicbot.ai/)

 is a native macOS AI assistant - not a browser tab, not a CLI wrapper, not "ChatGPT with buttons". It's an autonomous agent with hands, eyes, memory, and a real workspace.

![](https://pbs.twimg.com/amplify_video_thumb/2049378428986806272/img/rVhUrmvmzY5onR-t.jpg)

withе , you can run your agent locally on Mac or deploy it to the cloud using the built-in service feature - linked to your account via email.

https://x.com/0xMovez/article/2049891014249431141/media/2049383515620552704

[Atomic](https://atomicbot.ai)

 offers 100+ integrations, a large library of pre-installed skills, persistent memory, support for all major AI models (Claude, ChatGPT, Gemini) - and most importantly, one-click setup.

### How to set up Hermes Agent with Atomic:

> ****Step 1 ****- install Atomic app or run in Cloud

Go to [https://atomicbot.ai](https://atomicbot.ai/)

 and choose the agent you want to set up on the Atomic main page. In this guide we will use Hermes agent, so I'm choosing this one.

https://x.com/0xMovez/article/2049891014249431141/media/2049385824953978880

Also, if you ****don't**** want to run it ****locally****, you can ****choose**** "Run in Cloud" in the ****right corner**** of main page → login via Google & get access to same interface.

After app is downloaded, move it into the ****Applications**** folder on your Mac.

> ****Step 2 ****- install agent & connect model API

After we have installed Atomic, we need to plug in a model API for our agent. You can choose to set up free local models (Gemma, Qwen, GLM) or use a paid API from Claude, OpenAI Codex, Google AI, etc.

https://x.com/0xMovez/article/2049891014249431141/media/2049891122667806720

After the latest OpenAI update, I'm ****planning**** to ****choose**** Codex as the ****code**** ****engine**** for my agent logic. All you need to do is ****buy**** ****a**** ChatGPT Plus plan & connect it to Atomic.

https://x.com/0xMovez/article/2049891014249431141/media/2049395714590199808

Here we go - we have entered the Atomic dashboard where we can communicate with our Hermes agent and build an up/down trading setup.

You can talk with your agent using the "Chat" tab on the left panel or the CLI if it's more comfortable for you.

https://x.com/0xMovez/article/2049891014249431141/media/2049398095725903873

> ****Step 3 ****- connect TG bot to your agent

With Atomic, you can connect your Telegram bot to your Hermes agent in ****a few**** clicks.

https://x.com/0xMovez/article/2049891014249431141/media/2049399898684944384

Go to "Skills" tab in lower left corner → choose messenger Telegram → create bot in Telegram using [@BotFather](https://x.com/@BotFather)

 → add bot the API to Atomic

Here we go - a 2-click setup with Atomic and our agent is ready for setting up the trading logic and starting trading on Polymarket.

### Setting up Hermes crypto trading logic

Last and most importantly, we need to set up the trading logic for our self-learning crypto trading agent.

https://x.com/0xMovez/article/2049891014249431141/media/2049450748547665920

Instead of building logic from scratch, I recommend finding GitHub repositories with ready-built logic → feeding this logic to your Hermes agent, and letting it find the most efficient strategy for trading.

****List of popular githubs for Polymarket crypto-trading bots: ****

- [JLowo/gengar_polymarket_bot](https://github.com/JLowo/gengar_polymarket_bot)

 — Quarter-Kelly, Brownian motion probability model, calibrated volatility. Author honest about real-world pitfalls. Circuit breaker, Telegram.
- [joicodev/polymarket-bot](https://github.com/joicodev/polymarket-bot)

 — Node.js. Black-Scholes, EWMA volatility, Platt recalibration, Brier/Log Loss metrics. Cleanest math.
- [aulekator/Polymarket-BTC-15-Minute-Trading-Bot](https://github.com/aulekator/Polymarket-BTC-15-Minute-Trading-Bot)

 — Production-grade, 7-phase architecture. Grafana, Redis, SL/TP.
- [djienne/Polymarket-bot](https://github.com/djienne/Polymarket-bot)

 — Two strategies: "Gabagool" (arb) and "Smart Ape" (momentum). Web dashboard, auto-optimization.
- ****Up/Down arbitrage (no prediction):****
- [Parallax-Trading](https://github.com/Parallax-Trading/polymarket-copy-trading-bot)

 / [Orbital-Alpha](https://github.com/Orbital-Alpha/polymarket-copy-trading-bot)

 — Near-identical Node.js projects. Symmetric ladder, taker arb, on-chain merge to USDC. No Kelly.

With Hermes, I rewrote the logic of those bots so now it uses the latest CLOB2 update by Polymarket, so here is instructions you should send to your Heremes agent:

> ****Step 1: ****give it ****instructions ****to build the logic.

As I said before, I'm using an existing GitHub repo to build the logic. What's important to me is that it uses Quarter-Kelly for sizing, which makes it safer.

```python
Build a Polymarket BTC 5-minute up/down trading agent from this repo:                                                                                                                          https://github.com/JLowo/gengar_polymarket_bot                                                                                                                                                    
                                                                                                                                                                                                     
Update it for Polymarket CLOB v2 and make it ready for safe live trading.                                                                                                                         
                                                                                                                                                                                                     
   Requirements:                                                                                                                                                                                     
   - Keep the existing architecture if possible.                                                                                                                                                     
   - Use Python.                                                                                                                                                                                     
   - Migrate execution to py_clob_client_v2.                                                                                                                                                         
   - Support SAFE_ADDRESS for Polymarket Safe/proxy wallets.                                                                                                                                         
   - Use collateral balance terminology, not legacy USDC-only wording.                                                                                                                               
   - Add fee-aware trade evaluation using CLOB v2 market metadata.                                                                                                                                   
   - Keep DRY_RUN=true by default.                                                                                                                                                                   
   - Add or update tests for the core logic.                                                                                                                                                         
   - Update README.md, SETUP.md, and .env.example.                                                                                                                                                   
   - Verify everything with tests before finishing.                                                                                                                                                  
   - Do not expose private keys in chat or logs.
```

> ****Step 2: ****setting up ****wallet**** for trading

Hermes has built-in safety skills, so after sending the command below, confirm that you understand all the risks and ask him to create wallet he will manage.

```python
сreate a wallet for Polymarket trading and send me the address so I can deposit funds to it
```

> ****Step 3: ********executor ****updates

Run this prompt so the bot can operate using the latest Polymarket CLOB2

```python
- In executor.py, migrate from legacy py_clob_client to py_clob_client_v2.                                                                                                                        
- Initialize ClobClient with:                                                                                                                                                                     - host=https://clob.polymarket.com                                                                                                                                                              
- key from PRIVATE_KEY                                                                                                                                                                          
- chain_id=POLYGON                                                                                                                                                                              
- funder=SAFE_ADDRESS if present                                                                                                                                                                
- signature_type=2 when using Safe, otherwise 0                                                                                                                                                 
- builder_config from env vars                                                                                                                                                                  
- use_server_time=True                                                                                                                                                                          
- retry_on_error=True                                                                                                                                                                           
- Use create_or_derive_api_key() for API creds.                                                                                                                                                   
- Read collateral balance using AssetType.COLLATERAL.                                                                                                                                             
- Add market metadata refresh and fee estimation support.                                                                                                                                         
- Keep buy/sell execution working.
```

> ****Step 4:******** environment/config ****setup

Stores all wallet, risk, and live-trading settings in .env for easy setup.

```python
- Update .env.example with:                                                                                                                                                                       
     - PRIVATE_KEY                                                                                                                                                                                   
     - SAFE_ADDRESS                                                                                                                                                                                  
     - CLOB_HOST=https://clob.polymarket.com                                                                                                                                                         
     - DRY_RUN=true                                                                                                                                                                                  
     - MIN_EDGE                                                                                                                                                                                      
     - MIN_PROB                                                                                                                                                                                      
     - MIN_BET                                                                                                                                                                                       
     - MAX_BET                                                                                                                                                                                       
     - BANKROLL                                                                                                                                                                                      
     - BUILDER_ADDRESS                                                                                                                                                                               
     - BUILDER_CODE                                                                                                                                                                                  
   - Use a small default MIN_BET if needed for testing, but keep live safety in mind.
```

> ****Setp 5:**** ****documentation**** set-up

Explains how to install, configure, and safely run the bot in dry-run or live mode.

```python
- Update README.md and SETUP.md to explain:                                                                                                                                                       
     - CLOB v2                                                                                                                                                                                       
     - collateral balance                                                                                                                                                                            
     - Safe wallet setup                                                                                                                                                                             
     - builder config env vars                                                                                                                                                                       
     - DRY_RUN usage                                                                                                                                                                                 
     - how to switch to live trading safely
```

> ****Step 6: ****set up ****testing**** prompt.

Proves the core math and API integration behave correctly and prevents regressions

```python
Add or update tests for:                                                                                                                                                                          
   - market slug generation                                                                                                                                                                          
   - 5-minute window alignment                                                                                                                                                                       
   - token ID parsing                                                                                                                                                                                
   - probability estimation                                                                                                                                                                          
   - Kelly sizing                                                                                                                                                                                    
   - order sizing                                                                                                                                                                                    
   - fee calculation                                                                                                                                                                                 
   - fee-aware rejection                                                                                                                                                                             
   - executor initialization using the v2 API method
```

> Step 7: ****verification**** prompt

Confirms the code compiles and the test suite passes before the bot is considered ready.

```
Run:                                                                                                                                                                                              
   - python -m pytest -q                                                                                                                                                                             
   - python -m py_compile bot.py strategy.py executor.py market.py price_feed.py tracker.py telegram_notifier.py proxy.py
```

And there it is - your Hermes agent is ready to trade on Polymarket up/down markets, powered by custom trading logic, position sizing with the Kelly Criterion, and a self-learning loop that improves with every trade.

****note:****  i recommend starting with small $1-$2 trades to let your Hermes agent learn, and build its own trading logic based on executed trades. Let the magic of AI build its own strategy.

### Conclusion:

Polymarket trading bots have already taken a large share of the profit pie from manual traders, and this percentage keeps increasing daily. 

Nowadays, with agentic frameworks like Hermes and [@atomicbot_ai](https://x.com/@atomicbot_ai)

, you don’t need to be a senior-level developer to build your own agent.

All you need is a good ML model, right prompts and time for training.

> 📄 Original article URL: https://x.com/i/article/2048428835230683136

---

## Commentary from Other Bookmarks

### @defileo (Defileo🔮) — 2026-04-30

> Cancelled his $20 ChatGPT, his $200 Claude and his $30 Copilot, then built JARVIS on his MacBook that runs offline.
> 
> WiFi off, microphone on, whisper transcribing every word locally, a local LLM responding in real time.
> 
> A voice visualization that looks like Iron Man's actual interface.
> 
> No internet, no API, no "we're experiencing high traffic, please try again"
> 
> The whole thing runs on hardware he already owns, no mac minis jsut his macbook.
> 
> ChatGPT pricing assumes you'll never figure out you can do this yourself. Claude Pro is betting you don't have the patience.
> 
> Copilot is locked behind Windows licenses you didn't ask for, one Python script and a microphone just made all of it optional.
> 
> AI subscriptions used to feel inevitable, now they feel like a tax on people who didn't read the documentation.
> 
> JARVIS doesn't need WiFi anymor, or your wallet.

[→ View quote tweet](https://x.com/defileo/status/2049897707054289202)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

