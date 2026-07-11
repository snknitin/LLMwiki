---
title: "when your data is mostly hierarchical rather than relational (documents own other documents, big to..."
author: "Yuan Gao"
username: "@mesetatron"
date: "2025-06-21"
tweet_url: "https://x.com/mesetatron/status/1936299996976234556"
tweet_type: "reply"
likes: 708
retweets: 19
replies: 10
bookmarks: 407
views: 17879
has_media: false
extraction_quality: full
tags: ["twitter-bookmark"]
---

# when your data is mostly hierarchical rather than relational (documents own other documents, big to...

> **Source:** [@mesetatron](https://x.com/mesetatron) · 2025-06-21 · 👍 708 · 💬 10 · 🔖 407 · 👁 17879

> 🔗 [View tweet on X](https://x.com/mesetatron/status/1936299996976234556)

## Tweet Content

when your data is mostly hierarchical rather than relational (documents own other documents, big to little, one-to-many-and-to-nothing-else), and when you benefit from indexing of nested keys

here's a somewhat contrived example: let's say you're making an online game where you have equipment slots that can contain items can have zero or more enhanced properties, like enchantments, or customized name and appearances. and you want to be able to query for equipped items that have specific properties (which might happen if you had a quest or something where having any item equipped in any slot with a anti-vampiric quality passes some narrative check)

in rdb terms, you have an equipment table, items table, and possibly several different tables covering each of the item's possible extrinsic properties

to do the query, you'd need to make sure you have an index on the right columns and do two joins across the equipment table and items table, and whichever third table the queries for item extrinsic property lives in. and this operation involves reading three tables, querying three indexes to get the relations right, and the fourth index for the property, assuming that's high traffic enough to warrant the index

RDB purists would say "marvelous, which is the amazing expressive power of relational tables, that I can formulate this big join query and flex my SQL prowess"

On a document store however, it's just one document per equipment slot with approximately this structure:

{
  userId: "123",
  slot: ring
  item: {
    id: "basicRing",
    enchants: [
      { type: garlic }
    ]
  }
}

with sparse index on whichever nested fields are relevant, and a single query for that property. For example, you can tell the document database to index .item .enchants .type, and query for all documents where owner is the user, and .item .enchants .type == garlic. that's a query that involves exactly two indexes. user ID, and the one you added to the property assuming this query was important enough to have one

There are obvious limitations to this structure. I picked a problem that was _mostly_ hierarchical: equipment slot owns item, which owns extrinsic properties. if we had more complex relations to manage, this becomes harder to express in document stores. However when data can be structure in this way, the ability to index nested documents of arbitrary structure has significant performance advantages and reduced complexity over multi-table joins. (also I'm ignoring schema control, that's still an option and some document databases offer it, that's a different tradeoff discussion)

