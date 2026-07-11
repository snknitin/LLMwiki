---
title: "****Did you know you can just use Cloudflare email routing to get a custom email for free?****"
author: "toki"
username: "@tokifyi"
date: "2026-02-23"
tweet_url: "https://x.com/tokifyi/status/2025741929997361371"
tweet_type: "original"
likes: 5809
retweets: 512
replies: 166
bookmarks: 19483
views: 1787669
has_media: false
extraction_quality: full
article_id: "2025737865913843712"
tags: ["twitter-bookmark"]
---

# ****Did you know you can just use Cloudflare email routing to get a custom email for free?****

> **Source:** [@tokifyi](https://x.com/tokifyi) · 2026-02-23 · 👍 5809 · 💬 166 · 🔖 19483 · 👁 1787669

> 🔗 [View tweet on X](https://x.com/tokifyi/status/2025741929997361371)

## Article Content

****Did you know you can just use Cloudflare email routing to get a custom email for free?****

Most people pay $6-12/month for Google Workspace or Microsoft 365 just to get a custom email. This setup costs you nothing except the domain itself.

Here's what you need:

- A domain name ($10-15/year from Namecheap, GoDaddy, etc. - ****students: free**** via GitHub Student Pack)
- A Gmail account (free)
- Cloudflare account (free)

### Step 1: Get a Domain

- Buy one from Namecheap, Porkbun, or any registrar

- Cheapest options: .xyz, .site, .online (~$2-5/year)

- Premium options: .com, .io, .ai (~$10-15/year)

- ****Students:**** Get free domains from GitHub Student Pack: [https://education.github.com/pack](https://education.github.com/pack)

- Pick something short and memorable for your brand

### Step 2: Add Your Domain to Cloudflare

- Sign up at [cloudflare.com](https://x.com//cloudflare.com)

 (free plan works perfectly)

- Click "Add a site" and enter your domain

- Cloudflare will scan your DNS records

- Copy the two nameservers Cloudflare gives you

- Go back to your domain registrar and update the nameservers

- Wait about 5-10 minutes for DNS to propagate globally

### Step 3: Enable Email Routing

- In Cloudflare dashboard, go to Email → Email Routing

- Click "Get Started" to enable the feature

- Enter your Gmail address as the destination email

- Check your Gmail for a confirmation link from Cloudflare

- Click it to verify you own that inbox

- You're now ready to create custom addresses

### Step 4: Create Custom Email Addresses

- Click "Create address" in the Email Routing section

- Type the address you want: hello@, contact@, support@, sales@, hi@

- Choose where it forwards to (your Gmail)

- Click Save

- Repeat for unlimited addresses - they're all free

- Each one can go to the same Gmail or different inboxes

### Step 5: Send FROM Your Custom Email (Optional)

- Open Gmail and go to Settings → See all settings

- Click the "Accounts and Import" tab

- Under "Send mail as", click "Add another email address"

- Enter your name and your custom email (e.g. hello@yourdomain.com)

- On the next page, Gmail will ask for SMTP server details

- ****Important:**** Gmail will pre-populate the SMTP server with Cloudflare's MX record.

- ****Replace**** the pre-populated server with: [smtp.gmail.com](https://x.com//smtp.gmail.com)

- Port: 587

- Username: your full Gmail address (e.g. you@gmail.com)

- Password: a Google App Password (NOT your regular Gmail password)

- To get an App Password: go to Google Account → Security → 2-Step Verification (enable it if you haven't) → App passwords → generate one for "Mail"

- Click "Add Account"

- Gmail will send a verification email to your custom address

- Cloudflare forwards it right back to your Gmail inbox

- Enter the confirmation code or click the verification link

- Done. You can now send emails from your custom address directly in Gmail

### Step 6: Verify Your DNS Records

Cloudflare automatically sets up SPF, DKIM, and DMARC records when you enable email routing. You don't need to add anything manually.

To double-check:

- Go to Cloudflare → DNS → Records

- You should see MX records pointing to Cloudflare

- You should see TXT records for SPF and DKIM already in place

- If anything looks off, try disabling and re-enabling email routing

****Note**** ****on**** ****DKIM:**** Unlike Google Workspace, regular Gmail doesn't sign outgoing emails with your custom domain's DKIM key. This means some recipients might flag your emails. For personal and freelance use, the SPF record Cloudflare sets up is usually enough. If deliverability becomes an issue, that's when you'd consider upgrading to Google Workspace.

### The Result:

You receive emails at hello@yourdomain.com in your normal Gmail inbox. You can reply from that address. You look professional. You pay $0/month for email (just the annual domain cost). No storage limits because it's using your free Gmail storage.

### Important Limitations:

- Cloudflare only forwards emails - it doesn't store them or provide a mailbox

- When sending via Gmail's "Send mail as", emails might go to spam initially (needs SPF/DKIM setup)

- Gmail limits: 500 emails sent per day from custom addresses

- Not ideal for high-volume business email or teams (stick with Google Workspace for that)

Perfect for: freelancers, side projects, personal brands, small businesses, portfolio sites

Not ideal for: large teams, high-volume sales email, enterprises

That's it. Professional custom email for ~$10/year instead of $72+/year with Google Workspace.

****Note:**** It's not sponsored by Cloudflare. I just happened to know this method and wanted to share it. If you know any other free/cheap alternatives or hacks like this, let me know. Feel free to follow me for more little tips like this.

> 📄 Original article URL: https://x.com/i/article/2025737865913843712

---

## Commentary from Other Bookmarks

### @marckohlbrugge (Marc Köhlbrugge) — 2026-02-24

> I thought this was common knowledge, but this article is about to cross one million views.
> 
> Lesson: what’s obvious to you, might not be to others. Share.

[→ View quote tweet](https://x.com/marckohlbrugge/status/2026158913075445917)

