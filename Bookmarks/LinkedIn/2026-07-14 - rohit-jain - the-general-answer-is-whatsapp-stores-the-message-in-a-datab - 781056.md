---
title: "The general answer is: “WhatsApp stores the message in a database until the user comes online.”"
author: "Rohit Jain"
author_url: "https://www.linkedin.com/in/ACoAACwGRCMBQttuuz7yl7q5afqhlyfa0hD_qa4"
headline: "Ex-Amazon | IIT KGP 2019 alum | SDE @ Square | Insights on System Design and Software Engineering"
date: "2026-07-14"
posted_relative: "2w"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7482841403572781056/"
activity_id: "7482841403572781056"
media: "image"
source: "linkedin-saved-post"
tags: [linkedin-bookmark]
---

# The general answer is: “WhatsApp stores the message in a database until the user comes online.”

> **Source:** [Rohit Jain](https://www.linkedin.com/in/ACoAACwGRCMBQttuuz7yl7q5afqhlyfa0hD_qa4) · Ex-Amazon | IIT KGP 2019 alum | SDE @ Square | Insights on System Design and Software Engineering · 2w

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7482841403572781056/)

## Post

The general answer is: “WhatsApp stores the message in a database until the user comes online.”

That is technically true, but incomplete. A better answer explains durable storage, recipient queues, delivery receipts, retries, and duplicate protection.

Here’s how I would think about this in 4 layers:

[1] Store the message before confirming “sent”

When you press send, the message first reaches a WhatsApp server.

The server gives it a unique message ID and stores the encrypted message safely. Only after that storage succeeds does the sender see the first tick.

This matters because the server should never say “message sent” while the message exists only in temporary memory. If that server crashes, the message would disappear.

[2] Keep an inbox for the offline user

The system checks whether the recipient has an active connection.

If they are online, the message can be delivered immediately.

If they are offline, the message is placed in their pending inbox. Think of it as a small queue of messages waiting for that specific user.

The queue may contain:

- message ID 
- encrypted message content 
- sender and recipient IDs 
- creation time 
- delivery status 

The message stays there until the recipient reconnects or the storage period expires.

[3] Deliver, confirm, and remove

When the recipient comes online, their phone opens a connection with the server.

The server checks the pending inbox and sends all waiting messages. But it does not delete them immediately.

First, the recipient’s device must confirm: “I received message 123.”

Only then can the server mark that message as delivered and remove it from the pending queue. That delivery confirmation is what allows the sender to see the second tick.

If the connection drops before confirmation, the server sends the message again.

[4] Prevent duplicates and preserve order

Retries create another problem. The same message may reach the phone more than once.

That is why every message has a unique ID. The recipient’s device keeps track of messages it has already processed.

If message 123 arrives again, the phone recognises it and ignores the duplicate.

Messages also carry ordering information, so a conversation does not appear randomly when several stored messages arrive together.

The better answer is: a messaging system does not simply “save the message in a database.”

It stores the message safely before confirming it, keeps a pending inbox for each offline user, retries delivery until the recipient confirms receipt, and uses unique IDs to stop retries from becoming duplicate messages.

It's more than moving text from one phone to another. 

You are designing a delivery process that must survive offline users, broken networks, retries, and server failures without asking anyone to press “send” again.

## Images

![](https://media.licdn.com/dms/image/v2/D5622AQFHaSH_VKCInQ/feedshare-shrink_480/B56Z9hkmm.GsAg-/0/1784048413514?e=1787184000&v=beta&t=BD3mBvDUEavlgaB_lpJncQW4quernc9BbkstO_qYNrc)

