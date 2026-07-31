---
title: "Clustering - BIC replaces elbow method"
saved: "August 30, 2025 2:13 PM"
date: "2025-08-30"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7027546291760996354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7027546291760996354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7027546291760996354"
notion_tags: "Interview, ML"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, interview, ml]
---

# Clustering - BIC replaces elbow method

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7027546291760996354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7027546291760996354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved August 30, 2025 2:13 PM · tags: Interview, ML

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7027546291760996354/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7027546291760996354%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Are you still using the "elbow method"?

Despite being so popular, the elbow method is pretty much the worst choice one can do when choosing the number of clusters for a dataset.

So what should you use instead?

In a recent paper, Erich Schubert shows that BIC (Bayesian Information Criterion) often outperforms other methods. So, I have taken the GoLang implementation of BIC made by Robert Hancock, translated it into Python, and tested it against the elbow method. 

The difference in performance between the two methods is huge!

For example, in these 5 datasets, the elbow method guesses the true number of clusters only once, whereas the BIC score makes the right choice every time.

☕ Read about the full experiment in my article on Towards Data Science: https://lnkd.in/dEpMjpBP

🐍 Find the fully reproducible Python code on my GitHub: https://lnkd.in/dxvAq6Jg

#datascience #clustering #statistics #metrics #python #github
