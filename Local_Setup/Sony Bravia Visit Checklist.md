# Sony Bravia Visit Checklist (parents' Google TV)

Written 2026-10-26 for doing the job in person, run from the phone through this desktop's Claude Code session. Background and sources: [[TV Debloat Plan]] and the [[TV Debloat Research/Google TV cleanyourtv and Sony]] notes.

## Your questions, answered

- **Same procedure as the Fire TV?** Mostly, with three differences:
  - Google TV *allows* a different home screen, so it's more reliable than on the Fire TV.
  - The bloat is Sony's and Google's, not Amazon's.
  - The tool is **cleanyourtv's Sony list** for the debloat, plus **Free My TV** as the new home screen. dumbtv is Fire TV only.
- **Why it lags:** Google TV's own home screen and its background services are heavy:
  - The stock home is about 242 MB, against about 96 MB for Free My TV.
  - Samba TV fingerprints whatever is on screen.
  - Sony promo, telemetry and retail-demo apps run in the background.
  - Autoplaying trailers.
  - People report Bravias booting about 2x faster and going from unusable to fast after the same treatment.
- **Do you still need Tailscale?** Yes, one small piece. This Claude session runs on the **desktop at home**, so going there doesn't put the desktop on their Wi-Fi. A phone can't bridge it either (cleanyourtv's remote guide: Android's Tailscale app cannot route its home network). Two ways:
  - **A. Tailscale on the TV (recommended, 5 min).** It's the same app you have; it shows a QR code on the TV and you sign in from your phone. You can uninstall it when you leave, or keep it so I can fix things after firmware updates without another visit.
  - **B. No app on the TV: your phone as the ADB machine** (about 15 min of phone setup, below). The phone sits on their Wi-Fi and runs adb in Termux, and I reach the phone over your tailnet by SSH.

## Before you leave home (2 min)

- [ ] **Desktop:** leave it on, with this session's Remote Control on. You'll chat from the Claude app.
- [ ] **Phone:** Tailscale signed in (it already is: `oneplus-open`).
- [ ] **Option B only:** install **Termux from F-Droid** while you're still on fast Wi-Fi.
- [ ] **Already ready on the desktop:** adb, Free My TV v1.2.0, SmartTube 32.68, and cleanyourtv's 38 Sony model lists in `E:\GIT_ROOT\External`.

## At the TV

### Step 1: Tell me what it is (2 min)
- **Model:** Settings → System → About. Read me the **Model name** (e.g. KD-55X80J), the **Android TV OS version** and the **build**.
- **Free storage:** Settings → System → Storage. A nearly full disk alone makes Google TV crawl.
- **What your parents use**, one line each:
  - Live TV, aerial or set-top box on HDMI?
  - Voice/mic button?
  - Casting from their phones?
  - YouTube (fine with SmartTube, which has no ads)?
  - Which apps do they actually open?

### Step 2: Free fixes first (5 min, no computer)
1. **Install any pending system update now:** Settings → System → About → System software update. Updates re-enable debloated apps, so get it out of the way before we start.
2. **Turn off trailers that play themselves**, if the TV has the switch: look for **video previews** and **audio previews** under Settings → Accounts & sign-in → your account. The path varies by model; if you can't find it in a minute, skip it, because the new home screen ends autoplay anyway.
3. **Turn off Samba TV** if offered: Settings → System → Samba Interactive TV, or Privacy, depending on model. I disable it over ADB anyway.
4. **Restart:** hold the remote's power button → Restart, or Settings → System → Restart.

### Step 3: Developer mode (2 min)
1. Settings → System → About → **Android TV OS build**: press OK 7 times. The PIN may be asked.
2. Settings → System → **Developer options**: turn on **USB debugging**.
3. If there is **Wireless debugging**, turn it on, open it and read me:
   - the **IP address & port** on that screen;
   - under **Pair device with pairing code**, the **pairing port** and the **6-digit code**.
   Sony Google TV keeps port 5555 closed with USB debugging alone, so this is usually needed.

### Step 4: The link
**Option A, Tailscale on the TV**
1. Play Store → **Tailscale** → Install → Open.
2. Scan the QR code with your phone and sign in with **your** account.
3. Read me the TV's **100.x.y.z** address.

