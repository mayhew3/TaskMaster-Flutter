#!/bin/bash
# Firestore Backup Script
# Creates a backup of Firestore database and downloads it to local db_backups directory

set -e  # Exit on error

# Configuration
PROJECT_ID="m3-taskmaster-3000"
BUCKET_NAME="gs://taskmaster-3000-backups"
BACKUP_DIR="db_backups"
DATE_SUFFIX=$(date +%Y_%m_%d)
BACKUP_SUBFOLDER="prod_${DATE_SUFFIX}"
LOCAL_BACKUP_DIR="${BACKUP_DIR}/${BACKUP_SUBFOLDER}"

echo "=== Firestore Backup Script ==="
echo "Project: ${PROJECT_ID}"
echo "Date: ${DATE_SUFFIX}"
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

# Step 2: Create Firestore backup
echo ""
echo "[2/4] Creating Firestore backup..."
BACKUP_OUTPUT_URI="${BUCKET_NAME}/${BACKUP_SUBFOLDER}"

echo "Backup subfolder: ${BACKUP_SUBFOLDER}"
echo "Backup URI: ${BACKUP_OUTPUT_URI}"

gcloud firestore export "${BACKUP_OUTPUT_URI}" \
    --project="${PROJECT_ID}" \
    --async

echo "Firestore export started (async). This may take several minutes..."
echo "You can monitor progress at:"
echo "https://console.cloud.google.com/firestore/databases/-default-/import-export?project=${PROJECT_ID}"

# Wait for export to complete
echo ""
echo "Waiting for export to complete (checking every 10 seconds)..."
ATTEMPTS=0
MAX_ATTEMPTS=60  # 10 minutes max wait

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    # Check if the export metadata file exists (indicates completion)
    if gsutil ls "${BACKUP_OUTPUT_URI}/${BACKUP_SUBFOLDER}.overall_export_metadata" &> /dev/null; then
        echo "Export completed successfully!"
        break
    fi

    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Still waiting... (${ATTEMPTS}/${MAX_ATTEMPTS})"
    sleep 10
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "WARNING: Export is taking longer than expected."
    echo "Check the console to verify it completed:"
    echo "https://console.cloud.google.com/firestore/databases/-default-/import-export?project=${PROJECT_ID}"
    echo ""
    read -p "Has the export completed? (y/n): " EXPORT_DONE
    if [ "$EXPORT_DONE" != "y" ]; then
        echo "Exiting. Please run the download step manually later."
        exit 1
    fi
fi

# Step 3: Create local backup directory
echo ""
echo "[3/4] Creating local backup directory..."
mkdir -p "${LOCAL_BACKUP_DIR}"
echo "Directory created: ${LOCAL_BACKUP_DIR}"

# Step 4: Download backup
echo ""
echo "[4/4] Downloading backup to local directory..."
gsutil -m cp -r "${BACKUP_OUTPUT_URI}/*" "${LOCAL_BACKUP_DIR}/"

echo ""
echo "=== Backup Complete! ==="
echo "Local backup location: ${LOCAL_BACKUP_DIR}"
echo "GCS backup location: ${BACKUP_OUTPUT_URI}"
echo ""

# Calculate backup size
BACKUP_SIZE=$(du -sh "${LOCAL_BACKUP_DIR}" | cut -f1)
echo "Backup size: ${BACKUP_SIZE}"

# List backup contents
echo ""
echo "Backup contents:"
ls -lh "${LOCAL_BACKUP_DIR}"

echo ""
echo "=== Next Steps ==="
echo "1. Verify backup integrity by checking files in ${LOCAL_BACKUP_DIR}"
echo "2. To restore, use: gcloud firestore import ${BACKUP_OUTPUT_URI}"
echo "3. To delete GCS backup after download: gsutil rm -r ${BACKUP_OUTPUT_URI}"
echo ""
