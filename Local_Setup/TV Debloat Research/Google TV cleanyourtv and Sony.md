# Debloating a Sony Bravia (Google TV) over ADB and replacing the launcher

Research date: 2026-10-21. Read-only research; nothing was run against any TV.

## Sources

- Gathin (@gathint), original post, 17 Oct 2026, 33k likes: https://x.com/gathint/status/2111379569030939102
- Follow-up with the repo link: https://x.com/gathint/status/2111379571744657874
- Repo, renamed on 19 Oct from tv-vibehack to **cleanyourtv** (old links redirect): https://github.com/Gathin23/cleanyourtv
  - Prompt: https://github.com/Gathin23/cleanyourtv/blob/main/PROMPT.md
  - Troubleshooting: https://github.com/Gathin23/cleanyourtv/blob/main/docs/TROUBLESHOOTING.md
  - Setting up a TV in another home (Tailscale): https://github.com/Gathin23/cleanyourtv/blob/main/docs/REMOTE.md
  - Sony lists: `examples/sony-*` (22 models). Google TV ones: sony-bravia-4k-vh2 (KD-55X80J), sony-bravia-4k-vh21 (KD-65X85K), sony-bravia-4k-vh21-eu (XR-55A80K), sony-xr-65a80j, sony-kd-55x85j, sony-kd-65x80j, sony-bravia-ae2, sony-bravia-9-ii, sony-bravia-bf1, sony-bravia-vu31
- "48 hours later" post plus the site: https://x.com/gathint/status/2112182577947926920 , https://cleanyour.tv
- Amol Tangade: https://x.com/amoltangade/status/2112113132466540685
- Harshit Satija: https://x.com/harshitsatija/status/2111731520641896945
- Ryan Doyle (@doooyle), where the trend started on 16 Oct: https://x.com/doooyle/status/2111196679680540724

## 1. What "vibehack" actually is

It is a **prompt plus a toolkit**. You paste `PROMPT.md` into Claude Code, Codex or Gemini CLI on a computer on the same Wi-Fi as the TV and type in the TV's model. The assistant then runs `adb` / `pm` itself. If the repo is cloned, it reuses `tools/` and `launcher/` and only edits `config.xml`. The same steps also run by hand with no AI involved (`tools/disable.sh`, `restore.sh`, `launcher/build-and-install.sh`, with a PowerShell version of each).

How PROMPT.md is laid out (paraphrased):
- **Header:** "I want to debloat my Android TV and replace its launcher… My TV model is: <MODEL>. Work on the real device, step by step, verify everything with screenshots pulled from the TV. Ask me before anything that depends on my preferences."
- **Connect:** find the TV, use ADB on port 5555. If that port is closed, use Wireless debugging (pair, connect, then `adb tcpip 5555`). Use a Tailscale address for a TV in another home. If `adb install` hangs on Android 14, push the APK and run `pm install -r`.
- **Back up first:** save the package list, the disabled list, `getprop` and every setting, and write a restore script. At the end, switch network ADB off and confirm the port is closed.
- **Debloat:** sort the packages into categories. Use `pm disable-user --user 0` and never uninstall. Never disable TV input/HDMI/tuner, the remote/Bluetooth, the keyboard, the Play Store or Play Services. Check unclear packages with `dumpsys package` and don't launch them. Ask with a checklist before touching streaming apps, voice, Chromecast, Miracast or updates. Run one `pm` command per shell call, in small batches, with a screenshot after each. Reboot and compare against `pm list packages -d`. AdGuard Private DNS is offered as an optional extra.
- **Launcher:** build a small native Java launcher (AndroidX RecyclerView). Declare `<queries>` for LEANBACK_LAUNCHER on Android 11+, or the app grid comes up empty. Set it as Home, confirm with `mFocusedApp`, and handle setupwraith. Apple TV-style design spec.
- **Verify:** inject key presses, take screenshots, check `wm size`/`wm density`, and write up the restore and build scripts plus a README.

The reference launcher is `com.gathin.tvhome`: **plain Java**, about 429 KB, minSdk 26, targetSdk 34, no network permission, no background services. It has optional accessibility services that restore the remote buttons launcherx used to handle (Input, YouTube, gear). The repo ships no prebuilt APK on purpose: you build it with JDK 17 and Android SDK 34.

## 2. Exact workflow for a Google TV Sony

