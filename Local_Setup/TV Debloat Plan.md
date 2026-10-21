# TV Debloat Plan (Fire TV Stick + Sony Bravia Google TV)

Built 2026-10-21 from the Social Capture "Home & device hacks" TV captures (Oct 17–20). Every tweet's thread, replies and quotes were read, along with the linked repos. Detailed notes with source links are in [[TV Debloat Research/Fire TV dumbtv and fire-tv-cleanup]], [[TV Debloat Research/Google TV cleanyourtv and Sony]], [[TV Debloat Research/Remote and phone ADB]] and [[TV Debloat Research/TV hacks roundup]].

## How everyone is doing it

There is no root and no firmware flashing. Every hack in the wave uses the same four steps:

1. Turn on **Developer options → ADB/network debugging** on the TV.
2. A computer on the same network runs `adb connect <tv-ip>:5555`. Someone at the TV presses **"Always allow"** once.
3. A coding agent such as Claude Code runs a prepared prompt or script. It uses `pm disable-user --user 0 <pkg>` on ads and telemetry packages. This is reversible with `pm enable` and deletes nothing.
4. Optionally the agent installs a small custom launcher APK and moves the Home button to it.

Most "I vibe-coded my TV" posts are steps 1–3 plus **Gathin23/cleanyourtv** (formerly tv-vibehack). It has 17k stars, lists for 174 TV models, and 22 Sony lists. On a Fire TV the equivalent is **dumbtv**.

## Your questions, answered

