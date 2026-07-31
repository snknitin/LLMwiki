---
title: "State of Machine Learning Competitions report"
saved: "April 17, 2025 11:05 PM"
date: "2025-04-17"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7303059476184449025/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7303059476184449025%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7303059476184449025"
notion_tags: "ML"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, ml]
---

# State of Machine Learning Competitions report

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7303059476184449025/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7303059476184449025%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 17, 2025 11:05 PM · tags: ML

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7303059476184449025/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7303059476184449025%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Every Spring, I'm excited to read through the comprehensive ~100-page "State of Machine Learning Competitions" report, which offers many interesting insights into current trends, useful tools, and emerging methodologies in the field. Below are some key takeaways from the latest 2024 report (https://lnkd.in/g5c-iU3x):

1) Language & frameworks
- Python remains the dominant language, with 76 out of 79 winning solutions.
- PyTorch continues to be the deep learning framework of choice, with 53 out of 60 deep learning competition winners.
   
2) Hardware trends
- Over 80% of winning teams used NVIDIA GPUs (with A100s being the most popular)
- Interestingly, there's still no mention of AMD GPUs.
- I'm surprised no solution utilized more than an 8xH100 server, which suggests that multi-node setups are either underutilized or underreported.
   
3) Efficiency Techniques
- Techniques like LoRA are still popular choices for reducing training compute requirements, but many now opt for full finetuning for improved modeling performance.
- And 8-bit and 4-bit quantization remain the most popular approaches for lowering inference compute requirements.
   
4) LLM reasoning
- The integration of chain-of-thought reasoning and inference-time scaling already made its way into competitions. But these approaches currently rely on simplistic majority voting rather than advanced verifier LLMs (I expect more sophisticated implementations soon)
   
5) Computer vision
- Interestingly, most winning solutions in computer vision competitions are CNN- rather than transformer-based.

Bonus: In one of the chapters of my LLM book, I described training a decoder-style LLM (GPT) for classification, which is a concept that surprised many readers. Interestingly, the report mentioned that many NLP competitions used decoder-style LLMs for classification tasks as well:

> [...] several competitions seemed designed specifically with these powerful new decoder LLMs in mind. [...] The most commonly-used decoder models among competition winners in 2024 were variants of Llama, Mistral, Gemma, Qwen, and DeepSeek models. Several competition winners used only decoder models." 
 
However, I recently saw the release of ModernBERT by Jeremy Howard's team, and I recommend at least trying this new encoder-style model before jumping to (often larger) decoder-style LLMs.