### On the TV
1. Settings > System > About > **"Android TV OS build"**, press OK 7 times. The Sony BRAVIA 9 II list notes that "Android TV OS version" only shows a logo, so use the *build* row. On older Android TV the path is Settings > Device Preferences > About > Build.
2. Back > System > Developer options > **USB debugging** ON.
3. On Sony Google TV, **USB debugging alone leaves port 5555 closed** (confirmed on the BRAVIA 9 II). Turn on **Wireless debugging** too, then open "Pair device with pairing code".

### On the computer
```bash
adb mdns services                      # or: dns-sd -B _adb-tls-pairing._tcp ; shows the pairing ip:port
adb pair <tv-ip>:<pair-port> <6-digit-code>
adb connect <tv-ip>:<connect-port>     # the port shown on the Wireless debugging screen (not the pairing port)
adb tcpip 5555                         # optional: plain 5555 until next reboot
adb connect <tv-ip>:5555
```
Accept "Allow USB debugging?" on the TV. Android turns Wireless debugging off whenever Wi-Fi drops; switching it back on reconnects without a new code.

### Back up first
```bash
adb shell pm list packages -f > pkgs.txt
adb shell pm list packages -d > disabled-before.txt
adb shell getprop > getprop.txt
adb shell settings list global > s-global.txt; adb shell settings list secure > s-secure.txt; adb shell settings list system > s-system.txt
adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME   # who owns Home now
adb shell dumpsys wifi | grep -o 'cname=[^ ]*'      # who owns the saved Wi-Fi network (see setupwraith below)
adb shell wm size; adb shell wm density; adb shell settings get secure display_density_forced
```

### Debloat (one package per call, small batches, screenshot between)
```bash
adb shell pm disable-user --user 0 <pkg>
adb shell pm list packages -d                     # trust this, not the exit code
adb exec-out screencap -p > shot.png              # comes back empty on Live TV/HDMI/Netflix: press Home first
```
The repo deliberately avoids `pm uninstall -k --user 0 <pkg>`. It also works without root, and the undo is `cmd package install-existing <pkg>`. Disabled packages stay re-enableable from the TV's own Settings > Apps, while an uninstalled-for-user package does not show up there.

### Install the launcher and take over Home
```bash
adb push app.apk /data/local/tmp/l.apk && adb shell pm install -r /data/local/tmp/l.apk
adb shell am start -W -n com.example.launcher/.MainActivity      # prove it starts before touching the stock one
adb shell cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME
adb shell cmd package set-home-activity --user 0 com.example.launcher/.MainActivity
adb shell pm disable-user --user 0 com.google.android.apps.tv.launcherx          # only AFTER the new one works
adb shell pm disable-user --user 0 com.google.android.tungsten.setupwraith       # see warnings
adb shell input keyevent KEYCODE_HOME
adb shell dumpsys activity activities | grep mFocusedApp                         # ground truth for "Home works"
```
Why setupwraith matters: on Google TV the setup wizard `com.google.android.tungsten.setupwraith` also answers HOME (`.MainActivity` at priority 4, `.RecoveryActivity` at priority 1). With launcherx disabled it grabs Home. On some builds `set-home-activity` prints Success but changes nothing, the shell cannot disable just that one component, and on one Xiaomi system_server crash-looped every ~200 ms. Disabling the **whole setupwraith package** is the fix. On the Sony VH2 list, launcherx could even stay enabled once setupwraith was off, because Home already went to the new launcher.

### Optional extras
```bash
adb shell settings put global private_dns_specifier dns.adguard-dns.com
adb shell settings put global private_dns_mode hostname       # undo: private_dns_mode opportunistic ; does NOT block YouTube ads
adb shell settings put global window_animation_scale 0.5; adb shell settings put global transition_animation_scale 0.5; adb shell settings put global animator_duration_scale 0.5
adb shell pm trim-caches 999G                                   # VH21 list: /data 81% -> 65%
adb shell settings put secure screensaver_components <pkg>/.ClockDream; adb shell settings put secure screensaver_enabled 1
```

