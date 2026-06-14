---
title: "The Model Context Protocol (MCP) is not just 'another API lookalike.' If you think, 'Bro, these two..."
author: "Santiago"
username: "@svpino"
date: "2025-03-08"
tweet_url: "https://x.com/svpino/status/1898398856926416977"
tweet_type: "original"
likes: 2708
retweets: 300
replies: 160
bookmarks: 4018
views: 574876
has_media: false
extraction_quality: full
tags: ["twitter-bookmark", "mcp"]
---

# The Model Context Protocol (MCP) is not just "another API lookalike." If you think, "Bro, these two...

> **Source:** [@svpino](https://x.com/svpino) · 2025-03-08 · 👍 2708 · 💬 160 · 🔖 4018 · 👁 574876

> 🔗 [View tweet on X](https://x.com/svpino/status/1898398856926416977)

## Tweet Content

The Model Context Protocol (MCP) is not just "another API lookalike." If you think, "Bro, these two ideas are the same," it means you still don't get it.

Let's start with a traditional API:

An API exposes its functionality using a set of fixed and predefined endpoints. For example, /products, /orders, /invoices.

If you want to add new capabilities to an API, you must create a new endpoint or modify an existing one. Any client that requires this new capability will also need modifications to accommodate the changes.

That issue alone is a colossal nightmare, but there's more.

Let's say you need to change the number of parameters required for one endpoint. You can't make this change without breaking every client that uses your API! This problem brought us "versioning" in APIs, and anyone who's built one knows how painful this is to maintain.

Documentation is another issue. If you are building a client to consume an API, you need to find its documentation, which is separate from the API itself (and sometimes nonexistent.)

MCP works very differently:

First, an MCP server will expose its capabilities as "tools" with semantic descriptions. This is important! Every tool is self-describing and includes information about what the tool does, the meaning of each parameter, expected outputs, and constraints and limitations.

You don't need separate documentation because the interface itself is that documentation!

One of my favorite parts is when you need to make changes:

Let's say you change the number of parameters required by one of the tools in your server. Contrary to the API world, with MCP, you won't break any clients using your server. They will adapt dynamically to the changes!

If you add a new tool, you don't need to modify the clients either. They will discover the tool automatically and start using it when appropriate!

But this is just the beginning of the fun:

You can set your tools so they are available based on context. For example, an MCP server can expose a tool to send messages only to those clients who have logged in first.

There's a ton more, but I don't think I need to keep beating this dead horse.

AI + MCP > AI + API

*micdrop*

