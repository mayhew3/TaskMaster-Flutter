@echo off
REM Firestore Backup Script (Windows)
REM Exports production Firestore data to GCS and downloads it to db_backups\.
REM Run from the project root: scripts\firestore_backup.bat

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ID=m3-taskmaster-3000
set BUCKET_NAME=gs://taskmaster-3000-backups
set BACKUP_DIR=db_backups

REM Build YYYY_MM_DD_HHMMSS timestamp via WMIC
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set DATE_SUFFIX=%dt:~0,4%_%dt:~4,2%_%dt:~6,2%_%dt:~8,2%%dt:~10,2%%dt:~12,2%

set BACKUP_SUBFOLDER=prod_%DATE_SUFFIX%
set LOCAL_BACKUP_DIR=%BACKUP_DIR%\%BACKUP_SUBFOLDER%
set GCS_URI=%BUCKET_NAME%/%BACKUP_SUBFOLDER%

echo === Firestore Backup Script ===
echo Project: %PROJECT_ID%
echo Backup:  %BACKUP_SUBFOLDER%
echo.

REM Check for Google Cloud SDK
where gsutil.cmd >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: gsutil not found. Install Google Cloud SDK:
    echo https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

REM Step 1: Ensure GCS bucket exists
echo [1/4] Checking if backup bucket exists...
call gsutil.cmd ls %BUCKET_NAME% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Creating bucket: %BUCKET_NAME%
    call gsutil.cmd mb -p %PROJECT_ID% -l us-central1 %BUCKET_NAME%
    if %ERRORLEVEL% neq 0 ( echo ERROR: Failed to create bucket & pause & exit /b 1 )
    echo Bucket created successfully
) else (
    echo Bucket already exists
)

REM Step 2: Export Firestore to GCS (synchronous — gcloud blocks until done)
echo.
echo [2/4] Exporting Firestore to GCS...
echo GCS URI: %GCS_URI%

call gcloud.cmd firestore export %GCS_URI% --project=%PROJECT_ID%
if %ERRORLEVEL% neq 0 (
    echo ERROR: Export failed. Make sure you are authenticated:
    echo   gcloud auth login
    pause
    exit /b 1
)
echo Export complete!

REM Step 3: Create local backup directory
echo.
echo [3/4] Creating local backup directory...
if not exist "%LOCAL_BACKUP_DIR%" mkdir "%LOCAL_BACKUP_DIR%"
echo Directory: %LOCAL_BACKUP_DIR%

REM Step 4: Download backup
echo.
echo [4/4] Downloading backup...
call gsutil.cmd -m cp -r %GCS_URI%/* %LOCAL_BACKUP_DIR%\
if %ERRORLEVEL% neq 0 (
    echo ERROR: Download failed.
    pause
    exit /b 1
)

echo.
echo === Backup Complete! ===
echo Local: %LOCAL_BACKUP_DIR%
echo GCS:   %GCS_URI%
echo.
echo To load into the emulator:
echo   scripts\copy_backup_to_emulator.bat %BACKUP_SUBFOLDER%
echo.

pause
endlocal
