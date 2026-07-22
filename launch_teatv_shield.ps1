$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$report = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\launch_teatv_shield_report.txt'
$manifestPath = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\sweettv-src-clean-base\AndroidManifest.xml'
$runStamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

[string]$manifestText = Get-Content -LiteralPath $manifestPath -Raw
$packageMatch = [regex]::Match($manifestText, '<manifest\b[^>]*\bpackage="([^"]+)"')
if (-not $packageMatch.Success) {
    throw 'Package name not found in AndroidManifest.xml'
}

$packageName = $packageMatch.Groups[1].Value
$launcherActivity = $null
$activityMatches = [regex]::Matches($manifestText, '<activity\b[^>]*\bandroid:name="([^"]+)"[^>]*>(.*?)</activity>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

foreach ($activityMatch in $activityMatches) {
    $activityBody = $activityMatch.Groups[2].Value
    if ($activityBody -match 'android.intent.action.MAIN' -and $activityBody -match 'android.intent.category.(LAUNCHER|LEANBACK_LAUNCHER)') {
        $launcherActivity = $activityMatch.Groups[1].Value
        break
    }
}

if (-not $launcherActivity) {
    throw 'Launcher activity not found in AndroidManifest.xml'
}

$launchComponent = if ($launcherActivity.StartsWith('.')) {
    $packageName + '/' + $packageName + $launcherActivity
} else {
    $packageName + '/' + $launcherActivity
}
$packagePattern = [regex]::Escape($packageName)
$activityPattern = [regex]::Escape(($launcherActivity -split '\.')[-1])

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'RUN_STAMP=' + $runStamp
    'ADB_PATH=' + $adb
    'REPORT_PATH=' + $report
    'PACKAGE_NAME=' + $packageName
    'LAUNCH_COMPONENT=' + $launchComponent
) -Encoding ascii

try {
    $clearOutput = & $adb -s $serial logcat -c 2>&1
    $clearExit = $LASTEXITCODE

    $launchOutput = & $adb -s $serial shell am start -W -n $launchComponent 2>&1
    $launchExit = $LASTEXITCODE

    $topOutput = & $adb -s $serial shell dumpsys activity top 2>&1
    $topExit = $LASTEXITCODE
    $topPattern = 'ACTIVITY|' + $packagePattern + '|' + $activityPattern + '|MainActivityNew|com\.google\.android\.tvlauncher'
    $topFiltered = $topOutput | Select-String $topPattern

    $logcatOutput = & $adb -s $serial logcat -d -v brief 2>&1
    $logcatExit = $LASTEXITCODE
    $logcatPattern = $packagePattern + '|AndroidRuntime|FATAL EXCEPTION|VerifyError|Exception|ActivityTaskManager|ActivityManager'
    $logcatFiltered = $logcatOutput | Select-String $logcatPattern

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