**Option B, phone bridge.** In Termux, paste:
```
pkg update -y && pkg install -y openssh android-tools
mkdir -p ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz3IxCp+XooLFct22NaCcUfUVWgN2fz1bLZtVXae9no nike-workstation' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
termux-wake-lock; sshd; whoami
```
Send me the `whoami` result. I then SSH in with `ssh -p 8022 <user>@100.77.105.88` and run adb from the phone on their Wi-Fi.

### Step 5: I connect, you press Allow (1 min)
- I run `adb pair` with the code, then `adb connect`, then `adb tcpip 5555`.
- **"Allow USB debugging?"** appears on the TV: tick **Always allow** and press OK.

### Step 6: I measure and back up (me, 3 min)
- **"Before" numbers:** free RAM, the stock home screen's memory, and frame jank while I press arrows on the stock home.
- **Backup:** the full package list and all settings, plus a restore script, saved on the desktop.
- **Wi-Fi owner:** I check who owns the saved Wi-Fi network (`dumpsys wifi`). If it's the setup wizard (setupwraith), disabling it would **delete their Wi-Fi**. You then do Settings → Network → forget it → re-join first.
- **The right list:** I pick the closest cleanyourtv Sony list to their model, out of 38.

### Step 7: Debloat (me, 10 min, small batches, TV stays usable)
- **Switched off** (disabled, nothing uninstalled, all reversible):
  - Samba TV (`tv.samba.ssm*`).
  - Sony promos, Sony Select and launcher ads.
  - Telemetry and bug reporters.
  - Retail demo apps, help and manual apps, hotel mode.
  - Google Play Games, YouTube Music and Google feedback.
- **Never touched:**
  - Inputs and the tuner (`com.sony.dtv.tvinput.*`, `tvx`/`tvlin`).
  - `sonyvendorservice` (the Netflix/YouTube/Prime buttons) and `braviasync*` (HDMI-CEC).
  - Dolby/eARC, `com.mediatek.*`, Sony IP Control (`webapi.core`).
  - Play Store and Play Services, the keyboard, system update.
- **Your call from Step 1:** voice, Chromecast, AirPlay, BRAVIA CORE.

### Step 8: Speed and ads settings (me, 2 min)
- Animations at 0.5x: window, transition and animator.
- Optional ad-blocking DNS for the whole TV: `dns.adguard-dns.com`. It blocks ads inside most apps, but not YouTube's. **SmartTube** handles YouTube: no ads, no Shorts, same Google account.

### Step 9: New home screen, Free My TV (5 min)
1. I install it; the TV may say "Play Protect: More details → Install anyway".
2. You open **Free My TV → Home Screen → Free My TV** and accept the **second** "Allow USB debugging?" with Always allow. That one is for the app itself.
3. The app switches Google's home off in the safe order on its own: the setup app first, then the stock home.
   - **Undo for your parents:** Free My TV → Home Screen → **Original**.
   - **Safety net:** after three crashes in five minutes it goes back on its own.
   - **Remote buttons:** it maps Sony's Netflix / YouTube / Prime / BRAVIA CORE buttons in **Remote Buttons**.

### Step 10: Check together (5 min)
- [ ] Arrow keys feel instant. I take "after" numbers and compare them with Step 6.
- [ ] Netflix, YouTube (SmartTube), Prime and the other apps open and play.
- [ ] The remote's app buttons and the **Input** button work. Live TV / HDMI box works.
- [ ] Casting from a phone works, if they use it.
- [ ] Voice works, if kept.

### Step 11: Leaving
- **Leave USB debugging on.** Free My TV runs its own ADB on the TV (127.0.0.1) for its undo, watchdog and boot check. Network ADB still needs an accepted key, and it's behind their router.
- **Never port-forward 5555 on their router.**
- **Tailscale:** keep it so I can redo the debloat after a firmware update from home, or uninstall it.
  - If you keep it, I'll limit it in your tailnet's access rules so the TV can't reach your devices and only the desktop can reach the TV.
- **After firmware updates:** apps come back. Tell me and I re-run the list (cleanyourtv `tools/check.py --fix`).
- **Before any factory reset:** Free My TV → Original first.

**Total time:** about 45–60 minutes, most of it waiting on me.
