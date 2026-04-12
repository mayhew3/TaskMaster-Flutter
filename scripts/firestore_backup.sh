#!/bin/bash
# Firestore Backup Script
# Exports production Firestore data to GCS and downloads it to db_backups/.
# Run from the project root: bash scripts/firestore_backup.sh

set -e  # Exit on error

# Configuration
PROJECT_ID="m3-taskmaster-3000"
BUCKET_NAME="gs://taskmaster-3000-backups"
BACKUP_DIR="db_backups"
DATE_SUFFIX=$(date +%Y_%m_%d_%H%M%S)
BACKUP_SUBFOLDER="prod_${DATE_SUFFIX}"
LOCAL_BACKUP_DIR="${BACKUP_DIR}/${BACKUP_SUBFOLDER}"
GCS_URI="${BUCKET_NAME}/${BACKUP_SUBFOLDER}"

echo "=== Firestore Backup Script ==="
echo "Project: ${PROJECT_ID}"
echo "Backup:  ${BACKUP_SUBFOLDER}"
echo ""

# Step 1: Ensure GCS bucket exists
echo "[1/4] Checking if backup bucket exists..."
if ! gsutil ls "${BUCKET_NAME}" &> /dev/null; then
    echo "Creating backup bucket: ${BUCKET_NAME}"
    gsutil mb -p "${PROJECT_ID}" -l us-central1 "${BUCKET_NAME}"
    echo "Bucket created successfully"
else
    echo "Bucket already exists"
fi

# Step 2: Export Firestore to GCS
echo ""
echo "[2/4] Starting Firestore export..."
echo "GCS URI: ${GCS_URI}"

gcloud firestore export "${GCS_URI}" \
    --project="${PROJECT_ID}" \
    --async

echo "Export started (async). Polling every 10 seconds..."

ATTEMPTS=0
MAX_ATTEMPTS=60  # 10 minutes max

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if gsutil ls "${GCS_URI}/${BACKUP_SUBFOLDER}.overall_export_metadata" &> /dev/null; then
        echo "Export completed!"
        break
    fi
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Still waiting... (${ATTEMPTS}/${MAX_ATTEMPTS})"
    sleep 10
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "WARNING: Export timed out. Check:"
    echo "https://console.cloud.google.com/firestore/databases/-default-/import-export?project=${PROJECT_ID}"
    read -p "Has the export completed? (y/n): " EXPORT_DONE
    if [ "$EXPORT_DONE" != "y" ]; then
        echo "Exiting. Run the download step manually later."
        exit 1
    fi
fi

# Step 3: Create local backup directory
echo ""
echo "[3/4] Creating local backup directory..."
mkdir -p "${LOCAL_BACKUP_DIR}"
echo "Directory: ${LOCAL_BACKUP_DIR}"

# Step 4: Download backup
echo ""
echo "[4/4] Downloading backup..."
gsutil -o "GSUtil:parallel_process_count=1" -m cp -r "${GCS_URI}/*" "${LOCAL_BACKUP_DIR}/"

echo ""
echo "=== Backup Complete! ==="
echo "Local: ${LOCAL_BACKUP_DIR}"
echo "GCS:   ${GCS_URI}"
echo ""
echo "Backup size: $(du -sh "${LOCAL_BACKUP_DIR}" | cut -f1)"
echo ""
echo "To load into the emulator:"
echo "  bash scripts/copy_backup_to_emulator.sh ${BACKUP_SUBFOLDER}"
echo ""
