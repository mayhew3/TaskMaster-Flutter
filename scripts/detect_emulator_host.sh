#!/bin/bash
# Detects the host machine's LAN IP and writes it to assets/config/emulator_host.txt
# This file is gitignored and read at runtime by the Flutter app when SERVER=local

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_DIR/assets/config/emulator_host.txt"

# Detect LAN IP based on OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  # Windows (Git Bash / MSYS2)
  IP=$(ipconfig | grep -i "IPv4" | head -1 | sed 's/.*: //' | tr -d '\r\n ')
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
else
  # Linux
  IP=$(hostname -I | awk '{print $1}')
fi

if [ -z "$IP" ]; then
  echo "WARNING: Could not detect LAN IP. Using 127.0.0.1"
  IP="127.0.0.1"
fi

echo -n "$IP" > "$OUTPUT_FILE"
echo "Emulator host IP detected: $IP (written to assets/config/emulator_host.txt)"
