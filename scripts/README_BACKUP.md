# Firestore Backup Scripts

These scripts create and download backups of your Firestore database.

## Prerequisites

1. **Google Cloud SDK installed**
   - Download from: https://cloud.google.com/sdk/docs/install
   - Or check if installed: `gcloud --version`

2. **Authenticated with GCP**
   ```bash
   gcloud auth login
   gcloud config set project m3-taskmaster-3000
   ```

3. **Required IAM permissions**
   - `datastore.databases.export` (Firestore Export)
   - `storage.buckets.create` (Create GCS bucket)
   - `storage.objects.create` (Upload to GCS)
   - `storage.objects.get` (Download from GCS)

## Usage

### Windows (Batch Script)

```cmd
cd C:\Code\TaskMaster\TaskMaster-Flutter
scripts\firestore_backup.bat
```

### Linux/Mac/Git Bash (Shell Script)

```bash
cd /c/Code/TaskMaster/TaskMaster-Flutter
chmod +x scripts/firestore_backup.sh
./scripts/firestore_backup.sh
```

## What the Script Does

1. **Creates GCS Bucket** (if doesn't exist)
   - Bucket name: `taskmaster-3000-backups`
   - Location: `us-central1`

2. **Exports Firestore Database**
   - Exports all collections to GCS
   - Backup subfolder format: `prod_YYYY_MM_DD`
   - Runs asynchronously (doesn't block)

3. **Waits for Completion**
   - Polls GCS every 10 seconds
   - Max wait time: 10 minutes
   - Shows progress updates

4. **Downloads to Local**
   - Downloads to: `db_backups/prod_YYYY_MM_DD/`
   - Preserves folder structure
   - Shows backup size and contents

## Backup Structure

```
db_backups/
├── prod_2025_01_27/
│   ├── prod_2025_01_27.overall_export_metadata
│   ├── all_namespaces/
│   │   └── kind_tasks/
│   │       ├── all_namespaces_kind_tasks.export_metadata
│   │       └── output-0
│   └── ... (other collections)
```

GCS structure matches local:
```
gs://taskmaster-3000-backups/
├── prod_2025_01_27/
│   ├── prod_2025_01_27.overall_export_metadata
│   ├── all_namespaces/
│   └── ...
├── prod_2025_01_26/
└── prod_2025_01_25/
```

## Restore from Backup

### Restore from GCS (Recommended)

```bash
gcloud firestore import gs://taskmaster-3000-backups/prod_2025_01_27
```

### Restore from Local Backup

1. Upload local backup to GCS:
   ```bash
   gsutil -m cp -r db_backups/prod_2025_01_27 gs://taskmaster-3000-backups/
   ```

2. Import from GCS:
   ```bash
   gcloud firestore import gs://taskmaster-3000-backups/prod_2025_01_27
   ```

## Manual Backup (Alternative)

If scripts don't work, you can create backups manually:

### Via Console
1. Go to: https://console.cloud.google.com/firestore/databases/-default-/import-export
2. Click "Export"
3. Select "All collections" or specific collections
4. Choose/create GCS bucket
5. Click "Export"

### Via Command Line
```bash
# Export
gcloud firestore export gs://taskmaster-3000-backups/manual_backup

# Download
gsutil -m cp -r gs://taskmaster-3000-backups/manual_backup db_backups/
```

## Cleanup Old Backups

### Delete Local Backups
```bash
# Windows
rmdir /s /q db_backups\prod_2025_01_20

# Linux/Mac
rm -rf db_backups/prod_2025_01_20
```

### Delete GCS Backups
```bash
gsutil rm -r gs://taskmaster-3000-backups/prod_2025_01_20
```

## Troubleshooting

### "Permission denied" Error
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
```

### "Bucket not found" Error
- Script will create bucket automatically
- Or create manually: `gsutil mb -p m3-taskmaster-3000 gs://taskmaster-3000-backups`

### "Export taking too long"
- Large databases can take 30+ minutes
- Check progress in console: https://console.cloud.google.com/firestore/import-export
- Script will wait up to 10 minutes, then ask for confirmation

### Download Fails
```bash
# Retry download manually
gsutil -m cp -r gs://taskmaster-3000-backups/prod_2025_01_27 db_backups/prod_2025_01_27/
```

## Automated Backups

### Schedule Daily Backups (Windows Task Scheduler)
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Daily at 2:00 AM
4. Action: Start a program
   - Program: `C:\Code\TaskMaster\TaskMaster-Flutter\scripts\firestore_backup.bat`
   - Start in: `C:\Code\TaskMaster\TaskMaster-Flutter`

### Schedule Daily Backups (Linux/Mac Cron)
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /path/to/TaskMaster-Flutter && ./scripts/firestore_backup.sh >> logs/backup.log 2>&1
```

## Cost Estimates

- **Firestore Export**: Free
- **GCS Storage**: ~$0.02/GB/month (Standard storage)
- **GCS Download**: First 1GB free/month, then ~$0.12/GB

Example: 100MB database
- GCS storage: ~$0.002/month
- Download: Free (under 1GB)

## Best Practices

1. **Backup before major changes**
   - Before migrations
   - Before bulk deletes
   - Before schema changes

2. **Keep multiple backups**
   - Daily for last 7 days
   - Weekly for last month
   - Monthly for last year

3. **Test restores periodically**
   - Verify backups are valid
   - Practice restore process
   - Use test project for restore testing

4. **Monitor backup size**
   - Track growth over time
   - Clean up old data if needed
   - Optimize storage costs

## Support

If you encounter issues:
1. Check GCP Console for detailed error messages
2. Verify IAM permissions
3. Check GCS bucket access
4. Review Firestore export/import documentation: https://cloud.google.com/firestore/docs/manage-data/export-import
