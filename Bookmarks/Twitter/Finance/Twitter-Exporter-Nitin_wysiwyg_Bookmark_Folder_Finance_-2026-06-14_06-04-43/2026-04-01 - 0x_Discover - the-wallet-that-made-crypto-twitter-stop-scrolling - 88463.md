---
title: "The wallet that made crypto Twitter stop scrolling"
author: "Discover"
username: "@0x_Discover"
date: "2026-04-01"
tweet_url: "https://x.com/0x_Discover/status/2039266206377488463"
tweet_type: "original"
likes: 737
retweets: 100
replies: 34
bookmarks: 2643
views: 5707208
has_media: false
extraction_quality: full
article_id: "2039265226336452608"
tags: ["twitter-bookmark", "claude"]
---

# The wallet that made crypto Twitter stop scrolling

> **Source:** [@0x_Discover](https://x.com/0x_Discover) · 2026-04-01 · 👍 737 · 💬 34 · 🔖 2643 · 👁 5707208

> 🔗 [View tweet on X](https://x.com/0x_Discover/status/2039266206377488463)

## Article Content

A complete guide to the arbitrage bot that made crypto history. How it works, why it wins 98% of trades, what the strategy actually is, and how you can build your own with a single Claude prompt.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265302740140032

Total PnL: ****$2 382 780,80****

Predictions: ****33,950+****

Win rate: ****100.0%****

## The wallet that made crypto Twitter stop scrolling

In December 2025, a wallet appeared on Polymarket the world's largest prediction market  with a balance of $313. Nobody noticed. There was nothing unusual about a small account entering the platform. Thousands do it every week. But over the next four months, something remarkable happened: that wallet made 26,738 individual trades, maintained a 98% win rate across all of them, and turned $313 into $2,382,780.80. Every single transaction is verifiable on-chain. There's no sleight of hand here. The number is real.

The wallet's address, ****0x8dxd****, was running an automated trading bot powered by Anthropic's Claude AI. When Finbold first reported the story in early January 2026 with on-chain data to back it up the crypto world had one of its periodic collective moments of disbelief. The post went viral. Threads dissecting the strategy flooded X. Within weeks, developers had reverse-engineered the approach and asked Claude to rebuild it.

This is the story of how that happened, why it works, and what you'd need to do to build something similar. It covers the full mechanism  from the underlying market inefficiency that makes the strategy possible, to the code that exploits it, to the risk management that keeps it alive long enough to compound. Nothing is omitted. If you read this in full, you'll understand the arbitrage bot space better than most people currently trading on Polymarket.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265540422979584

The growth curve is almost impossible to look at without some degree of skepticism. That's natural. A 7,942× return in four months is the kind of number that usually appears in scam advertisements. But the difference here is the blockchain. Every trade, every position, every settlement all of it is public and immutable. The Dune Analytics dashboards that tracked this wallet showed consistent, high-frequency activity across BTC and ETH short-term price contracts. There was no single lucky bet. There were 26,738 of them.

## What Polymarket actually is and where the money comes from

To understand why this strategy works, you first need to understand Polymarket's mechanics. It's a prediction market: a platform where users trade on the outcome of real-world events. The structure is simple. For any given event  will Bitcoin be higher or lower in 15 minutes? will the Fed raise rates this month? will candidate X win the election?  users can buy "Yes" shares or "No" shares.

Each share trades between $0 and $1. The price reflects the collective market estimate of the probability. A contract trading at $0.73 implies the market believes there's a 73% chance the outcome resolves as "Yes." If you're right, your share settles at $1.00. If you're wrong, it settles at $0.00. The mechanism is elegant, the math is straightforward, and the markets are liquid Polymarket's weekly trading volume exceeded $2 billion in early 2026.

The platform's key category for automated trading is its short-duration crypto contracts: 5-minute and 15-minute up/down questions on Bitcoin and Ethereum. Every few minutes, a new contract opens asking whether BTC will be higher or lower at expiry. These contracts resolve quickly, provide immediate feedback, and critically  they have a structural vulnerability that bots can exploit.

****Polymarket updates its contract prices slower than the underlying asset moves on centralized exchanges.****There is always a lag between when a price shift happens on Binance or Coinbase and when that shift is reflected in Polymarket's contract odds. In 2024, that lag averaged around 12 seconds. By Q1 2026, competition had compressed it to approximately 2.7 seconds. But even 2.7 seconds is an eternity for a machine. And in those 2.7 seconds, the outcome of a 15-minute BTC contract is effectively already known.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265607485644801

## The mechanism  how the arbitrage actually works

Let's walk through a single trade, step by step, at the level of milliseconds. Understanding this sequence is the foundation of everything else.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265661847773184

A new 15-minute Bitcoin up/down contract opens on Polymarket. The current market odds are roughly 50/50  neither side has a clear edge based on available information at contract open. At that moment, the contract is fairly priced.

Ten minutes into the contract's life, Bitcoin moves sharply on Binance. Let's say it drops 0.6% in 30 seconds  a clear, momentum-driven move. Based on what we know about BTC price persistence over 5-minute windows, this move now implies a substantially higher probability that BTC will be lower at contract expiry than Polymarket's current odds suggest. The "real" probability of the downside outcome might now be 78%, but Polymarket still shows 54/46.

The bot  which has been monitoring Binance's WebSocket feed continuously, receiving price updates with latency under 50ms  immediately calculates the discrepancy. The edge is roughly 24 percentage points. That's enormous. On a binary contract, that's effectively a free bet. The bot sizes a position using the Kelly Criterion, executes the trade via Polymarket's CLOB API, and waits.

Within 2–3 seconds, other market participants and bots begin updating Polymarket's odds to reflect the Binance move. The odds shift from 54/46 toward the "true" 78/22. The bot can exit at this point for an immediate profit from the repricing, or hold to contract resolution. Either way, the position was entered with near-certainty of a positive outcome.

Repeat this 200 to 500 times per day, with disciplined position sizing and a hard kill switch at −40% drawdown, and you get the 0x8dxd result. Not magic. Not prediction. Industrial-scale exploitation of a market inefficiency that still exists today, just with a shorter window than it had two years ago.

## Why does Polymarket lag at all?

It's a reasonable question. If the inefficiency is this obvious, why hasn't Polymarket fixed it? The answer is structural. Polymarket is a decentralized prediction market  it uses a CLOB (Central Limit Order Book) model where prices update when orders are placed and matched. Unlike a centralized exchange with a dedicated market-making desk, Polymarket's prices only update when traders actively post orders.

In practice, this means that in the seconds after a significant move on Binance, the "smart" side of the Polymarket contract the side that will benefit from the move  has few sellers willing to trade at the stale odds. The market is temporarily one-sided. Bots that recognize this imbalance and fill it by buying the "obvious" side are providing liquidity at the cost of taking the other side. They're rewarded for being fast and for being right about the direction of the lag.

Polymarket has taken steps to accelerate pricing. The lag has dropped from 12+ seconds in 2024 to around 2.7 seconds in early 2026. But closing the gap entirely would require real-time automated market makers that are themselves highly capitalized and algorithmically driven  which is essentially what the arbitrage bots already are. It's an arms race with no obvious end state.

### The 4 strategies  not all Claude bots do the same thing

The 0x8dxd wallet ran pure latency arbitrage. But the broader ecosystem of Claude-powered Polymarket bots uses four distinct strategies, each with different win rate profiles, risk characteristics, and capital requirements. Understanding the full landscape matters if you're thinking about building your own system because the right strategy depends entirely on your edge, your infrastructure, and your risk tolerance.

### • Latency ArbitrageWin rate 85–98%

The strategy 0x8dxd used. Monitor real-time price feeds from Binance and Coinbase via WebSocket. When Polymarket's contract odds diverge from what the CEX data implies by more than your threshold (typically 3–5%), buy the correct side before the market corrects. The edge is pure speed — there is no forecasting, no model, no sentiment analysis. The bot simply reacts to confirmed price information faster than the average market participant. Win rates of 85–98% are achievable because you're not guessing — you're reading an outcome that has, in a probabilistic sense, already happened. The main risk is that the window continues to compress as more bots enter, eventually making the strategy uneconomical for smaller operators.

### • Oracle ArbitrageWin rate 78–85%

A more robust but less frequent opportunity. Chainlink and other decentralized oracle networks publish on-chain price feeds that Polymarket uses for contract settlement. These oracles update on their own schedule, and their published prices occasionally diverge from Polymarket's implied contract prices by an exploitable margin. When the Chainlink BTC/USD feed shows $67,240 but a Polymarket settlement contract implies $66,900, the direction of settlement is known with near-certainty. Oracle arbitrage requires monitoring multiple data sources simultaneously and acting within the window before the discrepancy is noticed. Fewer opportunities than latency arb, but higher certainty when they appear.

### • News-Driven TradingWin rate 60–75%

This is where Claude's reasoning capability becomes most directly relevant. The bot ingests real-time news streams breaking developments, government filings, central bank statements, on-chain data releases  and assesses their probability impact on open Polymarket contracts. If a contract asks "will the Fed raise rates this meeting?" and a statement from a Fed governor is released suggesting a hold, the bot can update the implied probability before retail traders have time to read the headline and place orders manually. Win rates are lower than pure arbitrage because the interpretation layer introduces uncertainty Claude can misread a headline, or the market can react differently than the model expects. But the ceiling is higher, because the strategy works on any market category, not just crypto price contracts.

### • Market MakingReturn 2–5%/month

The most consistent strategy, and the hardest to blow up. The bot places simultaneous buy and sell orders on both sides of a market, capturing the bid-ask spread without taking a directional view. No prediction is required  the bot simply provides liquidity and earns the spread on every matched trade. The risk is inventory: if the market moves sharply in one direction, you can end up holding losing contracts before you can unwind. Market making is best run on high-liquidity markets where the spread is wide enough to justify the risk, and with strict inventory limits to prevent any single directional exposure from accumulating. Monthly returns of 2–5% on deployed capital are realistic, which compounds aggressively over time.

## The timeline  from $313 to $2.38M

The story of 0x8dxd didn't happen in isolation. It emerged in the middle of a broader wave of Claude-powered trading that transformed Polymarket's dynamics in Q1 2026. Here is the full timeline, documented from public sources.

December 2025

### Bot launches. Nobody notices.

$313

Wallet 0x8dxd appears on Polymarket. First trades on BTC 15-minute up/down contracts. The early phase involves small positions while the risk parameters calibrate. Win rate already in the mid-90s. The compounding begins quietly.

January 6, 2026

### Finbold reports. Crypto Twitter erupts.

~$438,000

In approximately 30 days, the wallet has grown 140× from its starting balance. 6,615 predictions. 98% win rate. Finbold publishes on-chain verification. The post spreads rapidly. Most responses are some variation of "this can't be real" — until people check Dune Analytics themselves.

March 10, 2026

### Claude vs OpenClaw  the public experiment.

$1,000 → $14,216 in 48 hours

A controlled comparison: Claude-powered bot vs OpenClaw framework, each starting with $1,000, running for 48 hours under identical conditions. Claude: +1,322% return. OpenClaw: fully liquidated. The post reaches 1.2 million views. Researchers trace the gap to risk management quality — Claude's generated code included more robust position sizing and drawdown protection. The OpenClaw setup overlevered into a sequence of losses it couldn't recover from.

March 16, 2026

### A swarm model trained on NBA data hits Polymarket.

+$1.49M

posts: "SOMEONE TRAINED A SWARM MODEL ON 3 YEARS OF NBA DATA. The results trading on Polymarket: +$1.49M." The strategy was different not latency arbitrage but genuine probability modelling  but the outcome confirmed that well-constructed AI systems could generate substantial returns across multiple market categories, not just crypto price contracts.[@RoundtableSpace](https://x.com/@RoundtableSpace)

April 2026

### Final verified balance for 0x8dxd.

$2,382,780.80

26,738 trades. 4 months. One of the most thoroughly documented automated trading results in the history of prediction markets. The bot is still running at time of publication.

## How to build your own  from A to Z

Everything that follows is a complete operational guide. If you follow each step in sequence and don't skip the risk management setup, you'll have a running bot by the end of the day. If you skip steps  especially step 4 and step 5  you will lose money. That's not a hedge. It's just what happens.

### • Set up a Polymarket wallet

and connect MetaMask or Coinbase Wallet. Fund it with USDC via the Polygon network  not Ethereum mainnet, not any other chain. Polygon is the network Polymarket runs on, and using the wrong network means your funds sit inaccessible. For testing purposes, $100–300 is sufficient. For real trading with meaningful compounding, start with $500–1,000. ****Important: Polymarket is not available to US residents.**** If you're in the US, you cannot legally access the platform. Check the legal status in your specific country before depositing anything.Go to[https://polymarket.com/?r=0x8dx](https://polymarket.com/?r=0x8dx)

### • Generate your API credentials

, navigate to the API section, and generate a CLOB API key by signing a message with your wallet. This proves ownership without requiring a password. You'll also need your wallet's private key to sign individual trade transactions. Store this private key in a local environment variable  ****never hardcode it into your bot script, never commit it to GitHub, never share it with anyone.**** A leaked private key means a drained wallet. This is the one step where operational security genuinely matters.Go to[docs.polymarket.com](https://docs.polymarket.com/)

### • Prompt Claude to build the bot

works too  you'll just need to install dependencies and run the code yourself.Open[Claude.ai](https://claude.ai/)

or Claude Code. The prompt below has consistently produced working, well-structured Python bots with proper error handling, rate limiting, and paper mode built in. Claude Code is preferred because it can read your filesystem, execute the code, and iterate on errors autonomously without you needing to copy-paste between windows. But[Claude.ai](https://claude.ai/)

https://x.com/0x_Discover/article/2039266206377488463/media/2039265754407976960

### • Run paper mode for at least one week

This step is not optional, and one week is a minimum  not a target. Paper trading simulates real trades without using actual capital. It lets you verify that the bot's edge calculation is correct, that the Binance WebSocket connection is stable, that the Polymarket API calls are working, and that the position sizing logic behaves as expected under various market conditions. You want to see at least 200 completed trades in paper mode with a win rate above 70% before you consider going live. If your paper win rate is consistently below 60%, something in the edge detection or timing logic needs adjustment. Bring the error logs back to Claude and iterate.

### • Configure risk management before touching live funds

The difference between the Claude bot (+1,322%) and the OpenClaw bot (liquidated) in the March 2026 experiment came down almost entirely to risk management quality. The OpenClaw setup overlevered into a losing sequence. Claude's generated code sized positions conservatively using Kelly fractions and stopped trading when drawdown thresholds were breached. Set these parameters explicitly: maximum single position size of 8% of total portfolio; daily loss limit of −20% with automatic halt; total drawdown kill switch at −40%; Telegram notification on every alert threshold. None of these should be negotiable. The kill switch especially: if your bot is running while you sleep and something breaks, you want it to stop, not to keep trading.

### • Go live  small, then scale only on evidence

Start with $1–5 USDC per trade. This is not about the dollar amount  it's about establishing a baseline. Watch every single trade for the first week. Compare live results to your paper mode results. If they're meaningfully different, investigate why before adding capital. If live and paper results converge, you have evidence that the system works as designed. Then you can scale gradually  doubling position sizes every week or two, up to whatever Kelly math suggests is appropriate for your full account size. Only trade markets with more than $50,000 in liquidity. Smaller markets can't absorb clean exits, and the bid-ask spread will eat your profit.

### Human traders vs Claude bots  the data

The performance gap between human traders and automated bots running the same strategy on Polymarket is documented and significant. Data comparing humans and bots using comparable latency arbitrage approaches showed a consistent pattern: bots generated approximately $206,000 using the strategy while humans using the same logic generated roughly $100,000. A 2× gap, same market, same strategy, same time period.

The gap doesn't come from better forecasting. It comes from execution. Humans make four systematic errors that bots don't:

****Late entries:**** By the time a human identifies the Polymarket lag, verifies their reasoning, and places the trade manually, the window has often closed or narrowed significantly. A bot executing in under 100ms catches opportunities that humans simply cannot.

****Inconsistent sizing:**** Humans tend to oversize positions when they feel "confident" and undersize when uncertain  exactly the opposite of Kelly math, which sizes larger when the edge is larger. Emotional sizing destroys expected value systematically over thousands of trades.

****Fatigue:**** A human monitoring 15-minute BTC contracts through an 8-hour session makes progressively worse decisions. A bot running for 72 hours straight makes the same decision at hour 72 that it made at hour 1.

****Drawdown psychology:**** After a losing sequence, humans often either abandon a winning strategy (panic) or double down trying to recover (tilt). Both responses destroy capital. A bot with a hard kill switch does neither.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265819545182208

https://x.com/0x_Discover/article/2039266206377488463/media/2039265848850874368

### What can go wrong  an honest assessment

This section is the most important one in this article. The 0x8dxd result is extraordinary and it is real. But it is also exceptional. Most people who build a Polymarket arbitrage bot will not 7,942× their money. Some will lose their initial capital entirely. Before running anything with real funds, you need a clear-eyed view of what the actual risks are and how each one manifests in practice.

Edge compression is the existential risk

The arbitrage window that made 0x8dxd possible was 12+ seconds in 2024. By Q1 2026 it had dropped to 2.7 seconds. The direction of that trend is clear and it doesn't reverse. As more bots enter the space and competition intensifies, the window will continue to shrink. At some point  perhaps 0.5 seconds, perhaps sooner  the window will be smaller than the round-trip API latency required to execute a trade, at which point the strategy stops working entirely for retail operators without co-located infrastructure.

This isn't a reason not to start. The window exists now and the returns while it exists are substantial. But you should treat any latency arbitrage operation as a time-limited business, not a permanent passive income stream. Extract value while the edge is there and be prepared to pivot to a different strategy as it narrows.

Rule changes can invalidate your model overnight

Polymarket can change contract mechanics, settlement rules, or API terms at any time. A change to how short-duration contracts are priced, or an update to the oracle data sources used for settlement, could make a strategy that worked perfectly yesterday produce consistent losses tomorrow. Monitoring Polymarket's changelog and community channels for announced changes is an operational requirement, not optional.

A bug in your risk management is more dangerous than a losing strategy

A strategy with a 55% win rate but proper Kelly sizing will slowly grow capital. A strategy with a 98% win rate but a bug in the position size calculation  one that allows a single position to represent 80% of the portfolio  will blow up the account on the inevitable losing trade. The most dangerous failure mode isn't a bad strategy. It's a strategy that works in paper mode but has an edge case in live trading that the paper simulation didn't surface. This is why the step from paper trading to live trading should be gradual and monitored closely.

### What can go wrong  an honest assessment

This section is the most important one in this article. The 0x8dxd result is extraordinary and it is real. But it is also exceptional. Most people who build a Polymarket arbitrage bot will not 7,942× their money. Some will lose their initial capital entirely. Before running anything with real funds, you need a clear-eyed view of what the actual risks are and how each one manifests in practice.

Edge compression is the existential risk

The arbitrage window that made 0x8dxd possible was 12+ seconds in 2024. By Q1 2026 it had dropped to 2.7 seconds. The direction of that trend is clear and it doesn't reverse. As more bots enter the space and competition intensifies, the window will continue to shrink. At some point  perhaps 0.5 seconds, perhaps sooner  the window will be smaller than the round-trip API latency required to execute a trade, at which point the strategy stops working entirely for retail operators without co-located infrastructure.

This isn't a reason not to start. The window exists now and the returns while it exists are substantial. But you should treat any latency arbitrage operation as a time-limited business, not a permanent passive income stream. Extract value while the edge is there and be prepared to pivot to a different strategy as it narrows.

Rule changes can invalidate your model overnight

Polymarket can change contract mechanics, settlement rules, or API terms at any time. A change to how short-duration contracts are priced, or an update to the oracle data sources used for settlement, could make a strategy that worked perfectly yesterday produce consistent losses tomorrow. Monitoring Polymarket's changelog and community channels for announced changes is an operational requirement, not optional.

A bug in your risk management is more dangerous than a losing strategy

A strategy with a 55% win rate but proper Kelly sizing will slowly grow capital. A strategy with a 98% win rate but a bug in the position size calculation  one that allows a single position to represent 80% of the portfolio  will blow up the account on the inevitable losing trade. The most dangerous failure mode isn't a bad strategy. It's a strategy that works in paper mode but has an edge case in live trading that the paper simulation didn't surface. This is why the step from paper trading to live trading should be gradual and monitored closely.

https://x.com/0x_Discover/article/2039266206377488463/media/2039265971656105984

****Why Claude specifically, and not GPT-4 or Gemini?**** The March 2026 head-to-head experiment gave a partial answer Claude's generated code produced better risk management outcomes under identical prompting. Researchers who analyzed the two systems found that Claude's output included more defensive edge cases, more conservative default parameters, and more legible error handling that made debugging easier. It also generates complete, functional codebases faster from a single prompt than most alternatives.

### Your complete starting checklist

Every item below should be checked before your first live trade. The order matters. Don't skip to item 8 before items 1–7 are done.

https://x.com/0x_Discover/article/2039266206377488463/media/2039266030082797568

The right mindset going in

The 0x8dxd result demonstrates what is possible at the upper end of this strategy. It required the right market conditions (high volatility in BTC during the period), the right position sizing, uninterrupted runtime, and no meaningful technical failures over four months. That combination of factors won't replicate exactly for anyone else.

What will replicate  for a well-built bot running on a solid infrastructure with proper risk management — is consistent positive expected value from the latency arbitrage edge that still exists in Polymarket's short-duration crypto contracts. Whether that produces 7,942× returns or a more modest 3–5× over a similar period depends on factors that vary between operators: the quality of the Binance WebSocket connection, the latency of the Polygon RPC endpoint, the accuracy of the edge threshold calibration, and how long the arbitrage window remains economically viable before the bot needs to adapt.

The bots that are already running have a compounding advantage. The edge exists now. The window is narrowing. The best time to understand this strategy was six months ago. The second best time is right now.

## If you made it this far thank you.

This took time to put together, and I hope it gave you something real: not just inspiration, but an actual path from zero to a running system.

The 0x8dxd result is extraordinary. Your results will be your own. But the mechanism is documented, the prompt is in your hands, and the edge still exists today.

If this was useful to you  I'd genuinely appreciate a repost. Not for vanity metrics. Because the more people who understand how these tools work, the harder it becomes for the information to stay locked inside small circles of developers who'd rather keep it to themselves.

This is the first in a series. I'm planning to cover every major income stream that can be automated with Claude prediction markets are just the beginning. Trading strategies, content pipelines, arbitrage across different platforms, automated research tools. All of it broken down the same way: mechanism first, then the exact prompt, then the risk.

Follow if you want to see the rest.

And if you build something with this  I'd actually love to hear how it goes.

> 📄 Original article URL: https://x.com/i/article/2039265226336452608

---

## Commentary from Other Bookmarks

### @0x_Discover (Discover) — 2026-04-05

> A Chinese engineering student set up a “weather station” in his dorm. 
> 
> Three Mac Minis. 
> 
> Two monitors. 
> 
> Satellite maps everywhere. Labels on each box: UI/UX. DEV. ADMIN. 
> 
> Total cost: under $2,000.
> 
> His roommate thought it was climate research. Professors assumed it was a thesis prototype. He didn’t correct anyone.
> 
> Then someone noticed what it was actually connected to:
> 
> A wallet. Sitting at $101K. Built on temperature bets.
> 
> Wallet:https://polymarket.com/@ColdMath
> 
> I’m using this:https://t.me/KreoPolyBot?start=ref-discov
> 
> ColdMath — $101,042 profit. 5,252 predictions. Joined November 2025. Bio: Edge compounds.
> 
> The setup had one job. 
> 
> Claude pulled real-time aviation weather data — precise sensor readings updated every 1–3 hours from stations worldwide. 
> 
> The system compared that data to prediction market prices. When something didn’t line up, the DEV box flagged it.
> 
> Mismatch found → trade placed → profit.
> 
> $25 on Tokyo hitting 16°C → $12,452 payout.
> $24 on Chicago reaching 54°F → $12,398 payout.
> $13 on Lucknow hitting 39°C → $6,850 payout.
> 
> Small bets. Massive returns. Just on weather.
> 
> A pilot friend mentioned that aviation data often updates hours before public forecasts — down to tenths of a degree. It’s free, required for safety… and mostly ignored outside aviation.
> 
> He didn’t ignore it. He fed it into Claude and said: find every mismatch.
> 
> It found dozens. Every day.
> 
> One morning his roommate finally asked what the system actually does. The student showed him the balance. No reaction — just one question:
> 
> “Can we add another monitor?”
> 
> Now 34K people are watching. $96K still active in positions.
> Three Mac Minis. Two screens. One quiet student who realized:
> 
> The most predictable edge is often hidden in plain sight.
> 
> The weather.

[→ View quote tweet](https://x.com/0x_Discover/status/2040724120472596617)

⚠️ Quote tweet has **video** — see [[MEDIA-REVIEW]] for link.