| Question | Answer |
|---|---|
| Same Wi-Fi needed? | The machine running `adb` has to *reach* the TV's IP. On the same LAN that works directly. From somewhere else, use Tailscale. |
| Remote (parents' house)? | Yes. Install **Tailscale on the Sony** (official Google TV app) and log it into your tailnet. Then run `adb connect 100.x.y.z:5555` from the desktop. **Never port-forward 5555**: open ADB ports are scanned by botnets. |
| Someone physically at the TV? | **Once per TV.** They enable developer options, sign in to Tailscale, and accept the "Allow debugging" prompt. Plan one phone or video call with a parent. |
| Run it all from the phone? | Yes. Phone (Claude app) → **Claude Code Remote Control** (`/rc` or `claude --remote-control`, scan the QR code) → the desktop session runs `adb`. The phone needs no ADB or Tailscale of its own. |
| Phone only, no desktop? | Possible: Termux from F-Droid, then `pkg install android-tools bash curl git`. It's untested with these repos, and you can't build launcher APKs on the phone. Not recommended. |
| Run the GitHub repos? | Yes. **dumbtv** for the Fire TV, **cleanyourtv** for the Sony. Each is a prompt plus bash/PowerShell scripts that call `adb`. Claude reads the scripts before running anything. |

## Phase 0 — Desktop prep (10 min, at the desktop)

```powershell
winget install Google.PlatformTools
```
Back up `%USERPROFILE%\.android\adbkey` after the first connection. If you lose it, both TVs show the approval prompt again, and the parents' TV needs someone in person.

Start the session with `/rc` so the rest can be done from the phone.

## Phase 1 — Fire TV Stick on the Sanyo (home LAN, ~1 h)

1. **Check the model.** Go to Settings → My Fire TV → About.
   - **Fire TV Stick 4K Select (2025)** runs Vega OS: there is no ADB, so stop here.
   - **2nd-gen stick (Fire OS 5)**: debloat is refused, so only the settings changes work.
   - **4K / 4K Max / Lite (Fire OS 7/8)**: everything below works.
2. **Enable ADB.** In About, select the device name and press OK 7 times. Then go to Developer Options and turn on **ADB debugging** and **Apps from unknown sources**. Get the IP from About → Network.
3. **Connect from the desktop.** Run `adb connect <ip>:5555` and accept "Always allow" on the TV. Then `adb shell getprop ro.build.version.sdk` gives 28 for Fire OS 7 and 30 for Fire OS 8.
4. **Debloat with dumbtv** (humblemuzzu/dumbtv, run under Git Bash). Use preflight → configure → debloat in **small batches, rebooting between them**. Before running, **remove these packages from `data/fireos/packages.txt`**:
   - `com.amazon.firebat`: this is Prime Video. Main disables it by mistake; PRs #52, #56 and #60 are unmerged.
   - `com.amazon.device.messaging`: disabling it caused a boot-animation hang that only a factory reset fixed (#57).
   - `com.amazon.vizzini`: disabling it leaves a stuck "Unable to detect remote" screen.
   - Keep `animator_duration_scale` at 1.0. At 0.5 the Fire OS 8 Settings menu can't be reached.
5. **YouTube without ads.** Use dumbtv's opt-in `youtube.sh`, which installs **SmartTube** and disables the stock YouTube app.
6. **Skip at first:**
   - **dumbtv's DNS filter:** it's fragile; three issues cover lost settings and DNS bypass.
   - **Launcher replacement:** Fire OS blocks a custom default home. Every Fire launcher, from dumbtv to orchard-tv to fire-tv-web-launcher, uses an accessibility "Home on Fire" redirect. Amazon's home flashes, and OTAs break it. dumbtv's Fire OS 8 Home fix is still only in unmerged PRs (#31 and #49).
   - Revisit after a week of stable use. **orchard-tv** is the most complete Fire launcher. **fire-tv-web-launcher** makes the home screen a web page, the easiest route to a calendar or weather dashboard.
7. **Undo** with dumbtv's `restore.sh`, or run `adb shell pm enable --user 0 <pkg>` per package.

## Phase 2 — Sony Bravia at your parents' place (one call, then remote)

**Option A, zero risk and no ADB:** turn on Google TV **Apps only mode** (profile → Settings → Accounts & sign-in). It removes the recommendation and ad rows, but also Assistant and search. If your parents mostly open Netflix and YouTube, this alone may be enough.

**Option B, full cleanup with cleanyourtv:**

1. **On the call** (they hold the remote):
   - Settings → System → About → **Android TV OS build**, press OK 7 times.
   - Developer options → **USB debugging** on. On a Sony also turn on **Wireless debugging**, since port 5555 can stay closed otherwise.
   - Install **Tailscale** from the Play Store and sign in to your tailnet, using the QR code on the TV.
   - Read you the model number from the back of the set or Settings → About.
2. **From the desktop:**
   - If the TV runs Android 13+, use the pairing code: `adb pair <tailnet-ip>:<pairport> <code>` while they read the code out, then `adb connect`, then `adb tcpip 5555` to pin the port.
   - On older Android, `adb connect <tailnet-ip>:5555`. They press **Always allow** and the call can end.
3. **Check Wi-Fi ownership first.** Run `adb shell dumpsys wifi | grep -o 'cname=[^ ]*'`. If it names `setupwraith`, disabling setupwraith later **deletes the Wi-Fi network**, and the TV drops off Tailscale and ADB. Have them forget and re-join Wi-Fi in Settings first, or skip the launcher step.
4. **Run cleanyourtv's `PROMPT.md`** with the exact model's Sony list. The agent backs up, disables in small batches, and screenshots after each step.
   - **Never disable:** `com.sony.dtv.tvinput.*`, `tvapi`, `sonysystemservice`, `sonyvendorservice` (it handles the Netflix and YouTube buttons), `braviasync*` (HDMI-CEC), anything `com.mediatek.*`, `com.sony.dtv.webapi.core`, Play Store and Play Services.
   - **Safe to disable:** Samba TV (`tv.samba.ssm*`), Sony promos and select, retail demo, and telemetry. The full list is in the Google TV notes.
5. **Launcher (optional, in this exact order):**
   1. Install it.
   2. `am start` it.
   3. `cmd package set-home-activity`.
   4. Confirm it holds focus.
   5. Only then disable `launcherx` and `setupwraith`.
   - The wrong order gives a black screen or boot loop.
   - Lower-risk alternatives that don't disable the stock launcher: **barehome** (33 KB), **Rivi**, Projectivy (closed source).
6. **After firmware updates** run cleanyourtv's `tools/check.py --fix`. Updates re-enable packages and give Home back to launcherx.
7. **Before any factory reset**, re-enable launcherx and setupwraith.

## Phase 3 — Fun extras (later)

- **Dashboard home screen** like doooyle's or srepdor's (calendar, weather, Home Assistant). Use a fire-tv-web-launcher page, or the cleanyourtv launcher with added widgets, as Amol did with GitHub stats and weather at about 65 MB RAM.
- **Intent control** like Harshit's: a small model on a home box (FirstSpark) maps a request to `adb shell am start -a android.intent.action.VIEW -d <deeplink> <pkg>`. Deep links are more robust than key-press sequences.

## Risks to know

- An OTA or firmware update re-enables packages and can drop the Home takeover. Plan to re-run the scripts.
- A factory reset undoes everything. It is also the last-resort recovery.
- Claude sometimes refuses this task. Framing it as a reversible cleanup of a TV you own gets it through.
- Netflix and DRM weren't reported to break from a normal cleanup.
- Nobody answered the warranty question.
