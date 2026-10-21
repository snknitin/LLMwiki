# Debloating an Amazon Fire TV Stick over ADB (research, 2026-10-21)

Target: a Fire TV Stick plugged into an old Sanyo TV. The TV doesn't matter. All the work happens on the stick, over Wi-Fi ADB.

Sources (read in full: both repos at HEAD, all open issues and PRs, the X threads and their replies):
- dumbtv: https://github.com/humblemuzzu/dumbtv (latest commit 2026-10-19, launcher release v1.1; about 40 community PRs are open and none is merged)
- X: https://x.com/DevMuzzammil/status/2111912547318395338, https://x.com/DevMuzzammil/status/2112227989685768653, the original post https://x.com/DevMuzzammil/status/2111595814099591535
- fire-tv-cleanup: https://github.com/itsmeterrylin/fire-tv-cleanup (fork of https://github.com/Gathin23/tv-vibehack; issues are disabled and there are no PRs)
- X: https://x.com/itsmeterrylin/status/2111851927537606973, https://x.com/itsmeterrylin/status/2111660040629244134, https://x.com/gathint/status/2111379569030939102

---

## 0. Before anything: find out which Fire OS the stick runs

On the stick: Settings > My Fire TV > About > click the device name row 7 times. Developer Options then appears under My Fire TV. Turn on **ADB debugging**. You do not need "Apps from unknown sources", because adb install works without it. Get the IP from Settings > My Fire TV > About > Network.

```sh
adb connect <ip>:5555          # the stick shows "Allow USB debugging?" Tick Always allow, press OK with the remote
adb devices                    # must say "device", not "unauthorized"
adb shell getprop ro.product.model          # e.g. AFTMM, AFTKA, AFTKM, AFTKRT, AFTMA08C15, AFTT
adb shell getprop ro.build.version.sdk      # 22 = Fire OS 5, 25 = Fire OS 6, 28 = Fire OS 7, 30 = Fire OS 8
```

