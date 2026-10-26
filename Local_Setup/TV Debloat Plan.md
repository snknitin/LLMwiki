# TV Debloat Plan (Fire TV Stick + Sony Bravia Google TV)

First built 2026-10-21 from the Social Capture "Home & device hacks" TV captures. **Updated 2026-10-26** with the captures from Oct 21–25 and the repo changes since then. Every tweet's thread, replies and quotes were read, along with the linked repos. Detailed research notes with source links are in [[TV Debloat Research/Fire TV dumbtv and fire-tv-cleanup]], [[TV Debloat Research/Google TV cleanyourtv and Sony]], [[TV Debloat Research/Remote and phone ADB]] and [[TV Debloat Research/TV hacks roundup]]. Where those notes and this page disagree, this page is newer.

## What changed since Oct 21

- **dumbtv fixed every problem on our list.**
  - Prime Video (`firebat`), the boot-hang package (`device.messaging`) and the remote popup (`vizzini`) are now on its never-disable list.
  - The Fire OS 8 Home-button takeover is merged (PRs #31 and #49), and so is the DNS-filter fix for Fire OS 8.
  - Its launcher is a prebuilt release (dumbtv home 1.5), so the desktop needs no Java or Android SDK.
  - It's now one sentence to an agent. dumbtv's AGENTS.md drives the agent, which asks a few questions and reboots the TV twice.
- **New for the Sony: Free My TV** (simbasjungles/free-my-tv, from @SimbasJungles, saved Oct 21). It's a better fit for your parents than cleanyourtv:
  - A ready APK, so nothing to build. The new home screen uses 96 MB of memory where the stock one uses 242 MB.
  - **A one-button undo on the TV itself**: Free My TV → Home Screen → *Original*. Your parents can undo it without you.
  - **A safety net:** after three crashes in five minutes it brings the stock home back by itself, and a boot check keeps your choice after TV updates.
  - **Sony support:** it maps the BRAVIA CORE, Netflix, Disney+, Prime, YouTube and Crunchyroll remote buttons.
  - It never disables an app that saved the Wi-Fi network, so the TV can't lose its connection.
  - It switches setupwraith and the launcher in the safe order by itself.
  - It runs its ADB commands from inside the TV (to 127.0.0.1:5555), so after the install no computer is needed.
- **cleanyourtv** (formerly tv-vibehack) is still the best general toolkit: 316 TV models, 89 brands, 121 showcased projects. It's the fallback if Free My TV misbehaves on the Bravia.
- **The TCL proof point** (@TheWarKettle): disabling 24 apps on a 1.4 GB-RAM Android TV 9 made it clearly faster. He added cleanyourtv's Pi-hole stats add-on, so the TV shows what it blocks. His view: a streaming stick still wins on raw power, but debloating closes much of the gap.
- **Not for your devices:**
  - TizenTube: Samsung Tizen TVs only. On the Fire TV and the Sony, SmartTube does the same job.
  - Stremio + Real-Debrid: piracy-adjacent, so skipped.
- **Related security captures:** Alex Hillman's Tailscale ACL lockdown prompt. Use it when the parents' TV joins your tailnet (Phase 2, step 6).

## Status log

**2026-10-26: Fire TV Stick (Sanyo) — Phase 1 done**
- **Device:** Fire TV Stick 4K 1st gen (AFTMM), Fire OS 6.7.1.1. dumbtv's catalogue lists this model as fully tested.
- **Tools:**
  - adb runs from the desktop over LAN to 192.168.1.8. The desktop is on 192.168.0.x and routes to it fine.
  - adb is installed by winget (`Google.PlatformTools`). The adb key is backed up in `%USERPROFILE%\.android\backup\`.
  - Repos and APKs are in `E:\GIT_ROOT\External\` (dumbtv, `tv-apks\`, `free-my-tv-release\`).
- **dumbtv answers:** prime=1, alexa=1 (kept, since Fire TV voice search runs through Alexa), launcher=1, dnsfilter=1, youtube=1, system_dns=0.
- **Results:**
  - 30 packages disabled.
  - 9 protected packages starved of background running, including both OTA updaters.
  - 13 privacy settings applied.
  - DNS filter live (382 hosts).
  - dumbtv home 1.5 owns Home, via Keeper.
  - SmartTube 32.56 installed, stock YouTube disabled.
  - `verify.sh`: **all checks passed**.
- **Added afterwards:**
  - Stremio 1.10.4 (Android TV, armeabi-v7a, from dl.strem.io) and CloudStream 4.8.0 (GitHub release).
  - Only the apps were installed; no add-ons or provider repos were added.
  - 420 MB of storage left.
- **Gotcha:** don't export `MSYS_NO_PATHCONV=1` when running the dumbtv scripts from Git Bash. curl then gets `/c/...` paths and fails with "error 23".
- **Open: Prime Video still shows the US price.**
  - The Amazon login is one identity; India Prime covers shopping only.
  - The stick registers on amazon.com because the account's *digital* country is US.
  - Fix: change it to India on amazon.com → Content & Devices → Preferences → Country/Region. Then re-register, sync, `pm clear com.amazon.firebat`, and reboot.
  - The DNS filter may need pausing for that.
- **Left for the owner on the TV:**
  - SmartTube: Settings → General → Hide content → "Hide shorts everywhere".
  - SmartTube: Player → Video presets → 1080p 60fps vp9.
  - App order in dumbtv home → Options.
- **Undo everything:** `cd E:\GIT_ROOT\External\dumbtv && ./scripts/restore.sh -y`.

**2026-10-26: Fire TV home screen styles (Wii, PlayStation, Spotlight)**
- **Where it lives:**
  - dumbtv home was rebuilt from source on the local branch `skins` in `E:\GIT_ROOT\External\dumbtv`, commit 719d60f. It is not pushed anywhere: the Spotlight and XMB originals have no licence, so this is a personal build only.
  - The APK and the TV's `home.conf` are copied to `E:\GIT_ROOT\External\tv-apks\`.
- **Switching:** Options → Layout cycles Rows / Grid / Wii / PlayStation / Spotlight. The same setting is `layout=` in `home.conf`. Each style runs inside dumbtv home, so the Fire OS 6 Keeper still owns HOME.
  - **Wii:** written for this build, in English. 12 tiles a page, the curved clock bar, Options and Settings buttons.
  - **PlayStation:** ported from amachador/xmb-home. Cross bar with Settings / Search / Video / Apps, PSP waves, month colours. Search filters installed apps. 0 janky frames.
  - **Spotlight:** ported from IyiolaJay/spotlight-tv. Turning wheel and glass card. `name=Nitin` gives the greeting and the signature. 0 janky frames.
- **Toolchain:**
  - JDK 17 is Temurin, from winget.
  - The Android SDK is in `E:\Android\sdk` (platform 25, build-tools 34). The owner approved accepting the SDK licence.
  - Build with `ANDROID_HOME=/e/Android/sdk JAVA_HOME=".../jdk-17..." ./launcher/install.sh --build`.
- **Windows build fixes** (committed in build.sh):
  - Argfile paths go through `cygpath`.
  - The `.bat` build tools are resolved.
  - `jar` stands in for `zip`.
  - Assets must stay flat, because aapt2 writes `dir\file`.
- **Signing:** the build uses its own key (`launcher/release.keystore`, git-ignored). Back it up: the official dumbtv release can't update over it, and swapping back means uninstalling.
- `verify.sh`: all checks passed after the swap.
- **Default and switching** (commit f8183be):
  - Spotlight is the default layout.
  - The remote's **⏩ / ⏪** step through Spotlight → PlayStation → Wii → Grid → Rows, in one press, with a name toast.
  - Measured on the TV, from key press to the first frame of the new style: 31–208 ms. PlayStation then plays its 1.8 s fade-in.
  - The child lock blocks the switch.

## How you'll run it: your phone, this desktop, Remote Control

```
Phone (Claude app → Code) ──Remote Control──▶ this desktop session
                                              │ adb (LAN)      → Fire TV Stick on the Sanyo
                                              │ adb (tailnet)  → Sony Bravia at your parents'
```

- **Yes, turn on Remote Control for the session.** Use the Remote Control switch in the session toolbar, or ask me to turn it on. Then open the Claude app on your phone → Code, and this session appears there. Everything runs on the desktop, so the phone needs nothing installed.
- **Use this session**, so all the research stays in context.
- **Keep the desktop awake while you work.** It never sleeps (display-off only), so this is already fine.
- **You still need to be at the TV with the remote** for a few on-screen prompts. The phone in your hand is the chat; the TV remote is in the other hand.

## Phase 0 — Desktop prep (5 min; I can do it once you say go)

1. `winget install Google.PlatformTools`, which installs adb. It isn't on the desktop yet.
2. Clone `humblemuzzu/dumbtv`, and download the Free My TV release APK, into `E:\GIT_ROOT\Tools\tv\`.
3. After the first TV connection, back up `%USERPROFILE%\.android\adbkey`. If you lose it, both TVs ask for approval again in person.

## Phase 1 — Fire TV Stick on the Sanyo (at home, ~40 min)

**You, at the TV (5 min):**
1. Settings → My Fire TV → About. Note the model name. The 2025 *4K Select* runs Vega OS, so no ADB: stop there. The 2nd gen (Fire OS 5) supports settings changes only.
2. On the device name, press OK 7 times. Then go to Developer Options and turn on **ADB debugging**.
3. Read the IP from About → Network and type it in chat. The desktop is on 192.168.0.x. If the stick shows a different subnet (for example 192.168.1.x) and I can't reach it, I'll run adb from FirstSpark instead, which sits on 192.168.1.x.

**Me, from the desktop:**
1. `adb connect <ip>:5555`, and you press **Allow → Always allow** on the TV.
2. `scripts/preflight.sh`: reads the TV and changes nothing. I'll post what it would change.
3. `configure.sh`, answered from chat:

   | Question | Recommended answer |
   |---|---|
   | Prime Video? | Yes |
   | Alexa voice button? | Your call; it's off if you say no |
   | dumbtv home launcher? | Yes |
   | DNS filter? | Yes |
   | Apps to remove? | None |
   | SmartTube instead of YouTube? | Yes, for no ads and no Shorts |

4. `all.sh`: it asks before each step and reboots the TV twice. I screenshot the TV (`adb exec-out screencap`) after each step and send it to your phone.
5. `verify.sh`, then you test Netflix, Prime, YouTube/SmartTube, the remote and the Home button.

**Undo:** `scripts/restore.sh`.

## Phase 2 — Sony Bravia at your parents' place (one video call, then remote)

**Option A, no ADB:** Google TV **Apps only mode** (profile → Settings → Accounts & sign-in). It hides the ad rows but also removes Assistant and search. Use it if they don't want anything installed.

**Option B, Free My TV over Tailscale (recommended):**

**Before the call:** I prepare the APK, and in the Tailscale admin console you make an ACL rule (step 6) ready to apply.

**On the call (~15 min, a parent holds the remote):**
1. Settings → System → About → **Android TV OS build**: press OK 7 times. Then Developer options → **USB debugging** on.
   - If the TV runs Android 14, also turn on **Wireless debugging**, since port 5555 can stay closed.
2. Play Store → install **Tailscale** → sign in with your account using the QR code on the TV.
   - This needs your account login on your phone. That's yours to do; I never handle the credentials.
3. I connect over the tailnet with `adb connect 100.x.y.z:5555`. On Android 14 that's `adb pair` with the code they read out, then `adb tcpip 5555`. They press **Always allow**.
4. I check whether setupwraith owns the saved Wi-Fi network (`dumpsys wifi`). If it does, they forget and re-join the Wi-Fi in Settings. Free My TV also asks for this.
5. I install Free My TV (`adb install -r FreeMyTV.apk`). They open **Free My TV → Home Screen → Free My TV** and accept the second **Allow USB debugging** prompt (the app's own key), with "Always allow" ticked. Then I post a screenshot.
6. **Lock it down:** apply a tailnet ACL so the parents' TV can't reach anything of yours, and only the desktop can reach it (port 5555 only). Never port-forward 5555 on their router.

**Afterwards, from anywhere:**
- Optional TMDB key: free, so trending picks appear (this needs a self-built APK).
- Remote-button mapping.
- Re-checks after firmware updates.
- **Android 14 caveat:** port 5555 closes at every restart, so after a reboot I re-pin it with `adb tcpip 5555` over the existing pairing. Free My TV's watchdog depends on that port.
- **If anything looks wrong:** a parent presses Free My TV → Home Screen → *Original*.

**Fallback:** cleanyourtv's `PROMPT.md` with the exact Bravia model list.
- Never disable: `com.sony.dtv.tvinput.*`, `sonyvendorservice`, `braviasync*`, `com.mediatek.*`, `webapi.core`, Play Store/Services.

## Phase 3 — Extras (later)

- **Dashboard home** like doooyle's or srepdor's: calendar, weather, Home Assistant. On the Fire TV use fire-tv-web-launcher; on the Sony, add-ons from the cleanyourtv showcase.
- **Pi-hole stats add-on**, if you run Pi-hole or AdGuard Home on FirstSpark.
- **Intent control** like Harshit's: a small model on FirstSpark maps a request to `adb shell am start -a android.intent.action.VIEW -d <deeplink> <pkg>`.

## Risks to know

- An OTA or firmware update can re-enable packages.
  - dumbtv's DNS filter blocks Amazon's update servers. Free My TV's boot check keeps its home screen.
  - Re-run `verify.sh` or cleanyourtv's `check.py --fix` after an update.
- A factory reset undoes everything and is the last-resort recovery.
  - On the Sony, switch Free My TV to *Original* before any reset.
- Claude sometimes refuses TV tweaks. Framing it as a reversible cleanup of TVs you own gets it through.
- Netflix and DRM weren't reported to break. Nobody answered the warranty question.
