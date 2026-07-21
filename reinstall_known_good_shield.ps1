$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$apk = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\teatv-standalone-rebuilt-20260717-aligned-debugSigned.apk'
$report = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\reinstall_known_good_shield_report.txt'

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'ADB_PATH=' + $adb
    'APK_PATH=' + $apk
    'REPORT_PATH=' + $report
) -Encoding ascii

try {
    $apkExists = Test-Path -LiteralPath $apk
    $output = & $adb -s $serial install -r $apk 2>&1
    $exitCode = $LASTEXITCODE
    $mainOutput = & $adb -s $serial shell pm list packages com.dude2714.teatv 2>&1
    $mainPresent = [bool]($mainOutput | Select-String 'package:com\.dude2714\.teatv')
    $legacyOutput = & $adb -s $serial shell pm list packages com.oe.grg3p0bcubi4 2>&1
    $legacyPresent = [bool]($legacyOutput | Select-String 'package:com\.oe\.grg3p0bcubi4')

    $lines = @(
        'APK_EXISTS=' + $apkExists
        'INSTALL_EXIT=' + $exitCode
        'INSTALL_OUTPUT_BEGIN'
    )

    $lines += $output | ForEach-Object { $_.ToString() }

    $lines += @(
        'INSTALL_OUTPUT_END'
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
    )

    Add-Content -LiteralPath $report -Value $lines -Encoding ascii
} catch {
    Add-Content -LiteralPath $report -Value @(
        'SCRIPT_EXCEPTION=' + $_.Exception.Message
    ) -Encoding ascii
    throw
}