$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$package = 'com.dude2714.sweettv'
$legacyPackage = 'com.oe.grg3p0bcubi4'
$report = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\verify_teatv_visibility_report.txt'

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'PACKAGE=' + $package
    'LEGACY_PACKAGE=' + $legacyPackage
) -Encoding ascii

try {
    $mainOutput = & $adb -s $serial shell pm list packages $package 2>&1
    $mainPresent = [bool]($mainOutput | Select-String ('package:' + [regex]::Escape($package)))

    $legacyOutput = & $adb -s $serial shell pm list packages $legacyPackage 2>&1
    $legacyPresent = [bool]($legacyOutput | Select-String 'package:com\.oe\.grg3p0bcubi4')

    $resolveOutput = & $adb -s $serial shell cmd package resolve-activity --brief $package 2>&1
    $resolveExit = $LASTEXITCODE

    $packageOutput = & $adb -s $serial shell dumpsys package $package 2>&1
    $packageFiltered = $packageOutput | Select-String 'android.intent.action.MAIN|android.intent.category.LEANBACK_LAUNCHER|android.intent.category.LAUNCHER|com\.oe\.photocollage\.SplashActivity|com\.oe\.photocollage\.MainActivityNew|com\.dude2714\.sweettv|enabled='

    $lines = @(
        'MAIN_PRESENT=' + $mainPresent
        'MAIN_OUTPUT_BEGIN'
    )

    $lines += $mainOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'MAIN_OUTPUT_END'
        'LEGACY_PRESENT=' + $legacyPresent
        'LEGACY_OUTPUT_BEGIN'
    )

    $lines += $legacyOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'LEGACY_OUTPUT_END'
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