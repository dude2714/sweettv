# Sweet TV Stopping Point - 2026-07-17

Active naming note:
- This workspace started from a donor APK, but the active standalone fork is Sweet TV.
- Use the `sweettv-*` artifacts and the Sweet TV-named scripts under `apk-work/` for current work.
- Treat legacy-named scripts and APKs in this folder as legacy recovery or experiment history unless explicitly resumed.

## Current state
- The active standalone package is `com.dude2714.sweettv`.
- The active rebuild target is `apk-work/sweettv-clean-base.apk` from `apk-work/sweettv-src-clean-base`.
- The duplicate package `com.oe.photocollage` should remain disabled for user 0 on Shield.
- Legacy donor trees under `apk-work/` are not the primary build target for Sweet TV.

## 2026-07-18 stability lock
- The active verified package on Shield is `com.dude2714.sweettv`.
- The launcher label is `Sweet TV`.
- The duplicate package `com.oe.photocollage` should stay disabled for user 0.
- The active install path should use `apk-work/install_sweet_tv_shield.ps1`.
- The active launch path should use `apk-work/launch_sweet_tv_shield.ps1`.
- The active verify path should use `apk-work/verify_sweet_tv_visibility.ps1`.
- The current rebuilt app launches into `MainActivityNew` under the Sweet TV package.
- The drawer `Discover` entry is hidden in the working-base drawer layouts.
- The drawer `Live TV` entry is intentionally hidden in the working-base drawer layout because the current built-in stream path locks up on device.
- The settings `Follow Twitter` and `About` rows are hidden in the working-base settings layout.
- The temporary `Because you watched...` movie/TV detail button was added, tested, and then removed after confirming the built-in related/similar sections were sufficient.
- The Desktop snapshot folder in use still carries a legacy source-name path and is not the desired product name.

## Incomplete work intentionally left in source
- AllDebrid should be the first feature resumed after launch is stable again.
- TorBox should stay deferred until AllDebrid is validated in the launched app.
- Discover/year-related edits in collection/detail fragments.
- Unlimited live-TV import into Sweet TV is deferred; tomorrow's work should start from a slimmed-down sidecar plan instead of more in-app bridge experiments.

## What was learned
- Work this project one change at a time.
- Keep the recovery APK separate from any experimental rebuild.
- Validate launch safety before layering additional feature work.

## Recommended next step
- Resume from `apk-work/sweettv-src-clean-base` for active Sweet TV work.
- Once launch is stable, validate the AllDebrid row and stored-key flow before touching TorBox.
- Preserve the current settings/menu cleanup unless the user explicitly asks to restore those entries.
- Treat `apk-work/sweettv-clean-base.apk` as the locked recovery baseline for this stop-point; build/sign markers are green and the signed APK checksum is `fa6e4401ac1f76183506427041168e5de1ae97d01abad56f741b66a8afc50a10`.