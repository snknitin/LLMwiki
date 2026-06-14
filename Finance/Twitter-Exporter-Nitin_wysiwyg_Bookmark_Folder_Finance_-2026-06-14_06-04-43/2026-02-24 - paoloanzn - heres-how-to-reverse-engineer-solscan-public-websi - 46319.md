---
title: "here's how to reverse engineer solscan public website to access the private data API they sell for *..."
author: "4nzn"
username: "@paoloanzn"
date: "2026-02-24"
tweet_url: "https://x.com/paoloanzn/status/2026361234032046319"
tweet_type: "original"
likes: 2915
retweets: 198
replies: 99
bookmarks: 7068
views: 1039514
has_media: false
extraction_quality: full
article_id: "2026352911702454272"
tags: ["twitter-bookmark", "agents"]
---

# here's how to reverse engineer solscan public website to access the private data API they sell for *...

> **Source:** [@paoloanzn](https://x.com/paoloanzn) · 2026-02-24 · 👍 2915 · 💬 99 · 🔖 7068 · 👁 1039514

> 🔗 [View tweet on X](https://x.com/paoloanzn/status/2026361234032046319)

## Article Content

here's how to reverse engineer solscan public website to access the private data API they sell for ****$200/mo**** to their users - you'll see how you can build custom scraper that bypass a lot of platform's security measures

****DISCLAIMER: all of the content is meant for educational purpose only. Using their API this way directly violate Solscan TOS.****

For those who don’t know, this is what solscan looks like:

https://x.com/paoloanzn/article/2026361234032046319/media/2026353713426595841

main block explorer for Solana. you can look up any transaction, any account, any token - all on-chain data in one place. super useful if you're building ai trading agents or anything that needs to react to on-chain activity

they make money by selling API access to all this data. cheapest plan starts at $200/mo

https://x.com/paoloanzn/article/2026361234032046319/media/2026354316051636225

i figured there had to be a way to pull data directly from their site. but i also assumed they'd have it locked down tight - if your whole business model is selling data access, you'd protect the pipeline, right?

wrong

### opening dev tools

https://x.com/paoloanzn/article/2026361234032046319/media/2026354754113163264

opened the Network tab while the page loaded. immediately saw a bunch of XMLHttpRequest calls pulling all the transaction data client-side

this was a ****HUGE RED FLAG****. sites that sell data access almost always use server-side rendering so the browser only gets static HTML - no exposed endpoints, no internal API calls to intercept

solscan just... didn't do that. the endpoints loading the data on the website are the same ones in their paid API docs. literally identical

https://x.com/paoloanzn/article/2026361234032046319/media/2026355128131809281

Official API Documentation

### the "authentication"

every request has a header called sol-aut with what looks like a random string. each request uses a different one - reusing a token gets rejected

so i dug into the JS that generates the request. found the file**** _app-0387a288f339cc14.js****, searched for "sol_aut" expecting obfuscated code

NOPE. plaintext. the function is called ****generateRandomString()**** and it does exactly what you'd expect:

https://x.com/paoloanzn/article/2026361234032046319/media/2026355730169675776

it generates a 40-char random string from that character set, then inserts "B9dls0fK" at a random position. that's it. that's the entire auth layer for a $200/mo product

testing it

wrote a quick Python script to replicate the token generation and hit the API:

https://x.com/paoloanzn/article/2026361234032046319/media/2026356248409464832

response comes back clean:

https://x.com/paoloanzn/article/2026361234032046319/media/2026356480849362944

****unlimited access. no API key. $0/mo.****

the actual problem here

this obviously violates their TOS and probably won't last forever. but that's not the point

the point is they're charging $200/mo for something they didn't even bother to protect. no TLS fingerprint rejection. no rate limiting. the auth token is a random string generated client-side with the logic sitting in unobfuscated JS

i genuinely think they should fix this. it's bad practice for a company that built otherwise solid software

### the takeaway

web scraping is 80% reverse engineering. open the network tab, spend time dissecting how the requests actually work, and sometimes you find stuff like this where the entire paid layer is held together by a random string function in plaintext JS

i packaged this into a Python library - you can grab it from the [GitHub repo](https://github.com/paoloanzn/free-solscan-api/tree/main)

 and install it directly

****NOTE:
****I originally wrote this article for my blog back in ****March 2025 - 1 year ago. ****since then they ACTUALLY implemented a little more security measures. they added some Cloudflare protection directly to the API endpoint, but spoiler: i've updated the code to use ****Cloudscraper**** a python library that let you send requests that can 80% the times easily bypass cloudflare protection.

its works. the rate limits might be different tho.

> 📄 Original article URL: https://x.com/i/article/2026352911702454272

---

## Commentary from Other Bookmarks

### @CrypSaf (SafZ) — 2026-02-24

> I saved it already. 
> 
> Please delete it ASAP.
> 
> No need for more people to know.
> 
> Thank you for your service.
> 
> (Guys, check this before it’s gone)

[→ View quote tweet](https://x.com/CrypSaf/status/2026416668398747965)

