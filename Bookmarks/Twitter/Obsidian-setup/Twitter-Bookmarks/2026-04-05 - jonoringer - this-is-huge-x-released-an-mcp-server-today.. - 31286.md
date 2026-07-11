---
title: "This is huge : @X released an MCP server today.."
author: "Jon Oringer"
username: "@jonoringer"
date: "2026-04-05"
tweet_url: "https://x.com/jonoringer/status/2040937372909531286"
tweet_type: "original"
likes: 2006
retweets: 212
replies_count: 79
bookmarks: 4457
views: 310809
has_media: false
tags: ["twitter-bookmark", "mcp", "ai-tools"]
---

# This is huge : @X released an MCP server today..

> **Source:** [@jonoringer](https://x.com/jonoringer) - 2026-04-05 - Likes: 2006 - Bookmarks: 4457 - Views: 310809

> [View on X](https://x.com/jonoringer/status/2040937372909531286)

## Tweet Content

This is huge : @X released an MCP server today..

How to Connect X to your 🦞 :

**Step 1: Run the XMCP Server**

git clone https://github.com/xdevplatform/xmcp.git  
cd xmcp  
cp env.example .env

Edit the .env file with your X OAuth consumer key and secret. Set the callback URL to http://127.0.0.1:8976/oauth/callback in your X Developer app.

For safety, add an allowlist such as:  
X_API_TOOL_ALLOWLIST=searchPostsRecent,createPosts,getUsersMe,getPostsById,likePost,repostPost

Then run:  
python -m venv .venv && source .venv/bin/activate  
pip install -r requirements.txt  
python http://server.py

The server will be available at http://127.0.0.1:8000/mcp. Complete the OAuth flow on first run and keep this process active.

**Step 2: Add XMCP in @OpenClaw**

Use the following command:

openclaw mcp set x '{  
  "url": "http://127.0.0.1:8000/mcp"  
}'

Verify with:  
openclaw mcp list  
openclaw mcp show x

**Step 3: Test the Integration**

Restart the OpenClaw agent or reload MCP configuration if required.

Test by sending these prompts to OpenClaw in your chat app:  
- Search recent posts about MCP on X and summarize the top trends  
- Draft and post this thread on X  
- Get my X profile information  
- Like the latest post from @xdevplatform

OpenClaw will use the XMCP tools automatically when relevant.

**Key Benefits**

- OpenClaw provides persistent memory and works across multiple messaging platforms.  
- XMCP delivers standardized access to X API functionality.  
- Combined, they enable an agent that can research trends, post content, engage with posts, and report results within your existing chat workflows.

**Safety and Configuration Notes**

Start with a minimal tool allowlist in the XMCP .env file. Expand gradually after testing.  
The allowlist can be updated and requires restarting the XMCP server.  
Monitor logs in both the XMCP server and OpenClaw for troubleshooting.  
X actions performed by the agent are public.

XMCP repository: https://github.com/xdevplatform/xmcp  
OpenClaw MCP documentation: https://docs.openclaw.ai/cli/mcp