Which stick runs what, from the dumbtv catalog and PRs:
| Stick | Fire OS | What is reported |
|---|---|---|
| Fire TV Stick 2nd gen (AFTT) | 5.2 (sdk 22) | **Almost nothing works.** Every `pm disable-user` is refused with a SecurityException (52 SUSPECT, 0 disabled). No `cmd` binary. Only the settings and the DNS filter worked (issue #42) |
| Fire TV Stick 4K 1st gen (AFTMM, mantis, 2018) | 6.7 (sdk 25) | Fully tested by the maintainer. Debloat, DNS filter and launcher all work. The launcher holds HOME through a "Keeper" service and has to be built from source |
| 4K Max 1st gen (AFTKA) | 7.x (sdk 28) | Catalog PRs #23 and #46 |
| 4K Max 2nd gen (AFTKRT), 4K 2nd gen (AFTKM), 4K Plus (AFTMA08C15) | 8.1.8.x (sdk 30) | Debloat works. The DNS filter needs one manual step in the app. On main, the HOME takeover does **not** work. Unmerged PRs #49 and #31 fix it, and #60/#61 report it working on the 4K Plus |

## 1. dumbtv (humblemuzzu): what it does, step by step

**Platform:** bash scripts (bash 3.2 compatible) plus `adb` plus `curl` on a computer. The README lists "macOS, Linux, Windows via WSL/Git Bash". On Git Bash, MSYS rewrites `/sdcard/...` device paths and the DNS push fails. Unmerged PR #49 fixes this with `MSYS2_ARG_CONV_EXCL`. Workaround: `export MSYS2_ARG_CONV_EXCL="/sdcard;/data;/storage;/system"`, or use WSL. It is not Node, Python or a web tool. It is built to be run by an AI agent: `AGENTS.md` is the contract and `skills/firetv-debloat/SKILL.md` is a skill. The tweet's instruction is literally "point your agent to this repo". Nothing on the TV needs root, and nothing is written to `/system`.

Order: `preflight.sh` → `configure.sh` → `all.sh` (debloat → lockdown → dnsfilter → launcher → optional youtube → verify). Each script takes `--dry-run` and `-y`. The pass reboots the TV twice and takes about 10 minutes.

1. **preflight.sh** is read-only. It prints model, build, sdk and verified-boot state, and saves a one-time snapshot of `settings list secure` and `settings list global` into `report/`. `restore.sh` uses that snapshot, so the snapshot is only taken once.
2. **configure.sh** asks which apps to keep, whether you watch Prime, whether to replace the launcher, whether to install the DNS filter, and whether to replace YouTube (default no). It writes `dumbtv.conf`.
3. **debloat.sh**, for each package in `data/fireos/packages.txt` (Fire OS 7/8) or `data/fireos6/packages.txt` (picked automatically when sdk < 28):
   - On builds that have `cmd package install-existing` (Fire OS 7/8): `pm uninstall -k --user 0 <pkg>`, falling back to `pm disable-user --user 0 <pkg>`
   - On Fire OS 6, which has no install-existing: `pm disable-user --user 0 <pkg>` only
   - Any `PROTECTED` answer ("Cannot disable a protected package") is logged
   - Third-party ad-funded apps (mostly Indian ones: Hotstar, Zee5, JioCinema, SonyLIV, discovery+, Aaj Tak, Twitch, FastScreen, MX Player) are removed with `pm uninstall --user 0`. This deletes the APK from /data, so the only way back is the Appstore
   - Packages that keep running after being disabled: `appops set <pkg> RUN_IN_BACKGROUND ignore`, `appops set <pkg> RUN_ANY_IN_BACKGROUND ignore` (sdk 28 and up), `am force-stop <pkg>`, `cmd netpolicy add restrict-background-blacklist <uid>`
   - Privacy settings (`settings put`), from `data/fireos/settings.txt`:
     ```
     secure amz_limit_ad_tracking 1          secure limit_ad_tracking 1
     secure non_amz_limit_ad_tracking 1      secure advertisingIdApp:interestBasedAds:value 0
     secure USAGE_METRICS_UPLOAD_ENABLED 0   secure usage_metrics_marketing_enabled 0
     secure settingsApp:appUsageData:value 0 secure settingsApp:deviceUsageData:value 0
     secure alexa_wake_word_disabled 1       secure voice_disabled 1
     global heads_up_notifications_enabled 0
     global com.amazon.tv.settings.featured_item_video_enabled 0
     global com.amazon.tv.settings.featured_item_video_volume 0.0
     global window_animation_scale 0.5       global transition_animation_scale 0.5
     # animator_duration_scale is left at 1.0: at 0.5 the Fire OS 8 settings menu becomes unreachable
     ```
   - Reboots, then checks that a home screen comes up.
4. **lockdown.sh**: `cmd netpolicy set restrict-background true` (data saver), then app-ops off, force-stop and a background-data blacklist for each package Amazon refuses to disable (`data/fireos/protected.txt`: `com.amazon.device.metrics`, `device.crashmanager`, `device.rdmapplication`, `ftvads.deeplinking`, `tv.csapp`, `device.software.ota`, `device.software.ota.override`).
5. **dnsfilter.sh**: installs **personalDNSfilter** (F-Droid APK, SHA-pinned) as an on-device local VPN. It builds the blocklist on the PC from the HaGeZi Amazon tracker list plus `data/blocklists/extra-hosts.txt`. When PRIME=1 it strips `aiv-delivery`/`aiv-cdn` so Prime playback keeps working. It runs `appops set dnsfilter.android ACTIVATE_VPN allow` so the phone-sized VPN consent dialog never appears, plus `dumpsys deviceidle whitelist +dnsfilter.android`. It patches the config (`detectDNS=false`, `routeIPs=<gateway>`, `fallbackDNS=router`, no auto-update), pushes the config and `FILTERHOSTS.TXT`, runs `settings put secure always_on_vpn_app dnsfilter.android`, then reboots and self-tests. Blocked hosts include `softwareupdates.amazon.com` (OTA), `arcus*`, `device-metrics-us*`, `unagi-*`, `api.amazonalexa.com`, `amazon-adsystem.com` and `mads.amazon.com`. Hosts deliberately left alone: the app store, YouTube, and launcher artwork.
   - **Fire OS 8:** adb cannot write `/sdcard/Android/data`. The script pushes the list to `/sdcard/Android/media/dnsfilter.android/dumbtv-blocklist.txt` instead. Then you have to do one step by hand in the app: Advanced settings > Configure filter update > add `file://storage/emulated/0/Android/media/dnsfilter.android/dumbtv-blocklist.txt`, untick the others, and reboot.
   - **Simpler option, which the FAQ endorses:** if your router lets you set DNS, use Pi-hole or AdGuard DNS at the router and skip this step. Several replies say the same, and PR #26 skipped the filter for exactly this reason.
6. **launcher.sh / launcher/install.sh** installs "dumbtv home" (`tv.dumbtv.home`, 45 KB, open source, no internet permission). The release APK is SHA-pinned, needs Android 9 or later, and `--build` builds it from source. Fire OS ignores the default-home setting and Amazon's launcher is protected, so the takeover works like this:
   - Fire OS 7/8: `cmd package set-home-activity tv.dumbtv.home/.Home` (ignored, but harmless), `settings put global alarm_manager_constants min_futurity=0` (lets an alarm-fired launch skip Android's 5-second app-switch delay), `settings put secure enabled_accessibility_services tv.dumbtv.home/...Guard`, `settings put secure accessibility_enabled 1`. The Guard watches for Amazon's `HomeActivity_vNext` window and covers it.
   - Fire OS 6: Amazon's A11yAuthorizer refuses third-party accessibility services on 6.7. The launcher uses a foreground "Keeper" service instead, granted with `appops set tv.dumbtv.home GET_USAGE_STATS allow`. It calls `moveTaskToFront`. You have to build it from source with MIN_SDK=25, which needs a JDK and the Android SDK. Unmerged PR #19 would ship a single APK for sdk 25.
   - Amazon's launcher is never disabled. Long-pressing HOME still opens Fire OS's quick menu, and Options > "Open Amazon's home screen" is the escape hatch.
   - The maintainer dropped Projectivy because it is closed source and asks for the ad ID, install-referrer and package install/delete permissions.
7. **youtube.sh** (opt-in only) installs **SmartTube** (`org.smarttube.stable`, SHA-pinned GitHub APK) and runs `pm disable-user --user 0 com.amazon.firetv.youtube`. Use `--remove` to uninstall the stock app instead. The script explains why: YouTube serves ads from the same hosts as the video, so DNS blocking can't remove them. In SmartTube, set "Hide shorts everywhere" and the 1080p vp9 preset, not av01, because the stick has no hardware decoder for it.
8. **verify.sh** checks that the blocked hosts resolve to 127.0.0.1, that YouTube and the Appstore still resolve, that HOME is bound, and counts the disabled packages.

**Packages disabled on Fire OS 7/8** (`data/fireos/packages.txt`, about 65):
- Ads: `com.amazon.tv.acr` (screen fingerprinting), `hybridadidservice`, `shoptv.client`, `sneakpeek`, `minitv.android.app`, `media.recommendations`, `tahoe`, `privacypassservice`, `ftv.screensaver`, `systemnotices`
- Telemetry: `tv.fw.metrics`, `wirelessmetrics.service`, `perfc`, `perfcollection`, `dp.logger`, `logan`, `neo.minerva.logcat`, `ceviche`, `connectivitydiag`, `hedwig`, `tigris`, `spiderpork`, `tv.developer.dataservice`
- Experiments: `ale`, `katoch`, `device_remote_config_sync_service`
- Alexa: `aca`, `alexa.datastore.app`, `alexadirectivebrokerservice`, `alexamediaplayer.runtime.ftv`, `alexa.externalmediaplayer.fireos`, `tv.alexaalerts`, `tv.alexanotifications`, `vizzini.ftvcds`, `firetv.androidskillconnectioncapability`, `audiohome`, `rtcsessioncontroller`
- OTA helpers: `tv.forcedotaupdater.v2`, **`firebat` (this is a bug: firebat is Prime Video, see below)**
- Bloat: `gamehub`, `bueller.music`, `bueller.photos`, `tv.democontent.provider`, `storm.lightning.tutorial`, `tmm.tutorial`, `tv.releasenotes`, `tv.website_launcher`, `tv.support`, `tv.easyupgrade`, `tv.ottssocompanionapp`, `tv.localgallery`, `tv.notificationcenter`, `uxnotification`, `csm.htmlruntime`, `cloud9` (Silk), `spotify.mediabrowserservice`, `wha.mediabrowserservice`, `dummy.*`, `com.android.printspooler`, `bips`, `traceur`, `nfc`

The Fire OS 6 list adds `shoptv.firetv.client`, `mvpdauth`, `amznfuse.operatorredirection`, `aria`, `whad`, `whasettings`, `tv.livetv`, `franktvinput`, `tifobserver` (sticks have no tuner), `imdb.tv.android.app` (Freevee), `imdb.livingroom.firetv`, `wifilocker` (uploads saved Wi-Fi passwords), `whisperjoin.wss.wifiprovisioner`, `tv.ffsprovisioneeclient`, `mediatek.atci.service`, `com.android.dreams.basic`, the ivona/pico TTS packages, and a few others. It keeps `firebat` (Prime) and `ftv.screensaver`.

**Never-disable list**, which the scripts enforce: `com.amazon.tv.launcher`, `firehomestarter`, `tv.settings.v2`, `tv.settings.core`, `tv.inputpreference.service`, `tv.routing`, `tv.devicecontrol(settings)`, `tv.keypolicymanager`, `tv.livetv` (on TVs), `fireinputdevices`, `autopairservice`, `device.bluetoothpa`, `device.blepa`, `whisperjoin.middleware.np`, `whisperplay.service.install`, `tv.oobe`, `tv.ooberesource`, `webview.chromium`, `venezia` (Appstore), **`com.amazon.vizzini`** (if disabled, it draws an undismissable "Unable to Detect Your Remote" window over everything), `systemui`, `packageinstaller`, `permissioncontroller`.

**Reversing it:** `scripts/restore.sh` runs, for each package, `cmd package install-existing <pkg>` (Fire OS 7/8) and `pm enable --user 0 <pkg>`, plus `appops ... allow` and `cmd netpolicy remove restrict-background-blacklist <uid>`. It sets `cmd netpolicy set restrict-background false`, runs `settings delete secure always_on_vpn_app` (and on Fire OS 6 disables dnsfilter), clears `enabled_accessibility_services` and sets `accessibility_enabled 0`, restores `alarm_manager_constants`, puts the snapshotted settings back, and reboots. `launcher/install.sh --undo` hands HOME back to Amazon's launcher. Uninstalled /data apps come back only from the Appstore. A factory reset undoes everything.

## 2. fire-tv-cleanup (itsmeterrylin): what it does

**Platform:** mainly a **prompt** (`PROMPT.md`) for Claude Code or another agent, plus small tools:
- `tools/tv.py` is a pure-Python ADB client (pip `adb-shell`, `rsa`, `cryptography`, in a venv). It exists because macOS Local Network privacy silently blocks Google's `adb` binary ("No route to host"). Modes: `--probe`, `--batch`, `--push`, `--pull`. `tools/b64push.py` pushes APKs as base64 chunks with an md5 check.
- `tools/disable.sh <list>` pipes `pm disable-user --user 0 <pkg>` for each line, one command per shell call, because chained `pm` commands can stop silently after the first. `tools/restore.sh <list> com.amazon.tv.launcher` runs `pm enable`, `cmd package set-home-activity --user 0 <stock>`, and resets the 3 animation scales to 1.0.
- It **never uninstalls**. Everything is `pm disable-user`, so it can be undone from the TV's own settings.

The Fire TV example list is for a Hisense Fire TV Edition, AFTOLCBC82, Fire OS 8. It has only 5 packages: `com.amazon.hybridadidservice`, `com.amazon.kso.blackbird` (sponsored screensaver/lock-screen ads), `com.amazon.shoptv.client`, `com.amazon.device.telemetry.emitter`, `com.amazon.wirelessmetrics.service`. Packages that were refused as protected: `ftvads.deeplinking`, `client.metrics`, `device.metrics`, `device.crashmanager`.

The launcher (`com.gathin.tvhome`) is a tvOS-style dock with a photo screensaver. You build it yourself with JDK 17 and Android SDK 34, and it has **minSdk 26, so it will not install on Fire OS 6 sticks (sdk 25)**. On Fire TV, `build-and-install.sh` runs:
```
pm install -r /data/local/tmp/tvhome.apk
pm grant com.gathin.tvhome android.permission.WRITE_SECURE_SETTINGS
settings put secure enabled_accessibility_services com.gathin.tvhome/com.gathin.tvhome.HomeRedirectService
settings put secure accessibility_enabled 1
settings put secure screensaver_components com.gathin.tvhome/com.gathin.tvhome.PhotoDream
am start -n com.gathin.tvhome/.MainActivity
```
Its HomeRedirectService starts the launcher straight from the accessibility service whenever Amazon's HomeActivity appears, with a 2-second grace period so Settings still opens. Amazon's home flashes briefly before the redirect. Amazon's launcher stays enabled, because disabling it locks you out of Settings. To get Amazon's home back: press Menu on the launcher's Settings button > "Use Amazon Home Screen", or run `settings delete secure enabled_accessibility_services`. The README also says that on that Hisense, "ADB turns off when the TV restarts", so you have to re-enable it in Developer Options.

Verdict: dumbtv is far more complete for a Fire Stick (DNS/OTA blocking, Fire OS 6 and 7 lists, restore with a snapshot). fire-tv-cleanup is a minimal, disable-only, prompt-driven approach.

## 3. Running from a phone instead of a PC

Neither repo documents this. What follows is my inference, not reported by anyone:
- **Manual commands** (the list in section 6) work from any phone ADB-over-network client: LADB, Bugjaeger, or "Remote ADB Shell". This is the realistic phone route.
- **Termux** (`pkg install android-tools bash curl coreutils git`) gives a real `adb` and bash, so `adb connect <ip>:5555` to the stick works. dumbtv's scripts would probably run there, since they only need bash, adb, curl, sha256sum and sed, but nobody has reported trying it. Building the launcher from source (needed on Fire OS 6) is impractical on a phone. The prebuilt APK (Fire OS 7/8) and SmartTube install fine with `adb install`.
- No reply in any thread mentions doing this from a phone. Every report used a laptop with Claude Code, Codex, DeepSeek or Grok.

## 4. Known issues and gotchas (repo issues, PRs, replies)

- **Prime Video breaks on Fire OS 7/8 with dumbtv main.** `com.amazon.firebat` is Prime Video (it owns `pyrocore.IgnitionActivity`), not an OTA helper. Disabling it removes the Prime tile, and verify.sh still passes (PRs #52, #56, #60, all unmerged). **Remove `com.amazon.firebat` from packages.txt before running**, or re-enable it afterwards with `adb shell pm enable --user 0 com.amazon.firebat`. PR #54 (blocking ADM `device-messaging-na.amazon.com` breaks Prime) was closed by its author as a misdiagnosis. The real cause was firebat.
- **Boot hang and factory reset:** disabling `com.amazon.device.messaging` hung a Fire OS (Android 14) Hisense on the boot animation, and only a factory reset fixed it (issue #57). Also avoid `tcomm`, `dha2` and `rdmapplication`. Disable in small batches and reboot after each batch.
- **Fire OS 8 HOME takeover fails on main.** Android 11 blocks the background launch (logcat: "Background activity start ... callingUidHasAnyVisibleWindow: false"). PRs #31 and #49 fix it by launching after the cover overlay has drawn (tested 5 out of 5 on AFTKRT and AFTOLCBC82), but neither is merged. `appops set ... SYSTEM_ALERT_WINDOW allow` does not stick. On newer Fire OS (Android 14, AFTCU9343B), the agent concluded HOME cannot be taken over at all (issue #57). A reply on Fire OS 6.7 (@SpencerFlah): "Amazon blocks the home button redirect, so I'm stuck on the stock launcher". At the time the Keeper wasn't merged; it is now.
- **DNS filter fragility:** never `am force-stop dnsfilter.android`, because DNS silently bypasses the tunnel until a reboot. On Fire OS 7.7.1.7, `AUTOSTART = true` races always-on VPN and DNS bypasses the tunnel, and setting `AUTOSTART = false` fixed it (issue #58). `adb reboot` can lose the ACTIVATE_VPN app-op and `always_on_vpn_app` before they are written to disk. Run `adb shell appops write-settings` before rebooting (issue #15, PR #16). A large list combined with deleting IDX_OUTDATED makes the filter inert. Fire OS 6: `always_on_vpn_app` doesn't persist, and the clock drifts unless SYSTEM_DNS=1.
- **Launcher binding:** any APK update or force-stop of `tv.dumbtv.home` silently drops the accessibility binding. Re-run `launcher.sh`. If HOME shows Amazon's home for about 5 s, `min_futurity=0` was reset by an update.
- **OTA:** an Amazon update re-enables a lot and restores settings. The OTA packages are protected, so DNS-blocking `softwareupdates.amazon.com` and the payload CDNs is the only defence. Re-run the pass after any update or reset. Replies make the same point (@Athaxv05, @koto2992).
- Packages that come back by themselves: `com.amazon.dummy.settings` and `com.android.traceur` re-enable after a reboot on Fire OS 8, and `vizzini` re-enables at every boot on Fire OS 6.
- The protected list differs by build, so trust the `PROTECTED` output, not the file.
- `android.settings.SETTINGS` reopens Amazon's home. Open settings with `adb shell am start -a android.intent.action.MAIN -c android.intent.category.LEANBACK_SETTINGS`.
- The Fire TV full-screen keyboard swallows taps. Use `adb shell input text ...` then KEYCODE_BACK (AFTKM).
- The dumbtv Inputs row can open a Live TV chooser or a channel scan. That only matters on Fire TV Edition TVs, not on a stick (issue #51, PR #33).
- Alexa voice is lost: the mic app `com.amazon.aca` is disabled. Undo with `pm enable --user 0 com.amazon.aca` and `settings put secure alexa_wake_word_disabled 0`.
- "Can I restore?": the author's answer is a factory reset or restore.sh. Fire OS cannot be replaced: the bootloader is locked and `/system` is protected by dm-verity, and `adb root`/`remount`/hosts editing is the brick path.

**Alternatives mentioned:** SmartTube (ad-free YouTube, built into dumbtv); Projectivy Launcher 4.72 (used by the PR #61 owner on a 4K Plus; dumbtv advises against it); Wolf Launcher was not mentioned; AdGuard DNS or Pi-hole at the router; replacing the screensaver instead of the launcher (@xenappblog, old Fire Stick); justatv.eu (a directory of removable preinstalled apps per TV model); mihirgupta0900/tv-home (Android TV only); buying an Nvidia Shield or Apple TV instead.

## 5. Risks, summarized

Low brick risk if you respect the never-disable list and never touch `/system`. The realistic failure is landing on Amazon's home. Real risks: Prime breakage (firebat), the device.messaging boot hang, losing uninstalled apps (they return only from the Appstore), losing Alexa voice, OTA undoing everything, and a factory reset wiping it all.

## 6. Concrete command list for a Fire Stick (manual, disable-only, reversible)

```sh
adb connect <ip>:5555 && adb devices
adb shell getprop ro.build.version.sdk                    # pick the list: 25 -> fireos6, 28/30 -> fireos
adb shell pm list packages > before-packages.txt          # backup
adb shell settings list secure > before-secure.txt; adb shell settings list global > before-global.txt

# disable, one call per package (never uninstall system apps on sdk 25)
for p in com.amazon.tv.acr com.amazon.hybridadidservice com.amazon.shoptv.client com.amazon.sneakpeek \
  com.amazon.media.recommendations com.amazon.tahoe com.amazon.privacypassservice com.amazon.systemnotices \
  com.amazon.tv.fw.metrics com.amazon.wirelessmetrics.service com.amazon.perfcollection com.amazon.dp.logger \
  com.amazon.logan com.amazon.ceviche com.amazon.hedwig com.amazon.spiderpork com.amazon.ale com.amazon.katoch \
  com.amazon.tv.forcedotaupdater.v2 com.amazon.gamehub com.amazon.cloud9 com.amazon.kso.blackbird; do
  adb shell pm disable-user --user 0 $p; done          # "absent"/"protected" answers are fine; NOT firebat, vizzini, device.messaging
# optional Alexa: com.amazon.aca com.amazon.alexa.datastore.app com.amazon.tv.alexaalerts com.amazon.tv.alexanotifications

# privacy settings
adb shell settings put secure limit_ad_tracking 1
adb shell settings put secure amz_limit_ad_tracking 1
adb shell settings put secure USAGE_METRICS_UPLOAD_ENABLED 0
adb shell settings put secure usage_metrics_marketing_enabled 0
adb shell settings put global com.amazon.tv.settings.featured_item_video_enabled 0
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb reboot

# ad-free YouTube
adb install SmartTube_stable_<ver>.apk && adb shell pm disable-user --user 0 com.amazon.firetv.youtube

# undo
adb shell pm enable --user 0 <pkg>        # each package; on sdk 28+ also: adb shell cmd package install-existing <pkg>
adb shell settings delete secure enabled_accessibility_services; adb shell settings put secure accessibility_enabled 0
```
Or the full scripted pass: clone dumbtv, **remove `com.amazon.firebat` from `data/fireos/packages.txt`**, then run `./scripts/preflight.sh && ./scripts/configure.sh && ./scripts/all.sh && ./scripts/verify.sh`, and `./scripts/restore.sh` to undo.
