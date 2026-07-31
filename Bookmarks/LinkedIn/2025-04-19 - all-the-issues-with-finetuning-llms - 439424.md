---
title: "all the issues with finetuning llms"
saved: "April 19, 2025 3:19 PM"
date: "2025-04-19"
url: "https://www.linkedin.com/feed/update/urn:li:activity:7127512530750439424/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7127512530750439424%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29"
domain: "linkedin.com"
activity_id: "7127512530750439424"
notion_tags: "Finetune, LLM"
media: "link"
extraction_quality: "full"
source: "notion-saved-links"
tags: [notion-saved-link, linkedin, finetune, llm]
---

# all the issues with finetuning llms

> **Source:** [linkedin.com](https://www.linkedin.com/feed/update/urn:li:activity:7127512530750439424/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7127512530750439424%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29) · saved April 19, 2025 3:19 PM · tags: Finetune, LLM

> [Open link](https://www.linkedin.com/feed/update/urn:li:activity:7127512530750439424/?updateEntityUrn=urn%3Ali%3Afs_updateV2%3A%28urn%3Ali%3Aactivity%3A7127512530750439424%2CFEED_DETAIL%2CEMPTY%2CDEFAULT%2Cfalse%29)

## Post

Making a tutorial is far easier than fine-tuning LLM for real. Let me share what all the issues I've faced so far and the remedies I found for different issues.

NOTE: Never use Databricks! I say never! Not even for free. The type of errors they have, you'll either go crazy or you'll apply for PHD in Prompt Engineering from YouTube. Their own tutorials don't even run properly on their machines. 

1. 7B models barely fit in your single GPU memory. With V100 (16 GB) it'll almost always give CUDA OOM issues when trained with All LoRA heads + Higher rank. You can use single A10 (24 GB) instead.

2. Tested with MAX_LEN = 412 and bam!!!!! CUDA OOM with a batch size of 2 and I have a far greater context length requirement. Wow!

3. Loaded the model in Nested Quant (4 bit) with qLoRA. Not so much helpful but yeah, whatever works.

4. Changed the Optimiser from 32 bit to 8 AdamW. Yes, now some relaxation.

5. Now let's increase the speed. Found out LLaMa v2 and Mistal supports Flash Attention! Use it! Bang!! Error. Why? Because "flash attention only supports Ampere GPUs or newer" means my V100 is of no use. Another reason to use A10. (No access to A100)

6. Time to turn on bfloat16 computation. Dayumm! Same error as above so A10 is my fav cousin now.

After 58294 days later, I got my first results and it was as exciting as 💩. Now either I could be brave to go that path again or opt for Multi GPUs parallel stuff. Since I'm not a very brave person, I chose the second and regretted on the first moment because given the type of bugs that occur, you'd have to be working in PyTorch, Nvidia, Linux, AWS and HuggingFace, all at once to solve those plus still there's no guarantee. 

Luckily, one amazing person told me about an awesome open source library "axolotl" (https://lnkd.in/dPcyAJDt) and oh boi! works like a charm. All the optimisations I'd done manually and more are already there for not even just single, multi GPUs but for multi clusters too. Can't thank them enough.

Update: You can train 1 epoch of LLaMa-2 in under 5 minutes with all qLoRA modules having rank=256 on 8xA10 GPUs with MAX_LEN >= 1600 and mini_batch >=3 on a dataset of around 30K.

Beware of:

1. Dogs

2. RuntimeError: Expected to mark a variable ready only once... (https://lnkd.in/dAX3HC-n). You have to do ddp_find_unused_parameters=False

3. In case you're using LLaMa for sequence classification, don't be surprised to see worse results than base model because there's an unresolved bug in the HF repo: https://lnkd.in/d_bWztA2

Amazing guide from Hugging Face on all the optimizations you can do (find the multi GPU link inside the blog) : https://lnkd.in/dnn6K2ry


Took me a whole lot of time to find out and solve all of these so you can thank me any day now :)

#llm #finetuning #nlp #llama2 #mistral #peft #lora #ml #ai #cuda #bug #issue #reality  #huggingface
