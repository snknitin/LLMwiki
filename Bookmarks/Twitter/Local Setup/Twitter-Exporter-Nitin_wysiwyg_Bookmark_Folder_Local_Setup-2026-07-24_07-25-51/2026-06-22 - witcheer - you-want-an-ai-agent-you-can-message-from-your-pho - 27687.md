---
title: "you want an AI agent you can message from your phone, one that kept running after you close the lapt..."
author: "witcheer"
username: "@witcheer"
date: "2026-06-22"
tweet_url: "https://x.com/witcheer/status/2069075880912027687"
tweet_type: "original"
likes: 263
retweets: 36
replies: 7
bookmarks: 797
views: 121312
has_media: false
extraction_quality: full
article_id: "2069063060925394944"
tags: ["twitter-bookmark", "agents"]
---

# you want an AI agent you can message from your phone, one that kept running after you close the lapt...

> **Source:** [@witcheer](https://x.com/witcheer) · 2026-06-22 · 👍 263 · 💬 7 · 🔖 797 · 👁 121312

> 🔗 [View tweet on X](https://x.com/witcheer/status/2069075880912027687)

## Article Content

you want an AI agent you can message from your phone, one that kept running after you close the laptop and come back on its own after a reboot? Hermes Agent does this: it runs as a gateway you talk to over Telegram, and once you wire it up right, it restarts itself after a crash or a power cut.

I built the same setup on two boxes, a cheap cloud VPS and the Mac Mini on my desk, so I could write the whole path down with nothing skipped. it is one route. the box only changes what you type in two places: the install command, and the part that keeps the gateway alive. everything in between is identical.

everything below ran on my own hardware. the Linux path is a Hetzner CX23 (x86, 2 vCPU, 4GB RAM, 40GB disk) on Ubuntu 24.04.4 LTS - the Mac path is a Mac Mini M4 on macOS 15. both ran Hermes Agent v0.16.0.

### what you will have at the end

- Hermes Agent installed, running as a normal user, not root
- a Telegram bot you message from your phone, locked to your account only
- the gateway running as a managed service, so it comes back after a crash or a reboot
- on the VPS, a hardened box: key-only ssh, no root login, a firewall

### pick your box

a VPS is the cheapest way in. any x86 box with 4GB RAM and about 20GB of free disk runs this; mine is a Hetzner CX23 at $7.79/month (Hetzner US pricing, 2026-06-18). rent it, and it is always on by definition.

a Mac you already own is the other option. any Apple silicon Mac that stays powered works, and the running cost is zero beyond the model. the trade is that the durability layer is fiddlier on macOS, which I cover at the end.

you need an ssh key on your own machine (ssh-keygen -t ed25519 if you do not have one), a Telegram account, and a model for the agent. this guide points at Nous Portal, which is OAuth, so there is no API key to keep in a file. Hermes needs a model with at least 64k context.

### step 1: get the box ready

> on a VPS

create the server at your provider: Ubuntu 24.04, an x86 instance (not Arm, see the cost note), and paste your ssh public key at create time.

a fresh public box needs a few minutes of hardening before you put an agent on it. the [secure-box.sh](https://x.com//secure-box.sh)

 in the recipe does it in one pass: an apt upgrade, a 2GB swapfile, a non-root sudo user with your key, key-only ssh with root login off, and a firewall that allows only ssh. edit the two variables at the top, copy it over, run it as root:

```bash
scp secure-box.sh root@<your-vps-ip>:
ssh root@<your-vps-ip> 'bash secure-box.sh'
```

this Ubuntu image shipped with PasswordAuthentication set to yes, even though I created the box with an ssh key. the script turns it off. before you close the root session, open a second terminal and confirm the new user logs in, so a mistake cannot lock you out:

```bash
ssh hermes@<your-vps-ip>
```

from here you are hermes, not root.

> on a Mac

no hardening pass. it is your machine on your own network, not a public box. install Homebrew if you do not have it (the installer uses it on the next step) and you are ready.

### step 2: install Hermes

the install is one command, the same on both boxes, run as your normal user:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc
hermes --version
```

the installer detects your OS and pulls its own toolchain (uv, Python 3.11, Node.js 22, ripgrep, ffmpeg, a Playwright Chromium for browser tools) into ~/.hermes, so it never touches your system Python. on my Hetzner box it landed Hermes Agent v0.16.0 on Python 3.11.15.

this is the heavy step. on the VPS it took the disk from 1.2GB used to 7.8GB, about 6.6GB, most of it the browser engine and Node. plan for 20GB free and stop worrying. run over a plain ssh command with no terminal, the installer prints Setup wizard skipped (no terminal available), which is fine, the setup is the next step.

on a Mac the same command runs, with one wrinkle: install Homebrew first. with Homebrew present, the installer pulls git and its dependencies without a prompt. without it, it falls back to Apple's Command Line Tools, which can open a macOS dialog you have to click, and a dialog is no good over ssh (this is in the installer's macOS branch). after that it is the same flow as above.

### step 3: point it at a model

```bash
hermes setup --portal
```

this is OAuth against Nous Portal: it prints a URL and a code, you approve it in the browser, and now the box talks to a model with no API key sitting in a file. Nous Portal has a free tier, and I ran the whole thing on a free model. if you would rather bring your own provider, run hermes model and pick one; the key then lives in ~/.hermes/.env.

### step 4: talk to it

> on a VPS

the moment your ssh drops, a foreground session dies with it. tmux keeps the session alive: start inside tmux, detach, and it keeps running.

```bash
sudo apt-get install -y tmux
tmux new -s hermes        # then, inside:  hermes
```

detach with Ctrl-b then d, and reconnect later from anywhere:

```bash
ssh hermes@<your-vps-ip>
tmux attach -t hermes
```

first boot of the interactive agent takes a moment. mine spent about 30 seconds loading the model and skills before the prompt appeared. once it is up, the slash commands work.

/goal is the one worth showing: it sets a standing goal the agent works on across turns, with a judge model checking after each turn whether it is done.

```bash
/goal check this box total RAM and free disk using shell tools, then report both on one line and mark the goal done
```

mine ran the shell command itself and came back with VPS total RAM: 3.7Gi, free disk space: 28G in about 15 seconds. that is the agent using its own tools.

keep two ideas apart: tmux holds an interactive session open across a dropped ssh connection, but not across a reboot. for an unattended gateway that survives a restart, you want a managed service, which is step 6.

> on a Mac

you are sitting at the machine, so you can run hermes in a terminal. tmux still helps if you ssh in from your laptop, but it is optional here.

### step 5: the Telegram gateway

this part is identical on both boxes. create a bot: message @ BotFather on Telegram, send /newbot, and copy the token. get your numeric user id from @ userinfobot. then configure the gateway:

```bash
hermes gateway setup
```

pick Telegram, paste the token, and set the allowed users to your numeric id so only you can talk to it. the token lands in ~/.hermes/.env, the rest in ~/.hermes/gateway.json.

setup only writes config. it does not start anything, so the bot stays silent, and that catches people out: nothing is polling Telegram yet. start it in the foreground once to check it connects:

```bash
hermes gateway run
```

you want to see, in the log:

```bash
gateway.run: Connecting to telegram...
[Telegram] Connected to Telegram (polling mode)
gateway.run: ✓ telegram connected
```

polling mode means the gateway reaches out to Telegram; nothing connects in to your box, which is why the firewall needs no inbound port beyond ssh. message your bot; it should answer. then stop the foreground gateway with Ctrl-C, because you cannot have two things polling the same token at once, and the next step runs it as a service.

### step 6: make it survive a reboot

this is the one place the two boxes diverge.

> on a VPS: systemd

hermes gateway install registers the gateway as a systemd service so it restarts on crash and comes back after a reboot. on this version the installer asks two [Y/n] questions and there is no flag to skip them. run it over a non-interactive ssh command, the natural thing when scripting a box, and it gets no answer, aborts, and installs nothing. feed the answers in on stdin:

```bash
printf 'n\nY\n' | hermes gateway install
```

the two questions are "start the gateway now?" and "start automatically on login/boot?". the n then Y says: do not start it this second, but do enable it on boot. the installer also turns on user-session lingering, which is what lets a user service run before you have logged in. confirm it, because this is what makes "survives reboot" true and not only "survives logout":

```bash
loginctl show-user $USER -p Linger     # want: Linger=yes
```

start it and check it:

```bash
hermes gateway start
systemctl --user status hermes-gateway
```

you want active (running) and NRestarts=0. on my box the gateway used about 280MB and the whole machine sat at about 556MB, comfortable on 4GB.

now the real test. reboot and do not touch it:

```bash
sudo reboot
```

mine came back in about 15 seconds, the gateway had started on its own, reconnected to Telegram, and answered the next message with the conversation history from before the reboot intact. that is the whole point.

> on a Mac: launchd and a watchdog

macOS uses launchd, not systemd, and there is a trap. on macOS 15 with Hermes v0.16.0, hermes gateway start can fail to register the launchd service and fall back, without telling you, to an unsupervised background process. you see this:

```bash
Bootstrap failed: 5: Input/output error
⚠ launchd cannot manage the gateway on this macOS version (launchctl exit 5)
✓ Started gateway as a background process instead
  It will NOT auto-start at login or auto-restart on crash.
```

if you had a working launchd job before, the command unloaded it, and the fallback runs fine until the first crash or reboot, then your agent is gone with nothing to tell you. raw launchctl works where the cli fails, including over ssh:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.hermes.gateway.plist
launchctl print gui/$(id -u)/ai.hermes.gateway | grep state    # want: state = running
```

the plist starts the gateway at login but does not restart it on crash. a cron watchdog closes both gaps, and cron runs at boot with no login needed. the recipe ships [gateway-watchdog.sh](https://x.com//gateway-watchdog.sh)

; it checks every 5 minutes whether the gateway process is alive and re-bootstraps it if not. install it on a schedule:

```bash
(crontab -l 2>/dev/null; echo '*/5 * * * * $HOME/scripts/gateway-watchdog.sh >/dev/null 2>&1') | crontab -
```

I have watched this sequence recover a downgraded gateway on my own Mac Mini. reboot it and confirm the gateway is back within five minutes without logging in.

### verify your setup

1. the service is up: systemctl --user status hermes-gateway on Linux (active (running)), or launchctl print gui/$(id -u)/ai.hermes.gateway | grep state on macOS (state = running)
2. message your bot: it answers you, and ignores anyone not in your allowed users
3. on Linux, loginctl show-user [$USER](https://x.com/search?q=%24USER&src=cashtag_click)

 -p Linger reads Linger=yes
4. reboot the box, wait, message the bot again without logging back in: it answers

### cost

on the VPS, the box is the only spend. mine is a Hetzner CX23 at $0.012/hour, capped at $7.79/month (Hetzner US pricing, 2026-06-18; the EU CX22 is the same shape and cheaper).

on the Mac, it is a machine you already own, zero extra services. the model is free on Nous Portal's free tier in both cases.

here, memory is not the limit: the gateway used about 280MB, the whole box about 556MB, so 1GB of RAM is plenty. disk is the real limit: the install is about 6.6GB, so a 1GB or 10GB image is tight, give it 20GB. and use x86, it is the safe pick.

### run it yourself, and what is next

both boxes have a full recipe with the exact scripts, runnable as-is:

- the VPS path: [cheap-vps](https://github.com/notwitcheer/hermes-recipes/tree/main/recipes/cheap-vps)
- the Mac path: [mac-mini-24-7](https://github.com/notwitcheer/hermes-recipes/tree/main/recipes/mac-mini-24-7)

you now have an always-on agent on Telegram that survives a reboot.

the next Flightplan builds on top of it: scheduled jobs that message you only when something matters, a git-synced workspace the agent reads and writes, and the draft-and-approve flow that keeps a human on every public action.

thanks for reading

> 📄 Original article URL: https://x.com/i/article/2069063060925394944

