# Sweet TV Stopping Point - 2026-07-21

## Current state
- The working donor for Sweet TV is `L:\NVIDIA_SHIELD\TeaTV [11.1.8r-release].apk`.
- The working rebuilt APK is `sweettv-clean-base.apk`.
- The visible app name is `Sweet TV`.
- The installed Android package identity is `com.dude2714.sweettv`.
- The launcher resolves to `com.dude2714.sweettv/com.oe.photocollage.SplashActivity` and reaches `MainActivityNew` on Shield.

## Verified flow
- Regenerate from `create_sweettv_clean_base.ps1`, which stages the donor to `C:\Users\johns\teatv-original-donor.apk` before decode.
- Build and sign with `build_sweettv_clean_base.ps1`.
- Install with `install_sweet_tv_shield.ps1`, which stages the APK to `C:\Users\johns\sweettv-clean-base.apk` before `adb install`.
- Launch and verify with `launch_teatv_shield.ps1`.

## Identity changes already in place
- Manifest package renamed from donor package to `com.dude2714.sweettv`.
- App-owned provider/fileprovider authorities renamed to Sweet TV package identity.
- Shield helper scripts updated to target the Sweet TV package.

## Current limits
- Internal class namespace still uses donor package names like `com.oe.photocollage`.
- That internal namespace is currently acceptable because the installed package, authorities, and visible branding are already Sweet TV.

## Recommended next step
- Keep this state as the new stable Sweet TV baseline.
- Only do deeper internal namespace cleanup if there is a specific reason to change it.