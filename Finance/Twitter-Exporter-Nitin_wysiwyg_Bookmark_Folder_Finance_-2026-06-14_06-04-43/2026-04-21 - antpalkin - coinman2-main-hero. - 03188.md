---
title: "Coinman2 - main hero."
author: "cvxv666"
username: "@antpalkin"
date: "2026-04-21"
tweet_url: "https://x.com/antpalkin/status/2046654122892403188"
tweet_type: "original"
likes: 1481
retweets: 154
replies: 62
bookmarks: 6025
views: 4335982
has_media: false
extraction_quality: full
article_id: "2046611667685924864"
tags: ["twitter-bookmark", "claude", "mcp", "llm", "agents"]
---

# Coinman2 - main hero.

> **Source:** [@antpalkin](https://x.com/antpalkin) · 2026-04-21 · 👍 1481 · 💬 62 · 🔖 6025 · 👁 4335982

> 🔗 [View tweet on X](https://x.com/antpalkin/status/2046654122892403188)

## Article Content

28 repositories. Six layers. ****One stack. No gaps. 

****How it works, why it works, and how to make your first ****$1,000**** on Polymarket with same algo - it’s all in here.

Everything you need to build a profitable trading bot on Polymarket - from the brain to the backtest to the production execution layer.

****Our patient:****

https://x.com/antpalkin/article/2046654122892403188/media/2046631901650141184

Wallet link: [polymarket.com/@coinman2?r=antopotoshka#RLOep5t](https://x.com//polymarket.com/@coinman2?r=antopotoshka#RLOep5t)

This article is not the story of one wallet. It is a map of the stack. Each tool below closes a specific failure mode that bleeds capital from most prediction-market operators: missing data, missing validation, missing discipline, missing speed.

### Before you read:

****→ Bookmark this. You'll need it when you actually start building.****

****→ If you want these exact strategies working for you tonight just copy coinman2 trades with this TG bot: ****[kreo.app/@cvxv666](https://x.com//kreo.app/@cvxv666)

****→ follow me for more alpha ****[@antpalkin](https://x.com/@antpalkin)

 

****→ You'll definitely need a Polymarket account:**** [polymarket.com](https://polymarket.com/?r=antopotoshka)

## Coinman2 - main hero.

****$1,003,450 PnL. 3,062 predictions. One wallet.****

The wallet is ["0x55be7aa03ecfbe37aa5460db791205f7ac9ddca3"](https://polymarket.com/@coinman2?r=antopotoshka#RLOep5t)

 public handle [@coinman2](https://polymarket.com/@coinman2?r=antopotoshka#RLOep5t)

 on Polymarket. Joined November 2024. Biggest single win on record: .

When traders first saw the growth trajectory on-chain, the initial reaction from crypto Twitter was simple: fake. A seven-figure cumulative PnL from a retail-profile wallet belongs in a Telegram scam group, not in a verifiable on-chain dashboard.

But the blockchain doesn't lie. Every trade is public. Every settlement is verifiable.

Developers reverse-engineered the approach within weeks. Then they asked Claude to rebuild it from scratch.

This piece is about the full tool stack that makes this possible - and what each layer actually does.

## What Polymarket is and where the edge lives.

Polymarket is a prediction market. Users trade on outcomes: will Bitcoin be higher in 15 minutes? Will the Fed raise rates? Each contract resolves at $1.00 (correct) or $0.00 (wrong). A contract priced at $0.73 means the market believes there's a 73% chance the "Yes" outcome happens.

The platform's weekly volume exceeded**** $2 billion**** in early 2026.

The key category for automated trading is short-duration crypto contracts - 5-minute and 15-minute BTC and ETH up/down questions. They resolve fast, provide immediate feedback, and have a structural vulnerability.

Polymarket updates its prices ****slower**** than the underlying asset moves on Binance. In 2024, that lag averaged ****12 seconds****. By Q1 2026, competition had compressed it to ****2.7 seconds****.

****2.7 seconds is an eternity for a machine.****

That gap - between what Binance knows and what Polymarket still shows  is where every strategy in this article lives.

## The mechanism, step by step.

A 15-minute BTC contract opens at 50/50. Ten minutes in, Bitcoin drops 0.6% on Binance in 30 seconds. The "real" probability that BTC will be lower at expiry just shifted to roughly 78%. Polymarket still shows 54/46.

****That's a 24-point edge on a binary contract.**** It's not a prediction. The outcome, in a probabilistic sense, has already happened.

A bot monitoring Binance's WebSocket feed with under 50ms latency sees this immediately. It calculates the discrepancy, sizes a position using ****Kelly Criterion****, and executes via ****Polymarket's CLOB API****. Two seconds later, the market corrects. The position closes profitable.

****Repeat 200–500 times per day.****

That's the coinman2 result. Not magic. Industrial-scale exploitation of a gap that still exists today.

## Why the gap exists at all.

Polymarket is a decentralized prediction market. Prices only update when traders actively post orders - there's no dedicated market-making desk refreshing quotes in real time. In the seconds after a Binance move, the "smart" side of the contract has few sellers willing to trade at stale odds.

The gap has narrowed from 12 seconds to 2.7 seconds as more bots entered. It will continue to narrow. But it hasn't closed. And closing it entirely would require the kind of real-time automated market makers that are, themselves, already the arbitrage bots.

****It's an arms race with no obvious end state.****

## Polymarket API infrastructure.

Before any AI, you need the raw infrastructure. Polymarket exposes four surfaces:

https://x.com/antpalkin/article/2046654122892403188/media/2046639571287367682

The official Python client, "py-clob-client" (pip install py-clob-client), wraps all of this. Three lines to fetch an order book. Five to place a signed limit order on Polygon (chain ID 137, USDC settlement).

****Key repos to start with:****

- ****Polymarket/agents (****[https://github.com/Polymarket/agents](https://github.com/Polymarket/agents)

) - Official AI agent framework. Gamma API, CLOB API, and LangChain already wired together. Built-in Chroma vector database for ingesting news sources.

- ****polyterm**** ([github.com/NYTEMODEONLY/polyterm](https://x.com//github.com/NYTEMODEONLY/polyterm)

) - Terminal dashboard: whale tracker, arbitrage scanner, insider detection, cross-platform comparison vs Kalshi, market risk grading A–F.

## The stack - layer by layer.

### LAYER 1 - BRAIN

****AI reasoning.**** The coinman2 bot ran on Anthropic's Claude. In March 2026, a controlled experiment ran Claude against the OpenClaw framework - same starting capital ($1,000), same market conditions, 48 hours.

****Claude: +1,322% return. OpenClaw: fully liquidated.****

https://x.com/antpalkin/article/2046654122892403188/media/2046648618984071168

Claude reasoning trace - from market context to Kelly-sized order, every decision auditable after the fact.

Researchers traced the gap to one thing: risk management quality. Claude's generated code included more conservative default parameters, more defensive edge cases, and cleaner error handling. OpenClaw overlevered into a losing sequence and couldn't stop.

****Claude**** (Anthropic) - Primary strategist. Reasons about market questions, estimates probability vs current price, identifies edge size.

****Qwen3-Coder ****([github.com/QwenLM/Qwen3-Coder](https://x.com//github.com/QwenLM/Qwen3-Coder)

) - Open source coding LLM. Watches live performance, detects crowded strategies, rewrites modules autonomously.

****G0DM0D3 ****([github.com/elder-plinius/G0DM0D3](https://x.com//github.com/elder-plinius/G0DM0D3)

) - Uncensored AI interface. Engages with uncomfortable market theses without refusals.

****Claude Squad ****([github.com/smtg-ai/claude-squad](https://x.com//github.com/smtg-ai/claude-squad)

) - Runs multiple Claude instances in parallel. One watches politics, one crypto, one sports - all feeding the same engine.

### LAYER 2 - ORCHESTRATION

****Making agents do things.**** A reasoning engine with no execution layer is just an opinion generator.

https://x.com/antpalkin/article/2046654122892403188/media/2046648911704518656

Bull vs Bear debate resolved by Risk Manager veto - the framework that keeps confident-but-wrong from becoming confident-and-bankrupt.

****Agency Agents ****([github.com/msitarzewski/agency-agents](https://x.com//github.com/msitarzewski/agency-agents)

) - Role-based debate: Bull Agent vs Bear Agent vs Risk Manager veto. Consensus determines trade and size.

****ClaudeAgent OneClick ****([github.com/cvxv666/ClaudeAgentOneClick](https://x.com//github.com/cvxv666/ClaudeAgentOneClick)

) - One click Claude agent deploy. Persistent 24/7 market watcher in minutes.

****MiroThinker ****([github.com/MiroMindAI/MiroThinker](https://x.com//github.com/MiroMindAI/MiroThinker)

) - Mandatory chain-of-thought layer. Bot must justify every position before entry.

****Superpowers ****([github.com/obra/superpowers](https://x.com//github.com/obra/superpowers)

) - Extends agents with web access, file ops, arbitrary API calls. Fresh data every decision cycle.

****TradingAgents ****([github.com/TauricResearch/TradingAgents](https://x.com//github.com/TauricResearch/TradingAgents)

) - Multi-agent framework: fundamental analyst + technical analyst + sentiment analyst → aggregated signal.

### LAYER 3 - DATA & MARKET SIGNALS

****The eyes.**** The bot is only as good as what it can see. This layer used to be four tools. Adding macro data, indicator math, and a real-time charting engine brings it closer to a Bloomberg terminal than a script.

https://x.com/antpalkin/article/2046654122892403188/media/2046649120056553472

The edge visualized: Binance-implied probability (blue) vs Polymarket shown (red). The gap between lines is the entire business.

****OpenBB ****([github.com/OpenBB-finance/OpenBB](https://x.com//github.com/OpenBB-finance/OpenBB)

) - Open source Bloomberg. 100+ data sources unified: stocks, macro, crypto, options flow, news. The backbone.

****Dexter ****([github.com/virattt/dexter](https://x.com//github.com/virattt/dexter)

) - Autonomous deep research. SEC filings, earnings transcripts, analyst reports - two hours of analyst work in seconds.

****MCP Server ****([github.com/financial-datasets/mcp-server](https://x.com//github.com/financial-datasets/mcp-server)

) - Financial datasets via MCP protocol. Typed, validated data straight into Claude's context window.

****Crucix ****([github.com/calesthio/Crucix](https://x.com//github.com/calesthio/Crucix)

) - On-chain aggregator. Whale wallet movements on Polygon can front-run the visible order book by minutes.

****fredapi ****([github.com/mortada/fredapi](https://x.com//github.com/mortada/fredapi)

) - Every macroeconomic dataset the Federal Reserve publishes, free, behind one Python wrapper. CPI, unemployment, yield curves - pipe directly into Claude's context to anchor any macro-related market.

****Binance Collector ****([github.com/txbabaxyz/mlmodelpoly](https://x.com//github.com/txbabaxyz/mlmodelpoly)

) - Predicts market direction and computes fair value for short-duration BTC/ETH contracts. The price-discovery half of every latency-arbitrage trade.

****Polymarket Assistant Tool ****([github.com/FiatFiorino/polymarket-assistant-tool](https://x.com//github.com/FiatFiorino/polymarket-assistant-tool)

) - Indicator engine that surfaces directional bias on live markets. Translates raw orderbook + price action into a usable signal.

****lightweight-charts ****([github.com/tradingview/lightweight-charts](https://x.com//github.com/tradingview/lightweight-charts)

) - TradingView's own charting library. 14k stars, 45KB, free. The fastest path to a production-grade dashboard for monitoring positions and signals in real time.

### LAYER 4 - MARKET INTELLIGENCE

****What others have already built.**** You don't have to build everything from scratch. An entire ecosystem of Polymarket-specific intelligence and pre-built bots already exists.

https://x.com/antpalkin/article/2046654122892403188/media/2046649304937324545

Whale alerts, leaderboards, signal confluence - the institutional-grade view retail never used to have.

****Polyscope ****([thepolyscope.com](https://x.com//thepolyscope.com)

) - Scans 2,000+ markets. Whale alerts ($5k/$10k/$20k), probability shifts, volume spikes - all to Telegram in real time.

****Polywhaler ****([polywhaler.com](https://x.com//polywhaler.com)

) - [$10k+](https://x.com/search?q=%2410k%2B&src=cashtag_click)

 whale trade tracker. Real-time alerts, insider detection, AI-generated signals.

****WHALES tracker ****(Apify) - Cross-references Gamma + Data + CLOB. Outputs Smart Money Consensus, Health Score, Conviction Score as structured JSON.

****HyperBuildX bot ****([github.com/HyperBuildX/Polymarket-Trading-Bot](https://x.com//github.com/HyperBuildX/Polymarket-Trading-Bot)

) - Rust-based, sub-100ms latency. AI ranks copy-trade signals when multiple whales pile into the same market.

[polymarketanalytics.com](https://x.com//polymarketanalytics.com)

**** -**** Open trader analytics. Top wallet P&L, biggest wins, Kalshi cross-comparison.

****polyrec ****([github.com/txbabaxyz/polyrec](https://x.com//github.com/txbabaxyz/polyrec)

) - Real-time terminal dashboard combining Chainlink oracle, Binance feed, and full orderbook depth. 70+ indicators, automatic CSV logging, built-in strategy backtester. The closest thing to an institutional cockpit you can get free.

****Polymarket-Trading-Bot ****([github.com/dylanpersonguy/Polymarket-Trading-Bot](https://x.com//github.com/dylanpersonguy/Polymarket-Trading-Bot)

) | 53k lines of TypeScript. Seven prebuilt strategies: arbitrage, momentum, market making, AI forecast, whale copy-trade, convergence, and more. A complete framework - pick a strategy, plug in keys, run. |

### LAYER 5 - BACKTEST & SIMULATION

****Prove it before you run it.**** This is the layer most retail bots skip - and the reason most retail bots blow up.

Reasoning models can sound convincing about strategies that have never made money. Whales can be followed into trades that already moved. A signal that worked last month may have been arbitraged out by yesterday. The only defense is running every idea against historical data and simulated execution before a single dollar of real capital touches the CLOB.

https://x.com/antpalkin/article/2046654122892403188/media/2046649510307254272

Every strategy earns its way to production by surviving this report first: 17 months of live record, fees and slippage included, drawdowns visible.

****prediction-market-backtesting ****([github.com/evan-kolberg/prediction-market-backtesting](https://x.com//github.com/evan-kolberg/prediction-market-backtesting)

) - Backtests trading strategies against real historical Polymarket and Kalshi data. The first sanity check on any new idea before it sees production.

****polybot ****([github.com/ent0n29/polybot](https://x.com//github.com/ent0n29/polybot)

) - Full execution and market-data infrastructure with paper trading. Kafka, ClickHouse, Grafana - the analytics pipeline an institutional desk would build. Reverse-engineered from production strategies.

### The complete signal flow.

https://x.com/antpalkin/article/2046654122892403188/media/2046644423094616064

World event to execution: under 10 seconds in the ideal world.

## Human traders vs bots - the data.

The performance gap between human traders and automated bots using comparable latency arbitrage approaches is documented. Bots generated approximately $206,000 during a tracked period. Humans using the same logic generated roughly $100,000.

****2× gap. Same market. Same strategy. Same time window.****

The gap isn't better forecasting. It's execution. Humans make four systematic errors that bots don't:

- ****Late entries.**** By the time a human identifies the Polymarket lag, confirms the Binance move, and places the order manually, the window has often already closed.

- ****Inconsistent sizing.**** Humans oversize when confident, undersize when uncertain — exactly the inverse of Kelly math. Emotional sizing destroys expected value across thousands of trades.

- ****Fatigue.**** A human monitoring 15-minute BTC contracts through an 8-hour session degrades. A bot running for 72 hours makes the same decision at hour 72 that it made at hour 1.

- ****Drawdown psychology.**** After a losing sequence, humans either abandon a working strategy or double down. Both destroy capital. A bot with a hard kill switch does neither.

## Why now.

The bots already running have a compounding advantage. The edge exists today. The window is narrowing. The best time to understand this stack was six months ago.

****The second best time is right now.****

****If you read this far:****

-> ****SAVE THIS POST**** or you’ll lose every important link.

-> ****coinman2 bot profile on Polymarket****: [wallet link](https://polymarket.com/@coinman2?r=antopotoshka#RLOep5t)

-> If it seems too complicated, ****copying the trades of similar bots is also a profitable strategy****. That’s exactly what I do through a TG bot: [kreo.app/@cvxv666](https://x.com//kreo.app/@cvxv666)

-> ****remember:**** competition is way weaker than it looks. ****99.9%**** of people will scream**** "too hard"**** and call it cap. Only the**** 0.01%**** actually try…**** and eat.****

> 📄 Original article URL: https://x.com/i/article/2046611667685924864

---

## Commentary from Other Bookmarks

### @antpalkin (cvxv666) — 2026-06-01

> A 31-year-old blitz chess master who never cracked the top 100 just turned $500 into $153,279 - with Claude and simulation engine.
> 
> Twenty years reading a board faster than the other guy, for prize pools that barely covered the flights. 
> 
> Then he pointed that speed at Polymarket.
> 
> His wallet: http://polymarket.com/@xuanxuan008?via=cvxv666
> 
> No tournament ever paid him like a Claude agent running 24/7.
> 
> Everyone trades Bitcoin like it mean-reverts on the 5-minute. It doesn't. That gap is the whole edge.
> 
> Here's the stack.
> 
> Every five minutes a BTC candle closes. A Claude agent reads it into a pattern net - price, momentum, volume in; BOS, order block, FVG out.
> 
> A neuron fires. It doesn't trade yet.
> 
> It hands off to MiroFish - a relationship-graph sim that threads a median path through three live clusters: bear, neutral prime, catalyst. That path is where BTC actually lands.
> 
> Fair value drifts 15¢ off the order book? That's the edge. Size by Kelly. Pull the trigger.
> 
> Read the candle. Fire the net. Run the graph. No thesis. No conviction.
> 
> It never stops sharpening, re-running the graph every few seconds, rewriting its own threshold nightly.
> 
> 92% of Polymarket traders lose. The winners are bots. This one just reads two endpoints and presses one button. 13,290 times.
> 
> The edge is on-chain. Read it with this bot before it gets crowded: http://kreo.app/@cvxv666

[→ View quote tweet](https://x.com/antpalkin/status/2061531380220387491)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

