---
title: "Right now, it's too easy to let AI write the code while you skip the learning. The bug gets fixed bu..."
author: "Addy Osmani"
username: "@addyosmani"
date: "2026-05-17"
tweet_url: "https://x.com/addyosmani/status/2056078124346228860"
tweet_type: "original"
likes: 3601
retweets: 609
replies: 109
bookmarks: 4856
views: 625167
has_media: false
extraction_quality: full
article_id: "2055936913211899904"
tags: ["twitter-bookmark", "claude", "llm", "agents"]
---

# Right now, it's too easy to let AI write the code while you skip the learning. The bug gets fixed bu...

> **Source:** [@addyosmani](https://x.com/addyosmani) · 2026-05-17 · 👍 3601 · 💬 109 · 🔖 4856 · 👁 625167

> 🔗 [View tweet on X](https://x.com/addyosmani/status/2056078124346228860)

## Article Content

Right now, it's too easy to let AI write the code while you skip the learning. The bug gets fixed but your mental model doesn't move. It might get worse over time. We are silently trading future capability for present-day speed, and the tools won't force us to do otherwise. That part has to come from you.

There's a default loop most of us have settled into. You paste in a spec or error message. The model hands you a fix and the symptom vanishes. You ship. Somewhere in that loop, the messy struggle between problem and solution stops happening at all.

I've written before about [cognitive surrender](https://addyosmani.com/blog/cognitive-surrender/)

, the moment an AI reviewer's verdict quietly replaces your own. This is the solo version of that same loop. It's just you and the model. The model is faster, so you stop trying to compete on comprehension. Across thousands of these small interactions, what you can actually build without an AI looking over your shoulder gets a little weaker every week. None of these moments feel like a problem on the day they happen.

I'm not anti-AI. I use these tools daily and have shipped more with them in the last year than in the years before it. But the default way we use them is optimized for one thing: closing tasks.

That is a completely different goal from staying sharp enough to steer them over a career that spans a long time.

### The studies are converging on the same point

Several pieces of research over the last year have landed in roughly the same place.

Anthropic ran a [randomized trial in early 2026](https://www.anthropic.com/research/AI-assistance-coding-skills)

 where engineers learned a new Python library, half with AI assistance and half without. Both groups finished the tasks at the same speed. But the AI group bombed the follow-up comprehension quiz: 50% versus 67% for the manual group, with the gap widening on debugging. The interesting cut was inside the AI group itself. Engineers who used AI to ask conceptual questions scored above 65%. Engineers who copy-pasted the generated code scored under 40%. ****The tool didn't determine the outcome. The posture did.****

MIT's [Your Brain on ChatGPT](https://www.media.mit.edu/publications/your-brain-on-chatgpt/)

 study compared essay writing across LLM, search-engine, and brain-only groups. EEG measurements showed brain connectivity scaling down with every layer of external support. The LLM group showed the weakest coupling. After writing the essay, 83% of LLM users couldn't quote a single line of what they had just produced. The researchers called this cognitive debt: saving mental effort today, paying for it in critical thinking tomorrow.

A [CHI 2026 study](https://arxiv.org/html/2603.08849v1)

 added a related finding. When people had LLM access at the start of a task, the LLM framed the entire problem. Even when the human did the rest of the work themselves, that initial anchoring produced measurably worse decisions. The order of operations mattered more than the total amount of AI used.

Different methodologies reaching the same conclusion. ****Using AI without an active intent to learn quietly degrades the skill you're being paid for.****

### The tools default to shipping, not teaching

****If you fire up a coding agent and stick to the defaults, everything is tuned for one metric: getting the task done. ****

The model writes the code. You accept it. The loop repeats. At no point does the tool pause and ask "what do you think the problem is?" or "try writing the first five lines yourself."

That's where UX gravity is right now. Product teams get rewarded for merged changes and shorter cycle times, not for making you a sharper engineer. We all want fewer keystrokes, so the tools have sanded the friction away. The trouble is that friction was where the learning lived.

A few companies have tried pushing back on these loops not encouraging us to really learn.

Anthropic shipped [Learning Mode](https://www.engadget.com/ai/anthropic-brings-claudes-learning-mode-to-regular-users-and-devs-170018471/)

 for Claude, which uses Socratic questioning and stops to ask you to write code before continuing. OpenAI and Google have shipped similar features. Almost nobody uses them for real production work though if we're being real. We've quietly filed them under "for students" and that's a mistake. The same feature that helps a sophomore learn React works for a senior engineer learning Rust. You just have to be willing to feel like a beginner again.

### "If the AI can do it, why do I need to understand it?"

A fair question. For some work, the answer is: maybe...you don't? If it's boilerplate, glue code, or a throwaway CI script you'll never look at again, delegate it. The opportunity cost of memorizing some syntax is too high.

For real software, pure delegation breaks down in a few specific places.

****When something breaks.**** AI-generated code crashes the same way human code does. "The agent wrote it" doesn't help you debug problems. Somebody on the team has to understand the architecture.

****When it's confidently wrong.**** LLMs can still hallucinate. The only defense against a plausible-looking incorrect answer is enough expertise to spot it. Bandaids like skills, CLIs etc only get you so far.

****When the foundation changes.**** Code is temporary; systems are permanent. When frameworks update or a security review flags a structural issue, you can't re-prompt your way out. You need engineers who understand the system well enough to migrate it.

****When you leave the median.**** AI is brilliant at problems that have been solved a million times on GitHub. The further you stray from the median, the worse it gets. The hard, undocumented problems, the ones that justify a senior engineer's salary, still require deep understanding.

****When the market adjusts.**** Engineers who can only ship with AI, and not without it, are entering a labor pool that is already re-pricing what expertise is worth. If you use AI to skip learning, you're trading future relevance for a slightly easier Tuesday.

### The fix is in how you prompt

The good news is that the same tools that produce cognitive debt can produce sharper engineers. The difference is in what you ask of them.

Form a hypothesis before you ask. Before requesting a fix, write down two or three sentences on what you think the problem is. Use the model's answer to test your theory, not to replace it.

Ask for the explanation before the code. In unfamiliar territory, your first prompt should be something like "explain how this works, what the alternatives are, and what the tradeoffs are." Ask for the code only after you've grasped the concepts.

Turn on Learning Mode when you're out of your depth. Yes, it feels slower. That's the point.

Treat AI output like a PR from a junior engineer. Read it. Critique it. Push back on it. Would you merge it just because the tests passed? If not, don't merge it here either.

Re-derive things by hand once in a while. Take a piece of code the model wrote for you and try to recreate it from scratch. It's the calibration check that tells you how much you've quietly lost.

Ask the model to teach you what it just did. After it writes a clever function, ask what concepts it used and what you'd need to read to understand the design choice. One extra prompt changes what you take away from the session.

None of these are dramatic. They're small posture shifts inside the same tools you're already using.

### Two metrics, not one

I've started ending coding sessions with a simple question: did I learn anything today, or did I just close issues?

Sometimes the honest answer is "I just closed issues" and that's fine. If it becomes the answer for months in a row, cognitive debt is accumulating in the background.

Ship and learn are two separate metrics. Your manager and your customers will only ever ask about the first one. The second is on you.

I'd rather ship 80% of what I could have and learn 100% of what I needed to, than the reverse. Over years, those two strategies produce very different engineers.

You don't have to choose between using AI and learning. You do have to choose a workflow that does both, because the defaults won't choose it for you. The tools are ready whenever you are.

The next boring task you were about to delegate is a good place to start.

> 📄 Original article URL: https://x.com/i/article/2055936913211899904

---

## Commentary from Other Bookmarks

### @lydiahallie (Lydia Hallie ✨) — 2026-05-18

> 💯 this is why I really like Learning mode in Claude Code
> 
> I personally use this for all my side projects and it keeps me so much sharper, great if you want to use Claude Code but still stay hands-on!
> 
> /config → Output style → Learning

[→ View quote tweet](https://x.com/lydiahallie/status/2056420694087594283)

![](https://pbs.twimg.com/media/HIndYHJbAAA1X68.jpg)

