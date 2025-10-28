@echo off
REM Firestore Backup Script for Windows
REM Creates a backup of Firestore database and downloads it to local db_backups directory

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ID=m3-taskmaster-3000
set BUCKET_NAME=gs://taskmaster-3000-backups
set BACKUP_DIR=db_backups

REM Get current date in YYYY_MM_DD format
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set DATE_SUFFIX=%dt:~0,4%_%dt:~4,2%_%dt:~6,2%

set BACKUP_SUBFOLDER=prod_%DATE_SUFFIX%
set LOCAL_BACKUP_DIR=%BACKUP_DIR%\%BACKUP_SUBFOLDER%

echo === Firestore Backup Script ===
echo Project: %PROJECT_ID%
echo Date: %DATE_SUFFIX%
echo.

REM Step 1: Ensure GCS bucket exists
echo [1/4] Checking if backup bucket exists...
gsutil ls %BUCKET_NAME% >nul 2>&1
if errorlevel 1 (
    echo Creating backup bucket: %BUCKET_NAME%
    gsutil mb -p %PROJECT_ID% -l us-central1 %BUCKET_NAME%
    echo Bucket created successfully
) else (
    echo Bucket already exists
)

REM Step 2: Create Firestore backup
echo.
echo [2/4] Creating Firestore backup...
set BACKUP_OUTPUT_URI=%BUCKET_NAME%/%BACKUP_SUBFOLDER%

echo Backup subfolder: %BACKUP_SUBFOLDER%
echo Backup URI: %BACKUP_OUTPUT_URI%

gcloud firestore export %BACKUP_OUTPUT_URI% --project=%PROJECT_ID% --async

echo Firestore export started (async). This may take several minutes...
echo You can monitor progress at:
echo https://console.cloud.google.com/firestore/databases/-default-/import-export?project=%PROJECT_ID%

REM Wait for export to complete
echo.
echo Waiting for export to complete (checking every 10 seconds)...
set ATTEMPTS=0
set MAX_ATTEMPTS=60

:wait_loop
gsutil ls %BACKUP_OUTPUT_URI%/%BACKUP_SUBFOLDER%.overall_export_metadata >nul 2>&1
if not errorlevel 1 (
    echo Export completed successfully!
    goto export_done
)

set /a ATTEMPTS+=1
echo Still waiting... (%ATTEMPTS%/%MAX_ATTEMPTS%)
timeout /t 10 /nobreak >nul

if %ATTEMPTS% lss %MAX_ATTEMPTS% goto wait_loop

echo WARNING: Export is taking longer than expected.
echo Check the console to verify it completed:
echo https://console.cloud.google.com/firestore/databases/-default-/import-export?project=%PROJECT_ID%
echo.
set /p EXPORT_DONE="Has the export completed? (y/n): "
if /i not "%EXPORT_DONE%"=="y" (
    echo Exiting. Please run the download step manually later.
    exit /b 1
)

:export_done

REM Step 3: Create local backup directory
echo.
echo [3/4] Creating local backup directory...
if not exist "%LOCAL_BACKUP_DIR%" mkdir "%LOCAL_BACKUP_DIR%"
echo Directory created: %LOCAL_BACKUP_DIR%

REM Step 4: Download backup
echo.
echo [4/4] Downloading backup to local directory...
gsutil -m cp -r %BACKUP_OUTPUT_URI%/* %LOCAL_BACKUP_DIR%\

echo.
echo === Backup Complete! ===
echo Local backup location: %LOCAL_BACKUP_DIR%
echo GCS backup location: %BACKUP_OUTPUT_URI%
echo.

REM List backup contents
echo Backup contents:
dir /s "%LOCAL_BACKUP_DIR%"

echo.
echo === Next Steps ===
echo 1. Verify backup integrity by checking files in %LOCAL_BACKUP_DIR%
echo 2. To restore, use: gcloud firestore import %BACKUP_OUTPUT_URI%
echo 3. To delete GCS backup after download: gsutil rm -r %BACKUP_OUTPUT_URI%
echo.

endlocal
