$ErrorActionPreference = 'Stop'

$adb = 'C:\Users\johns\AppData\Local\Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools\adb.exe'
$serial = '0321418026779'
$apk = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\sweettv-clean-base.apk'
$stagedApk = 'C:\Users\johns\sweettv-clean-base.apk'
$report = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\install_sweet_tv_shield_report.txt'
$manifestPath = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work\sweettv-src-clean-base\AndroidManifest.xml'
$runStamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

[string]$manifestText = Get-Content -LiteralPath $manifestPath -Raw
$packageMatch = [regex]::Match($manifestText, '<manifest\b[^>]*\bpackage="([^"]+)"')
if (-not $packageMatch.Success) {
    throw 'Package name not found in AndroidManifest.xml'
}

$packageName = $packageMatch.Groups[1].Value

Set-Content -LiteralPath $report -Value @(
    'SCRIPT_STARTED=YES'
    'RUN_STAMP=' + $runStamp
    'APK_PATH=' + $apk
    'STAGED_APK_PATH=' + $stagedApk
    'PACKAGE_NAME=' + $packageName
) -Encoding ascii

try {
    $apkExists = Test-Path -LiteralPath $apk
    $apkSize = if ($apkExists) { (Get-Item -LiteralPath $apk).Length } else { -1 }
    Copy-Item -LiteralPath $apk -Destination $stagedApk -Force
    $stagedExists = Test-Path -LiteralPath $stagedApk
    $stagedSize = if ($stagedExists) { (Get-Item -LiteralPath $stagedApk).Length } else { -1 }
    $output = & $adb -s $serial install -r $stagedApk 2>&1
    $exitCode = $LASTEXITCODE
    $packageOutput = & $adb -s $serial shell pm list packages $packageName 2>&1
    $packagePresent = [bool]($packageOutput | Select-String ('package:' + [regex]::Escape($packageName)))
    $resolveOutput = & $adb -s $serial shell cmd package resolve-activity --brief $packageName 2>&1
    $resolveExit = $LASTEXITCODE

    $lines = @(
        'APK_EXISTS=' + $apkExists
        'APK_SIZE=' + $apkSize
        'STAGED_APK_EXISTS=' + $stagedExists
        'STAGED_APK_SIZE=' + $stagedSize
        'INSTALL_EXIT=' + $exitCode
        'INSTALL_OUTPUT_BEGIN'
    )

    $lines += $output | ForEach-Object { $_.ToString() }

    $lines += @(
        'INSTALL_OUTPUT_END'
        'PACKAGE_PRESENT=' + $packagePresent
        'PACKAGE_OUTPUT_BEGIN'
    )

    $lines += $packageOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'PACKAGE_OUTPUT_END'
        'RESOLVE_EXIT=' + $resolveExit
        'RESOLVE_OUTPUT_BEGIN'
    )

    $lines += $resolveOutput | ForEach-Object { $_.ToString() }

    $lines += @(
        'RESOLVE_OUTPUT_END'
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