$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$report = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\launch_teatv_shield_report.txt'
$runStamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'RUN_STAMP=' + $runStamp
    'ADB_PATH=' + $adb
    'REPORT_PATH=' + $report
) -Encoding ascii

try {
    $clearOutput = & $adb -s $serial logcat -c 2>&1
    $clearExit = $LASTEXITCODE

    $launchOutput = & $adb -s $serial shell am start -W -n com.dude2714.teatv/com.oe.photocollage.SplashActivity 2>&1
    $launchExit = $LASTEXITCODE

    $topOutput = & $adb -s $serial shell dumpsys activity top 2>&1
    $topExit = $LASTEXITCODE
    $topFiltered = $topOutput | Select-String 'ACTIVITY|com\.dude2714\.teatv|SplashActivity|MainActivityNew|com\.google\.android\.tvlauncher'

    $logcatOutput = & $adb -s $serial logcat -d -v brief 2>&1
    $logcatExit = $LASTEXITCODE
    $logcatFiltered = $logcatOutput | Select-String 'com\.dude2714\.teatv|AndroidRuntime|FATAL EXCEPTION|VerifyError|Exception|ActivityTaskManager|ActivityManager'

    $lines = @(
        'CLEAR_EXIT=' + $clearExit
        'CLEAR_OUTPUT_BEGIN'
    )

    $lines += $clearOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'CLEAR_OUTPUT_END'
        'LAUNCH_EXIT=' + $launchExit
        'LAUNCH_OUTPUT_BEGIN'
    )

    $lines += $launchOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'LAUNCH_OUTPUT_END'
        'TOP_EXIT=' + $topExit
        'TOP_OUTPUT_BEGIN'
    )

    $lines += $topFiltered | ForEach-Object { $_.ToString() }

    $lines += @(
        'TOP_OUTPUT_END'
        'LOGCAT_EXIT=' + $logcatExit
        'LOGCAT_OUTPUT_BEGIN'
    )

    $lines += $logcatFiltered | ForEach-Object { $_.ToString() }

    $lines += @(
        'LOGCAT_OUTPUT_END'
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