### Reverse
```bash
adb shell pm enable --user 0 <pkg>                       # undo disable-user
adb shell cmd package install-existing <pkg>             # undo uninstall --user 0
adb shell pm enable --user 0 com.google.android.apps.tv.launcherx
adb shell pm enable --user 0 com.google.android.tungsten.setupwraith   # ALWAYS before a factory reset
adb shell cmd package set-home-activity --user 0 com.google.android.apps.tv.launcherx/.home.HomeActivity
# repo: TV_HOST=<ip> tools/restore.sh examples/<tv>/debloat.txt com.google.android.apps.tv.launcherx
```
Stuck in a Home crash loop: `pm enable --user 0 com.google.android.apps.tv.launcherx`.

### Close up afterwards
Switch off USB debugging and Wireless/Network debugging, revoke the authorisations, reboot, and confirm 5555 refuses connections. The launcher keeps working without debugging.

## 3. Sony Google TV package guidance (from the 4 Google TV Sony lists)

**Disabled in every Sony Google TV list (safe):**
- ACR viewing tracker: `tv.samba.ssm`, `tv.samba.ssm.ui` (Samba TV fingerprints what is on screen)
- Telemetry: `com.qterics.da.product`, `com.sony.dtv.da.service`, `com.sonyericsson.idd.agent`, `com.sony.dtv.sonybugreportsys`, `com.google.android.feedback`, `com.sony.dtv.usercontext`
- Promos and ad rows: `com.sony.dtv.promos`, `com.sony.dtv.sonyselect`, `com.sony.dtv.sonytab`, `com.sony.dtv.launcherxcustomizer`, `android.autoinstalls.config.sony.bravia`
- Retail demo: `com.sony.dtv.demosupport`, `com.sony.dtv.demosystemsupport`, `com.sony.dtv.multiscreendemo`
- Help and preloads: `com.sony.dtv.customersupport`, `com.sony.dtv.smarthelp`, `com.google.android.youtube.tvmusic`, `com.google.android.play.games`, `com.vewd.core.*`, `com.apple.atve.sony.appletv`, regional broadcaster apps
- Hotel/pro mode (XR-65A80J): `com.sony.dtv.b2b.hotelmode`, `com.sony.dtv.b2b.noderuntime*`
- Setup leftovers: `com.google.android.partnersetup`, `com.google.android.onetimeinitializer`, `com.sony.dtv.QuickSetupCustomizer`, `com.android.printspooler`
- BRAVIA CAM, only if you don't own one: `com.sony.dtv.gestureapp`, `com.sony.dtv.distancealert`, `com.sony.dtv.sensingcamera.*`; `com.sony.dtv.notificationcenter`
- `com.google.android.tungsten.setupwraith`, only after the new launcher is running

**Optional, off only by owner's choice (each costs a feature):**
- `com.google.android.katniss`, `com.sony.dtv.voicesearch`, `com.sony.dtv.assistantadapter`: voice and the mic button stop working
- `com.google.android.apps.mediashell`: Chromecast stops working
- `com.sony.dtv.airplayapp`, `com.sony.dtv.homekit`: AirPlay and HomeKit
- `com.sony.huey.dlna.*`, `com.sonyericsson.dlna`: DLNA
- `com.sony.dtv.hbbtvplayer`: HbbTV red button
- `com.uei.quicksetsdk.sony`: IR control of cable boxes and soundbars. HDMI-CEC is unaffected, but on the BRAVIA 9 II it is the IR blaster, so keep it there
- `com.google.android.tts`: TalkBack and read-aloud stop
- `com.sony.dtv.seeds.iot`: BRAVIA Connect phone app and remote start
- `com.google.android.videos`: lose access to purchases made in it
- Together the VH21 always-on services freed about 120 MB on a 3 GB set that was swapping

**Never disable (breaks HDMI, tuner, remote or updates):**
- `com.sony.dtv.tvinput.*` and `com.sony.dtv.tvx` / `com.sony.dtv.tvlin` (Live TV and the input player)
- `com.sony.dtv.tvapi`, `com.sony.dtv.sonysystemservice`, `com.sony.dtv.sonyvendorservice` (routes the Netflix/YouTube/Prime/Disney+ remote buttons)
- `com.sony.dtv.braviasync*` (CEC), HomeTheatreControl, audiooutput, `com.dolby.android.audio.service` (eARC)
- imeproxy, settingsprovider, systemupdate/update
- **every `com.mediatek.*`** (`com.mediatek.external` handles the HDMI inputs, `com.mediatek.tis` analog) and mtktvapi.agent
- the keyboard, the Play Store and Play Services
- The lists also leave alone, on purpose: `com.sony.dtv.webapi.core` (Sony IP Control: Home Assistant and IP remotes report the TV as off without it), `interactivetvutil` (holds a TokenProvider), `com.sony.dtv.b2b.vendorprotocol`/softap on some sets, and fingerprinterserver/lastaccess/crashlogcollector (purpose unclear)

