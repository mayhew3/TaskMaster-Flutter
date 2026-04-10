# Detects the host machine's LAN IP and writes it to assets/config/emulator_host.txt
# This file is gitignored and read at runtime by the Flutter app when SERVER=local

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
Write-Host "Emulator host IP detected: $IP (written to assets/config/emulator_host.txt)"
