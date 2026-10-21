# Remote ADB for Fire TV (home) + Sony Google TV (parents) — research notes (2026-10-21)

Marked [src] = stated by a source; [infer] = my inference, not confirmed by a source.

## 1. Same-network requirement and enable steps

- ADB over the network is plain TCP. The docs say "same network", but what is actually required is that the host can reach the TV's IP:port. A tailnet or subnet route meets that [infer]. Google: "Ensure that your workstation and device are connected to the same wireless network" [src]. Amazon: the computer and Fire TV must be on the same network [src].
- **Fire TV (Fire OS 7/8)** [src, Amazon]:
  1. Settings > My Fire TV > About. If Developer Options is hidden, select the device name and press the center/OK button 7 times.
  2. Developer Options: turn on **ADB Debugging** and **Apps from Unknown Sources**.
  3. Get the IP from My Fire TV > About > Network.
  4. Run `adb connect <ip>:5555`. The TV shows "Allow USB debugging?". Tick **Always allow from this computer**, then OK.
  - Fire TV listens on 5555 as soon as the toggle is on; no USB step is needed.
  - https://developer.amazon.com/docs/fire-tv/connecting-adb-to-device.html
- **Fire TV Stick 4K Select (2025) runs Vega OS, not Android.** It has no ADB Debugging toggle and does not run APKs, so none of this applies to it. Tailscale is also not supported on it [src]. Check the model first.
  - https://developer.amazon.com/docs/vega/0.24/developer-mode.html
  - https://tailscale.com/kb/1394/install-amazon-fire
- **Sony Google TV** [src, Sony Pro FAQ and guides]:
  1. Settings > System > About > Android TV OS build. Press OK 7 times.
  2. Settings > System > Developer options > Debugging: turn on **ADB debugging**. Some builds call it "Network debugging".
  3. Run `adb connect <ip>:5555` and accept the RSA prompt.
  4. If the connection is refused, toggle ADB debugging off and on again.
  - Google's pairing-code "Wireless debugging" needs Android 13+ on TV [src]. Most Bravia Google TVs run Android TV 10/12, so expect the classic 5555 toggle [infer].
  - If the TV only offers Wireless debugging: the pairing port and the connect port are random, and auto-connect uses mDNS, which does not cross a tailnet [infer]. Use explicit `adb pair ip:port` and `adb connect ip:port`. Once connected, `adb tcpip 5555` pins the port until the next reboot.
  - https://developer.android.com/tools/adb
  - https://pro-bravia.sony.net/faq/59/
  - https://anexplorer.io/devmode/android/tv

## 2. Phone only, no PC

- **Termux** (install from F-Droid or GitHub, not Play): `pkg install android-tools` gives real `adb`, which can `adb connect tv-ip:5555` [src, community]. A known failure is "cannot connect to daemon ... Not a data message"; the fix is `adb kill-server` and retry.
  - Termux also runs `pkg install nodejs python git`, so you can clone a repo and run scripts that shell out to `adb` [infer, standard Termux packages].
  - https://github.com/termux/termux-packages/issues/7946
  - https://forum.f-droid.org/t/how-to-use-adb-in-termux-without-root/33885
- **LADB** debugs only the phone itself, through self wireless debugging, so it cannot target a TV [infer from the app's design]. https://github.com/sekedus/ladb
- GUI clients that connect to a remote IP: Bugjaeger, Remote ADB Shell, Easy Fire Tools (Fire TV oriented, can uninstall and sideload APKs). Not re-verified in this pass, so treat them as convenience tools. Termux is the scriptable, reliable path.
- TV side: the Downloader app (AFTVnews) sideloads APKs from a URL. No TV-side helper is needed for ADB itself.

## 3. Remote access (parents' house)

- **Tailscale on Fire TV:** official listing in the Amazon Appstore covering most post-2018 Fire TVs, except the 4K Select. Sign-in is by QR code [src]. https://tailscale.com/kb/1394/install-amazon-fire
- **Tailscale on Android TV / Google TV:** yes. The KB says the client works on Android 8+, "including Android TV" [src]. https://tailscale.com/kb/1079/install-android
  - The Android TV app has offered a **subnet router** setting since 1.80.0. After turning it on you approve the route in the admin console [src, community].
  - Routing can be flaky without root; the suggested fallback is running the subnet router on the home router [src, forum].
  - https://blog.lon.tv/2026/09/13/i-turned-my-onn-tv-box-into-a-vpn-router-with-tailscale/
  - https://forum.tailscale.com/t/access-my-tailscale-network-from-a-subnets-host/678
- **Options, best first:**
  - (b) Tailscale on the Sony TV itself, then `adb connect 100.x.y.z:5555` from the desktop. This should work because adbd listens on all interfaces. No source confirms it on a TV specifically [infer]. Simplest option.
  - (a) Tailscale subnet router on an always-on device at the parents' house (a Pi, the router, or the TV app's subnet feature). Then use the TV's LAN IP from the desktop.
  - (c) **Never port-forward 5555.** ADB gives full shell access, and open 5555 is mass-scanned and exploited by ADB botnets (ADB.Miner, Trinity, Fbot). The RSA prompt is the only guard, and older or patched-off builds have none [infer, well-known].