## 4. Sony-specific gotchas

- Port 5555 stays closed with USB debugging alone, so you need the Wireless-debugging pairing flow (above).
- **The Wi-Fi network vanishes when setupwraith is disabled** (BRAVIA 9 II, plus Philips, Skyworth and Xiaomi on Google TV 14). If Wi-Fi was joined during first setup, setupwraith owns that network and Android deletes it the moment setupwraith is disabled. The TV goes offline and ADB goes with it. Check `dumpsys wifi | grep -o 'cname=[^ ]*'` first. If it names setupwraith, forget the network and re-join it in Settings (it then belongs to android.uid.system), or use Ethernet. This matters at a parents' house: someone has to re-join Wi-Fi with the remote.
- On Google's own Chromecast and Streamer, disabling setupwraith also breaks casting ("Untrusted device"), because the cast credentials provider lives inside it. No Sony report of this so far, but test casting from a phone after disabling it.
- **Input button:** it opens Sony's own system overlay without launcherx, so the input-key service is not needed.
- **App buttons:** the Netflix/YouTube/Prime/Disney+ buttons are routed by `sonyvendorservice` and keep working. YouTube, Prime and Disney+ all send keycode 196, so remapping one needs scancodes (485/490/491). The **gear/Settings** button (KEYCODE_SETTINGS) goes dead once launcherx is off; the repo's HomeKeyService brings it back.
- **Voice/Gemini** keeps working without launcherx (the ASSISTANT role resolves to katniss). Only the Gemini *tab* is lost. "Microphone is blocked" means the BRAVIA 9 II's hardware mic switch, not the debloat.
- **Live TV tile:** set `live_tv_package` to `com.sony.dtv.tvx` (or `tvlin` on newer sets). Its VIEW filter matches MIME type `vnd.android.cursor.item/channel` only.
- **The UI looks huge after a reboot** (MediaTek Sony on Android 14, China firmware): the density came back as 640 instead of 320. Fix with `wm density 320` plus `settings --user 0 put secure display_density_forced 320`, then reboot. Record the original values first.
- **Play Protect blocks an APK that targets SDK under 30** ("built for an older version of Android"). Target 34.
- **Firmware updates** re-enable the listed packages and hand Home back to launcherx. Run `tools/check.py --fix`. Many lists disable the updater, but the Sony lists mostly keep it.
- **Sony IP Control / REST API** (`com.sony.dtv.webapi.core`) is a parallel control path: Home Assistant's Bravia integration, and power, inputs and app launch over HTTP with a pre-shared key. It is not a debloat route, but it is a reason not to disable webapi, and it is an alternative to ADB for intent-style control (an inference; nobody in these sources used it that way).
- Sony owners in the threads report success: "new life for my 2018 Sony", "boots ~2x faster" (@SauravSan007, Sony Bravia), and @rajupp's Bravia went from 10+ minutes to usable after reboot to fast (TechPP write-up).

## 5. Failures and practical tips from replies

