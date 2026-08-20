# DGX Spark Automatic Power Recovery Research

_Official NVIDIA documentation review completed on 2026-08-20. No DGX Spark configuration was changed._

## Bottom Line

DGX Spark is designed to power on automatically when input power is applied. In NVIDIA's UEFI manual, the relevant setting is **Advanced → Power On Behavior → After Power Loss Behavior → `Auto Boot`**. NVIDIA documents `Auto Boot` as the default; the only alternative is `Power Button Press`. NVIDIA's current first-boot guide independently says that Spark starts immediately when power is applied. [NVIDIA DGX Spark UEFI Advanced tab](https://docs.nvidia.com/dgx/dgx-spark-uefi/advanced-tab.html#power-on-behavior), [NVIDIA DGX Spark first-boot guide](https://docs.nvidia.com/dgx/dgx-spark/first-boot.html#get-ready)

This firmware setting restores the **computer**, not necessarily every application. Hermes, LiteLLM, vLLM, LM Studio, Docker containers, and any other workloads still need their own operating-system or container restart configuration. Hardware auto-boot and process auto-recovery should therefore be tested as two separate layers.

## Exact NVIDIA-Documented Setting

1. Attach a display and a keyboard physically to the DGX Spark.
2. Power on or restart the Spark, then immediately press and hold `Esc` or `Del` until UEFI opens. NVIDIA says the key timing is critical and that UEFI access requires a physically connected keyboard. [NVIDIA DGX Spark UEFI access](https://docs.nvidia.com/dgx/dgx-spark/uefi-settings.html#access-uefi)
3. Open **Advanced**.
4. Select **Power On Behavior**.
5. Confirm **After Power Loss Behavior** is set to **`Auto Boot`**.
6. Open **Save & Exit** and choose **Save Changes and Exit** if a change was made. [NVIDIA DGX Spark UEFI Advanced tab](https://docs.nvidia.com/dgx/dgx-spark-uefi/advanced-tab.html#power-on-behavior), [NVIDIA DGX Spark UEFI Save & Exit tab](https://docs.nvidia.com/dgx/dgx-spark-uefi/save-exit-tab.html#save-options)

NVIDIA also documents this operating-system command as a way to reboot directly into the UEFI interface:

```bash
sudo systemctl reboot --firmware-setup
```

This command only enters UEFI; NVIDIA does not document an operating-system command that reads or changes `After Power Loss Behavior`. A local display and keyboard are still needed to inspect and edit the setting. [NVIDIA DGX Spark support guide](https://docs.nvidia.com/dgx/dgx-spark/support.html#before-running)

## Documented Default And Current Firmware Context

| Item | NVIDIA documentation |
|---|---|
| Default after-power-loss behavior | `Auto Boot` |
| Alternative | `Power Button Press` |
| Expected result when power is applied | Spark starts immediately |
| Current Founders Edition UEFI listed by NVIDIA | `1.110.13` |

The firmware version above is the current value in NVIDIA's release notes reviewed on 2026-08-20. NVIDIA cautions that this version table applies only to the **DGX Spark Founders Edition**; partner GB10 systems can receive updates on a different schedule. [NVIDIA DGX Spark release notes](https://docs.nvidia.com/dgx/dgx-spark/release-notes.html#current-software-versions)

## Safe Test Plan

1. First verify that no DGX OS, UEFI, or firmware update is in progress. NVIDIA warns that interrupting initial installation can damage the system and requires a stable power source for system or firmware updates. [NVIDIA DGX Spark first-boot warning](https://docs.nvidia.com/dgx/dgx-spark/first-boot.html#run-the-first-time-setup), [NVIDIA DGX Spark OS and component update guide](https://docs.nvidia.com/dgx/dgx-spark/os-and-component-update.html#using-dgx-dashboard-for-updates)
2. Before simulating a failure, capture the running services and make their restart policies durable. An AC-return test cannot prove process recovery unless this layer is configured first.
3. Confirm the live UEFI value is `Auto Boot`. Because it is the documented default, no change should be necessary unless this Spark was previously altered or had settings reset.
4. For the first test, perform a normal operating-system shutdown, wait until the Spark is fully off, remove input power, and then restore input power. This safely verifies the cold AC-application behavior without intentionally corrupting open writes.
5. After that passes, perform one controlled UPS-outlet test only when important work is stopped and storage activity is quiet. Restore the UPS outlet and observe whether the Spark reaches DGX OS without a power-button press.
6. Verify recovery in layers: Spark booted, network returned, NVIDIA Sync or SSH works, each required service is active, each expected API is healthy, and the correct model/routing identity is present.

NVIDIA does not publish a Spark-specific destructive power-failure test procedure, minimum outage duration, UPS sequencing requirement, or guarantee that arbitrary user processes will restart. The controlled test steps above are therefore an operational test design, not an NVIDIA-prescribed certification procedure.

## Decision

- Keep **After Power Loss Behavior = `Auto Boot`**.
- Do not change firmware merely to obtain the documented default; inspect it first.
- Treat UEFI auto-boot as the foundation, then separately configure and test system services and containers for reboot recovery.
- Do not pull power while an OS or firmware update is active.

## Primary Sources

- [NVIDIA DGX Spark UEFI User Guide — Advanced Tab](https://docs.nvidia.com/dgx/dgx-spark-uefi/advanced-tab.html)
- [NVIDIA DGX Spark User Guide — UEFI Settings](https://docs.nvidia.com/dgx/dgx-spark/uefi-settings.html)
- [NVIDIA DGX Spark UEFI User Guide — Save & Exit Tab](https://docs.nvidia.com/dgx/dgx-spark-uefi/save-exit-tab.html)
- [NVIDIA DGX Spark User Guide — Initial Setup and First Boot](https://docs.nvidia.com/dgx/dgx-spark/first-boot.html)
- [NVIDIA DGX Spark User Guide — Release Notes](https://docs.nvidia.com/dgx/dgx-spark/release-notes.html)
- [NVIDIA DGX Spark User Guide — OS and Component Update Guide](https://docs.nvidia.com/dgx/dgx-spark/os-and-component-update.html)
- [NVIDIA DGX Spark User Guide — Support](https://docs.nvidia.com/dgx/dgx-spark/support.html)

Related: [[DGX Spark Operations Setup Guide]] | [[Always-On Hermes on DGX Spark]] | [[Local Setup Index]]
