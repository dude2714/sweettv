$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$package = 'com.dude2714.sweettv'
$legacyPackage = 'com.oe.photocollage'
$report = Join-Path (Split-Path -Parent $PSCommandPath) 'verify_sweet_tv_visibility_report.txt'

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'PACKAGE=' + $package
    'LEGACY_PACKAGE=' + $legacyPackage
) -Encoding ascii

try {
    $mainOutput = & $adb -s $serial shell pm list packages $package 2>&1
    $mainPresent = [bool]($mainOutput | Select-String ('package:' + [regex]::Escape($package)))

    $legacyEnabledOutput = & $adb -s $serial shell pm list packages -e $legacyPackage 2>&1
    $legacyEnabled = [bool]($legacyEnabledOutput | Select-String ('package:' + [regex]::Escape($legacyPackage)))

    $legacyDisabledOutput = & $adb -s $serial shell pm list packages -d $legacyPackage 2>&1
    $legacyDisabled = [bool]($legacyDisabledOutput | Select-String ('package:' + [regex]::Escape($legacyPackage)))

    $resolveOutput = & $adb -s $serial shell cmd package resolve-activity --brief $package 2>&1
    $resolveExit = $LASTEXITCODE

    $packageOutput = & $adb -s $serial shell dumpsys package $package 2>&1
    $packageFiltered = $packageOutput | Select-String 'android.intent.action.MAIN|android.intent.category.LEANBACK_LAUNCHER|android.intent.category.LAUNCHER|com\.dude2714\.sweettv\.SplashActivity|com\.dude2714\.sweettv\.MainActivityNew|com\.dude2714\.sweettv|enabled='

    $lines = @(
        'MAIN_PRESENT=' + $mainPresent
        'MAIN_OUTPUT_BEGIN'
    )

    $lines += $mainOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'MAIN_OUTPUT_END'
        'LEGACY_ENABLED=' + $legacyEnabled
        'LEGACY_ENABLED_OUTPUT_BEGIN'
    )

    $lines += $legacyEnabledOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'LEGACY_ENABLED_OUTPUT_END'
        'LEGACY_DISABLED=' + $legacyDisabled
        'LEGACY_DISABLED_OUTPUT_BEGIN'
    )

    $lines += $legacyDisabledOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'LEGACY_DISABLED_OUTPUT_END'
        'RESOLVE_EXIT=' + $resolveExit
        'RESOLVE_OUTPUT_BEGIN'
    )

    $lines += $resolveOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'RESOLVE_OUTPUT_END'
        'PACKAGE_OUTPUT_BEGIN'
    )

    $lines += $packageFiltered | ForEach-Object { $_.ToString() }

    $lines += @(
        'PACKAGE_OUTPUT_END'
        'SCRIPT_DONE=YES'
    )

    Add-Content -LiteralPath $report -Value $lines -Encoding ascii
} catch {
    Add-Content -LiteralPath $report -Value @(
        'SCRIPT_EXCEPTION=' + $_.Exception.Message
        'SCRIPT_DONE=NO'
    ) -Encoding ascii
    throw
}
