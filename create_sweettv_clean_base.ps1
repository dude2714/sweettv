$ErrorActionPreference = 'Stop'

$root = 'C:\Users\johns\OneDrive\Desktop\empty folder\tea-tv\apk-work'
$java = 'C:\Users\johns\scoop\apps\temurin17-jdk\current\bin\java.exe'
$apktool = 'C:\Users\johns\scoop\apps\apktool\current\apktool.jar'
$sourceApk = 'L:\NVIDIA_SHIELD\TeaTV [11.1.8r-release].apk'
$stagedSourceApk = 'C:\Users\johns\teatv-original-donor.apk'
$targetDir = Join-Path $root 'sweettv-src-clean-base'
$stdout = Join-Path $root 'sweettv-clean-base-decode-stdout.txt'
$stderr = Join-Path $root 'sweettv-clean-base-decode-stderr.txt'
$exitFile = Join-Path $root 'sweettv-clean-base-decode-exit.txt'

Remove-Item $stdout,$stderr,$exitFile -ErrorAction SilentlyContinue
Remove-Item $stagedSourceApk -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $targetDir) {
    Remove-Item -LiteralPath $targetDir -Recurse -Force
}

if (Test-Path -LiteralPath $sourceApk) {
    Copy-Item -LiteralPath $sourceApk -Destination $stagedSourceApk -Force
}

$decodeProc = Start-Process -FilePath $java -ArgumentList '-jar', $apktool, 'd', '-f', $stagedSourceApk, '-o', 'sweettv-src-clean-base' -WorkingDirectory $root -RedirectStandardOutput $stdout -RedirectStandardError $stderr -NoNewWindow -Wait -PassThru
"DECODE_EXIT=$($decodeProc.ExitCode)" | Set-Content $exitFile -Encoding ascii

if (-not (Test-Path -LiteralPath $sourceApk)) {
    'SOURCE_APK_MISSING=True' | Add-Content $exitFile -Encoding ascii
}

exit $decodeProc.ExitCode