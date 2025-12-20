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
set BACKUP_OUTPUT_URI=%BUCKET_NAME%/%BACKUP_SUBFOLDER%

echo === Firestore Backup Script ===
echo Project: %PROJECT_ID%
echo Date: %DATE_SUFFIX%
echo Backup URI: %BACKUP_OUTPUT_URI%
echo.

REM Check if gsutil is available
echo Checking for Google Cloud SDK...
where gsutil.cmd >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: gsutil not found in PATH
    echo Please install Google Cloud SDK: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)
echo Google Cloud SDK found.
echo.

REM Step 1: Ensure GCS bucket exists
echo [1/4] Checking if backup bucket exists...
call gsutil.cmd ls %BUCKET_NAME% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Bucket does not exist. Creating: %BUCKET_NAME%
    call gsutil.cmd mb -p %PROJECT_ID% -l us-central1 %BUCKET_NAME%
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Failed to create bucket
        pause
        exit /b 1
    )
    echo Bucket created successfully
) else (
    echo Bucket already exists
)

REM Step 2: Create Firestore backup
echo.
echo [2/4] Creating Firestore backup...
echo Backup subfolder: %BACKUP_SUBFOLDER%

call gcloud.cmd firestore export %BACKUP_OUTPUT_URI% --project=%PROJECT_ID%
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to start Firestore export
    echo Make sure you are authenticated: gcloud auth login
    pause
    exit /b 1
)

echo.
echo Firestore export completed!
echo.

REM Step 3: Create local backup directory
echo [3/4] Creating local backup directory...
if not exist "%LOCAL_BACKUP_DIR%" mkdir "%LOCAL_BACKUP_DIR%"
echo Directory: %LOCAL_BACKUP_DIR%

REM Step 4: Download backup
echo.
echo [4/4] Downloading backup to local directory...
call gsutil.cmd -m cp -r %BACKUP_OUTPUT_URI%/* %LOCAL_BACKUP_DIR%\
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to download backup
    pause
    exit /b 1
)

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
echo 2. To restore, use: gcloud.cmd firestore import %BACKUP_OUTPUT_URI% --project=%PROJECT_ID%
echo 3. To delete GCS backup after download: gsutil.cmd rm -r %BACKUP_OUTPUT_URI%
echo.

pause
endlocal
