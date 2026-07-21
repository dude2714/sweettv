# TeaTV Stopping Point - 2026-07-17

## Current state
- Shield access was restored with `apk-work/teatv-standalone-rebuilt-20260717-aligned-debugSigned.apk`.
- The latest working-base rebuild target is `apk-work/teatv-year-base-test.apk`, and the staged install helper still reports a successful install to Shield.
- Current launch attempts from the 2026-07-18 working copy are not reliable enough to treat as verified: launch reports either truncate or bounce back to launcher/package UI instead of proving TeaTV foreground state.
- The source tree under `apk-work/teatv-src` still contains unfinished settings and discover/year edits and should not be treated as a verified build target.

## 2026-07-18 stability lock
- The active verified package on Shield is `com.dude2714.teatv`.
- The launcher label was renamed to `Sweet TV`.
- The legacy package `com.oe.grg3p0bcubi4` was removed for user 0 to prevent stale launcher routing.
- The verified rebuild target remains `apk-work/teatv-src-working-base`.
- The latest staged install helper still targets `apk-work/teatv-year-base-test.apk` and writes the staged copy to `C:\Users\johns\teatv-year-base-test.apk` before install.
- The verified install path must stage the rebuilt APK to a host path without spaces before `adb install`.
- The startup crash root cause was a `BaseGridFragment` mismatch in the working base: `getData()` referenced field `m`, but the class was missing field `m` and a real `c(String year)` setter. That mismatch is now fixed in the working base.
- The current rebuilt app launches into `MainActivityNew`, and the year path is working again.
- The drawer `Discover` entry is hidden in the working-base drawer layouts.
- The settings `Follow Twitter` and `About` rows are hidden in the working-base settings layout.
- The temporary `Because you watched...` movie/TV detail button was added, tested, and then removed after confirming the built-in related/similar sections were sufficient.
- The Desktop snapshot folder in use is `C:\Users\johns\Desktop\teatv`, which currently holds the locked APK copy for pickup outside the repo.

## Incomplete work intentionally left in source
- AllDebrid should be the first feature resumed after launch is stable again.
- TorBox should stay deferred until AllDebrid is validated in the launched app.
- Discover/year-related edits in collection/detail fragments.

## What was learned
- Work this project one change at a time.
- Keep the recovery APK separate from any experimental rebuild.
- Validate launch safety before layering additional feature work.

## Recommended next step
- Resume from `apk-work/teatv-src-working-base` only after capturing the launch failure cleanly enough to prove TeaTV foreground state again.
- Once launch is stable, validate the AllDebrid row and stored-key flow before touching TorBox.
- Preserve the current settings/menu cleanup unless the user explicitly asks to restore those entries.