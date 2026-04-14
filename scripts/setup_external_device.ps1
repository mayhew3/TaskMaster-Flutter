# Pre-launch script for external device development
# 1. Detects host LAN IP and writes to assets/config/emulator_host.txt
# 2. Sets up ADB reverse port forwarding for Firestore emulator

$ProjectDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$OutputFile = Join-Path $ProjectDir "assets\config\emulator_host.txt"

# Ensure output directory exists
$OutputDir = Split-Path -Parent $OutputFile
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Detect LAN IP (first non-loopback IPv4 address)
$IP = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -ne '127.0.0.1' -and $_.PrefixOrigin -ne 'WellKnown' } |
    Select-Object -First 1).IPAddress

if (-not $IP) {
    Write-Host "WARNING: Could not detect LAN IP. Using 127.0.0.1"
    $IP = "127.0.0.1"
}

[System.IO.File]::WriteAllText($OutputFile, $IP)
Write-Host "Emulator host IP detected: $IP"

# ADB reverse for Firestore emulator port
Write-Host "Setting up ADB reverse tcp:8085..."

# Resolve adb: prefer PATH, then ANDROID_HOME / ANDROID_SDK_ROOT.
$Adb = (Get-Command adb -ErrorAction SilentlyContinue).Source
if (-not $Adb) {
    $SdkRoot = $env:ANDROID_HOME
    if (-not $SdkRoot) { $SdkRoot = $env:ANDROID_SDK_ROOT }
    if ($SdkRoot) {
        $Candidate = Join-Path $SdkRoot "platform-tools\adb.exe"
        if (Test-Path $Candidate) { $Adb = $Candidate }
    }
}

if (-not $Adb) {
    Write-Host "WARNING: adb not found on PATH or under ANDROID_HOME/ANDROID_SDK_ROOT."
    Write-Host "         Skipping ADB reverse setup. If running on a physical Android device,"
    Write-Host "         install Android platform-tools or add them to PATH."
    exit 0
}

& $Adb reverse tcp:8085 tcp:8085
