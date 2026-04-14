#!/bin/bash
# Copy Backup to Emulator Script
# Prepares a db_backups/ folder for use with the Firebase emulator and
# updates the prod_latest pointer inside db_backups/.
# Defaults to the most recent prod_* backup if no argument is provided.
#
# Usage:
#   bash scripts/copy_backup_to_emulator.sh                        # uses most recent backup
#   bash scripts/copy_backup_to_emulator.sh prod_2026_04_12_143022 # uses specific backup

set -e

BACKUP_DIR="db_backups"
LATEST_DEST="${BACKUP_DIR}/prod_latest"

# Resolve which backup to use
if [ -n "$1" ]; then
    BACKUP_SUBFOLDER="$1"
    SOURCE="${BACKUP_DIR}/${BACKUP_SUBFOLDER}"
    if [ ! -d "${SOURCE}" ]; then
        echo "Error: backup not found at ${SOURCE}"
        echo ""
        echo "Available backups:"
        ls "${BACKUP_DIR}/"
        exit 1
    fi
else
    SOURCE=$(ls -dt "${BACKUP_DIR}"/prod_2* 2>/dev/null | head -1)
    if [ -z "${SOURCE}" ]; then
        echo "Error: no prod_* backups found in ${BACKUP_DIR}/"
        echo "Run bash scripts/firestore_backup.sh first."
        exit 1
    fi
    BACKUP_SUBFOLDER=$(basename "${SOURCE}")
fi

echo "=== Copy Backup to Emulator ==="
echo "Source: ${SOURCE}"
echo "Target: ${LATEST_DEST}"
echo ""

# Generate firebase-export-metadata.json so the emulator can find the data.
# The metadata_file must match the .overall_export_metadata filename in the backup.
METADATA_FILE="${BACKUP_SUBFOLDER}.overall_export_metadata"
if [ ! -f "${SOURCE}/${METADATA_FILE}" ]; then
    echo "Warning: expected metadata file not found: ${SOURCE}/${METADATA_FILE}"
    echo "The emulator may not load correctly."
fi

cat > "${SOURCE}/firebase-export-metadata.json" <<EOF
{
  "version": "15.11.0",
  "firestore": {
    "version": "1",
    "path": ".",
    "metadata_file": "${METADATA_FILE}"
  }
}
EOF
echo "Written: ${SOURCE}/firebase-export-metadata.json"

# Update prod_latest (copy, not symlink — Firebase CLI doesn't follow symlinks reliably)
echo "Updating ${LATEST_DEST}..."
rm -rf "${LATEST_DEST}"
cp -r "${SOURCE}" "${LATEST_DEST}"
echo "Done."

echo ""
echo "Start the emulator with:"
echo "  firebase emulators:start --import=${LATEST_DEST}"
echo ""
echo "Or with auto-export on exit (saves emulator changes back to prod_latest):"
echo "  firebase emulators:start --import=${LATEST_DEST} --export-on-exit=${LATEST_DEST}"
echo ""
