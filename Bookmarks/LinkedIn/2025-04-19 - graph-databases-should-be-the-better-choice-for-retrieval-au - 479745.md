---
title: "Graph Databases should be the better choice for Retrieval Augmented Generation (RAG)"
saved: "April 19, 2025 2:50 PM"
date: "2025-04-19"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7195362713848479745/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7195362713848479745%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7195362713848479745"
notion_tags: "GNN, RAG"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, gnn, rag]
---

# Graph Databases should be the better choice for Retrieval Augmented Generation (RAG)

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7195362713848479745/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7195362713848479745%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 19, 2025 2:50 PM · tags: GNN, RAG

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7195362713848479745/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7195362713848479745%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Graph Databases should be the better choice for Retrieval Augmented Generation (RAG)! We have seen the debate RAG vs fine-tuning, but what about Vector databases vs Graph databases?

In both cases, we maintain a database of information that an LLM can query to answer a specific question. In the case of vector databases, we partition the data into chunks, encode the chunks into vector representations using an LLM, and index the data by their vector representations. Once we have a question, we retrieve the nearest neighbors to the vector representation of the question. The advantage is the fuzzy matching of the question to chunks of data. We don't need to query a specific word or concept; we simply retrieve semantically similar vectors. The problem is that the retrieved data may contain a lot of irrelevant information, which might confuse the LLM.

In the context of graphs, we extract the relationships between the different entities in the text, and we construct a knowledge base of the information contained within the text. An LLM is good at extracting that kind of triplet information:

[ENTITY A] -> [RELATIONSHIP] -> [ENTITY B]
 
For example: 
- A [cow] IS an [animal]
- A [cow] EATS [plants]
- An [animal] IS a [living thing]
- A [plant] IS a [living thing]

Once the information is parsed, we can store it in a graph database. The information stored is the knowledge base, not the original text. For information retrieval, the LLM needs to come up with an Entity query related to the question to retrieve the related entities and relationships. The retrieved information is much more concise and to the point than in the case of vector databases. This context should provide much more useful information for the LLM to answer the question. The problem is that the query matching needs to be exact, and if the entities captured in the database are slightly semantically or lexically different, the query will not return the right information.

I know that there are databases that now merge the advantages of vector and graph databases. We can parse the entities and relationships, but we index them by their vector representations in a graph database. This way, the information retrieval can be performed using approximate nearest neighbor search instead of exact matching. 

--
👉 Don't forget to subscribe to my ML newsletter: https://lnkd.in/g4iKyRmS
--