- **Someone has to be at the TV once, in any setup.** The RSA dialog requires someone to "unlock the device and acknowledge the dialog" [src, Google]. With "Always allow" ticked, the key persists, so it is needed once per host key. Plan for a parent to press OK while you are on a call.
  - Tailscale sign-in on the TV (QR code) and any Wireless debugging pairing code also need someone in person.
  - Revoking authorizations, a factory reset, or a new adbkey on the desktop brings the prompt back. Back up `%USERPROFILE%\.android\adbkey`.

## 4. Driving it from a phone chat

- Claude Code **Remote Control** connects the Claude mobile app or claude.ai/code to a Claude Code session running on your own machine. "Claude keeps running locally the entire time", so local tools like `adb` run on the desktop [src].
  - Start it with `claude remote-control` (server mode), `claude --remote-control`, or `/remote-control` (`/rc`) inside a session. A QR code on the desktop opens the session on the phone.
  - Requires a Pro, Max, Team or Enterprise plan with a claude.ai login (no API keys). It reconnects after sleep or network drops.
  - https://code.claude.com/docs/en/remote-control
- Resulting chain: phone (Claude app) > Remote Control > desktop Claude Code > `adb connect` to the Fire TV (LAN) and to the Sony TV (tailnet IP). The phone needs no Tailscale or ADB of its own.

## 5. Launcher caveats

- **Fire TV:** Amazon actively blocks home-button replacement [src, AFTVnews].
  - Older methods (Launcher Manager logcat or accessibility interception) failed on Fire OS 8.1.6.6. Projectivy's own native override setting worked there [src, itechguides].
  - The "System User" exploit (Launcher Manager System User Edition, run over ADB) does not survive a reboot, and builds such as PS7706 and RS8153 are reported patched [src, community].
  - Fallbacks: a remote button remapper, or keep the custom launcher as an app.
  - Disabling the Amazon launcher (`pm disable-user`) tends to break the device or get reverted. Prefer debloating ads and telemetry packages only.
  - https://www.aftvnews.com/new-method-to-use-custom-launchers-on-fire-tvs-can-disable-amazons-app-blacklist/
  - https://www.itechguides.com/?p=354644
  - https://liliputing.com/?p=180187
- **Google TV / Sony:**
  - Install the replacement launcher and make it default **before** disabling `com.google.android.apps.tv.launcherx`. The wrong order gives a black screen or soft brick. Recover with `pm enable` over ADB, or Sony Safe mode.
  - One Sony user needed to enable accessibility for the launcher before its home override worked [src, Sony community].
  - Early-2026 reports say a Google TV or TCL firmware update stopped Projectivy's override. Re-granting the override permission fixed it for some users [src].
  - https://www.androidauthority.com/google-tv-update-blocks-projectivy-override-3649445
  - https://community.sony.pl/t5/android-tv/totally-disable-and-remove-google-from-my-bravia-tv/m-p/3952604
  - Lowest-risk option for parents: **Apps only mode** (profile > Settings > Accounts & Sign In > account > Apps only mode). It removes recommendations, but disables Assistant and search, a sponsored row remains, and you must turn it off to install apps [src]. https://www.howtogeek.com/695447/how-to-disable-recommendations-on-google-tv/
