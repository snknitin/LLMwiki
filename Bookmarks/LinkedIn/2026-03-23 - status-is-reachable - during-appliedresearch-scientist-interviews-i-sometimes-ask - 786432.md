---
title: "During Applied/Research Scientist interviews, I sometimes ask this fun brain-teaser:"
author: "Status is reachable"
author_url: "https://www.linkedin.com/in/ACoAABmfcdcB4Iz6YZhRUVT5oygAmSKtdlPNQyk"
headline: "Sr Researcher @Amazon (9+ YoE) || Published: AAAI, EMNLP, ACL || Grad @UT Austin || Scientific Committee @International Olympiad in AI"
date: "2026-03-23"
posted_relative: "4mo"
post_url: "https://www.linkedin.com/feed/update/urn:li:activity:7441993441728786432/"
activity_id: "7441993441728786432"
media: "text"
source: "linkedin-saved-post"
tags: [linkedin-bookmark, llm, career]
---

# During Applied/Research Scientist interviews, I sometimes ask this fun brain-teaser:

> **Source:** [Status is reachable](https://www.linkedin.com/in/ACoAABmfcdcB4Iz6YZhRUVT5oygAmSKtdlPNQyk) · Sr Researcher @Amazon (9+ YoE) || Published: AAAI, EMNLP, ACL || Grad @UT Austin || Scientific Committee @International Olympiad in AI · 4mo

> [View post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7441993441728786432/)

## Post

During Applied/Research Scientist interviews, I sometimes ask this fun brain-teaser:
"In a binary classification problem with imbalance, when is F1 the wrong metric?"

(Pause and think for a minute...you may find it hard to think of a case).

There are several correct answers. 
One is: "When the price of poor precision is much higher than the price of poor recall", in which case you want to measure F-Beta with Beta<1. Setting Beta=1 is how we get F1.

But to me, an under-discussed case is: when the *negative* class is imbalanced i.e. we have a high prevalence: a lot of true positives and very few true negatives. In this case, you are most likely trying to detect the negatives.

Both Precision and Recall don't care about True Negatives. 
1) Precision = from the set you predicted as positive, how many are actually positive? No True Negatives in sight.
2) Recall = from the actually positive cases, how many did your model catch (i.e. predict as positive)? Again, we does not care about True Negatives.

Many applications can be erroneously framed such that True Negatives are rare and important, but not measured.
E.g. in an LLM-as-a-Judge task, if you ask "Is the LLM response correct" rather than "Is the LLM response wrong", then you implicitly set correct = 1 and wrong = 0. 
This feels quite natural...but if the ground-truth has 95% correct and 5% wrong cases, your metrics (Precision, Recall and F1) don't focus on the performance on True Negatives. You can either change the framing or use alternate equivalent metrics (NPV rather than Precision, Specificity rather than Recall, Negative F1).

Binary classification (alongside hypothesis testing) is easily one of the least intuitive tasks. It is genuinely SO easy to make mistakes. It makes you question yourself, not the model.