- "Stuck on boot animation" (@shashamura18). Another user is stuck on the Google TV logo after a power cycle (reply under Amol's post). Most likely cause: the stock launcher was disabled before a working replacement, or setupwraith took Home. Recovery: `pm enable` launcherx, or Settings > Apps if the UI still comes up.
- Amol's first attempt, with Gemini, **bricked** his TV. ChatGPT got it back, and Opus then did the build. That argues for the repo's guarded scripts over a free-form agent.
- Some models refuse. @UltraLinx said Claude refused to remap the Home button and DeepSeek/opencode did it; other users hit safety refusals when they mentioned "ad removal". Framing it as "my own TV, reversible debloat" plus the repo's prompt usually works.
- OTA updates undo the changes, so re-apply or keep the updater off (@Athaxv05).
- Some ISP/carrier boxes remove the Developer options toggles entirely, and then nothing works. A password-locked Build row can sometimes be bypassed with Activity Launcher opening `com.android.tv.settings/.system.development.DevelopmentActivity`.
- Zero-risk alternative: Google TV's built-in **Apps only mode** (Settings > Accounts & Sign In > your account > Apps only mode). It kills recommendations without ADB but keeps the launcher.
- Play Store app updates keep working after the debloat (gathint).
- Fire TV can't replace Home; people use a screensaver/daydream app, or watch for Amazon's home screen and override it. Not relevant to Sony.

## 6. Alternative launchers and tools mentioned

- **Projectivy Launcher** (Play Store): the most-cited off-the-shelf choice. Codex was told "make Projectivy the default launcher" (@spsxj). "Free My TV" keeps Projectivy as a fallback.
- Other open-source launchers people built: Matinee TV Launcher (@yigitech, Play Store and GitHub), Plume Launcher (0.4 MB, ~50 MB RAM), teja2495's Google TV Streamer launcher (Continue Watching + Apps), Aerial TV, Cosy Home/Cosy TV (used on the XR-65A80J), afnon (prayer times), orchard-tv (Fire TV), justatv.eu. SHOWCASE.md in the repo lists about 36.
- Apps in docks: SmartTube (ad-free YouTube), Stremio, OTT Navigator, Wholphin. Stremio needs `cmd appops set com.stremio.one RUN_ANY_IN_BACKGROUND ignore; cmd appops write-settings`, or its streams fail after boot.
- DNS: AdGuard DNS via Private DNS, or Pi-hole. Neither blocks YouTube ads.
- FLauncher, barehome, ATV Launcher, Wolf Launcher and TDUK did not come up in these threads. They are known Android TV alternatives (FLauncher is open source; Wolf is popular for Google TV), but I have no source-backed notes on them here.

## 7. Amol Tangade's build

- His words: "just ADB commands over the local network with Claude doing most of the heavy lifting". He disabled 40+ apps and built a **custom Java launcher** with GitHub stats, weather and a pixel mascot that reacts to the remote, using about 65 MB RAM.
- It is the **same repo as gathint** (cleanyourtv's Java launcher), with Claude asked to add his GitHub contributions graph and a Claude mascot. So it is a native Java APK built with Gradle, not Kotlin/Compose and not a WebView.
- Cost: $0. He used Claude Opus through a GitHub Copilot plan. His first try with Gemini bricked the TV and ChatGPT recovered it.
- Stremio tip: download the right-architecture APK from stremio.com > other downloads, then `adb install`.

## 8. Harshit Satija's intent model

- Liquid AI's **d1-3B decision model** runs on a home server (a docked ROG Ally with 24 GB shared memory), with a fallback LLM. Nothing new runs on the TV.
- You speak or type an intent. The model picks the content type, the app (prompted with examples and his app preferences, e.g. Stremio, Netflix) and **the ADB command**. The local machine then sends it over the LAN. Prompt-to-command takes about 600 ms; the TV's own app load time is now the bottleneck.
- He did not publish code or the exact commands. The usual primitives are `adb shell am start -a android.intent.action.VIEW -d <deep link> <pkg>`, `monkey -p <pkg> 1` / `am start -n` to launch, and `input keyevent` / `input text` to navigate or search (an inference).
- Replies raise real limits: Netflix blocks screenshots, so the agent can't see app state (@HyCe). Profile pickers, subtitles and audio are hard to drive. Key-press sequences break when apps update, while **deep links survive longer** (@jeffbruchado). Check which app is in the foreground (`dumpsys activity activities | grep topResumedActivity`) before sending input (@AxleMode).

## 9. Recommended plan for the parents' Sony

1. Write down the exact model, for example KD-55X80J or XR-65A80K. Clone cleanyourtv and pick the closest `examples/sony-*` list (VH2/VH21 for 2021–22, AE2/AE3 for 2025–26).
2. At their house, or over Tailscale using docs/REMOTE.md: install Tailscale on the TV from the Play Store and share it into your tailnet. Never port-forward 5555.
3. Before disabling setupwraith, re-join Wi-Fi in Settings (or use Ethernet) so the network belongs to android.uid.system.
4. Keep voice, Chromecast, updates and webapi enabled for parents.
5. Run `tools/disable.sh <list>`, then `launcher/build-and-install.sh` (on Windows, use the `.ps1` versions with `-TvHost`). Apply the list again so setupwraith is disabled once the new launcher owns Home.
6. Have them press every remote button. Remap the gear button with HOME_KEY_SERVICE=1.
7. Close ADB. Leave `restore.sh <list> com.google.android.apps.tv.launcherx` written down for later.
