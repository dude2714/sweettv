$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSCommandPath
$java = 'C:\Users\johns\scoop\apps\temurin17-jdk\current\bin\java.exe'
$apktool = 'C:\Users\johns\scoop\apps\apktool\current\apktool.jar'
$toolsDir = 'C:\Users\johns\OneDrive\Desktop\empty folder\terrarium-tv\.tools'
$signerJar = 'uber-apk-signer-1.3.0.jar'
$sourceDir = Join-Path $root 'sweettv-src-clean-base'
$sourceBuildDir = Join-Path $sourceDir 'build'
$unsignedApk = Join-Path $root 'sweettv-clean-base.apk'
$stdout = Join-Path $root 'sweettv-clean-base-build-stdout.txt'
$stderr = Join-Path $root 'sweettv-clean-base-build-stderr.txt'
$signOut = Join-Path $root 'sweettv-clean-base-sign-stdout.txt'
$signErr = Join-Path $root 'sweettv-clean-base-sign-stderr.txt'

Remove-Item $unsignedApk,$stdout,$stderr,$signOut,$signErr -ErrorAction SilentlyContinue
Remove-Item $sourceBuildDir -Recurse -Force -ErrorAction SilentlyContinue

& (Join-Path $root 'prepare_sweettv_clean_base.ps1')

$buildProc = Start-Process -FilePath $java -ArgumentList '-jar', $apktool, 'b', '-f', 'sweettv-src-clean-base', '-o', 'sweettv-clean-base.apk' -WorkingDirectory $root -RedirectStandardOutput $stdout -RedirectStandardError $stderr -NoNewWindow -Wait -PassThru
"BUILD_EXIT=$($buildProc.ExitCode)" | Set-Content (Join-Path $root 'sweettv-clean-base-build-exit.txt')

if ($buildProc.ExitCode -ne 0) {
    exit $buildProc.ExitCode
}

Push-Location $toolsDir
$relativeUnsignedApk = Resolve-Path -LiteralPath $unsignedApk -Relative
Pop-Location
$signProc = Start-Process -FilePath $java -ArgumentList '-jar', $signerJar, '-a', $relativeUnsignedApk, '--overwrite' -WorkingDirectory $toolsDir -RedirectStandardOutput $signOut -RedirectStandardError $signErr -NoNewWindow -Wait -PassThru
"SIGN_EXIT=$($signProc.ExitCode)" | Set-Content (Join-Path $root 'sweettv-clean-base-sign-exit.txt')

exit $signProc.ExitCode