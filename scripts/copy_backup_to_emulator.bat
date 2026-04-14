@echo off
REM Copy Backup to Emulator Script (Windows)
REM Prepares a db_backups\ folder for use with the Firebase emulator and
REM updates the prod_latest pointer inside db_backups\.
REM Defaults to the most recent prod_* backup if no argument is provided.
REM
REM Usage:
REM   scripts\copy_backup_to_emulator.bat                        (uses most recent)
REM   scripts\copy_backup_to_emulator.bat prod_2026_04_12_143022 (specific backup)

setlocal enabledelayedexpansion

set BACKUP_DIR=db_backups
set LATEST_DEST=%BACKUP_DIR%\prod_latest

REM Resolve which backup to use
if not "%~1"=="" (
    set BACKUP_SUBFOLDER=%~1
    set SOURCE=%BACKUP_DIR%\%BACKUP_SUBFOLDER%
    if not exist "!SOURCE!" (
        echo Error: backup not found at !SOURCE!
        echo.
        echo Available backups:
        dir /b /ad "%BACKUP_DIR%\prod_*" 2>nul
        pause
        exit /b 1
    )
) else (
    REM Find most recently modified prod_2* folder
    set SOURCE=
    for /f "delims=" %%d in ('dir /b /ad /o-d "%BACKUP_DIR%\prod_2*" 2^>nul') do (
        if "!SOURCE!"=="" (
            set SOURCE=%BACKUP_DIR%\%%d
            set BACKUP_SUBFOLDER=%%d
        )
    )
    if "!SOURCE!"=="" (
        echo Error: no prod_* backups found in %BACKUP_DIR%\
        echo Run scripts\firestore_backup.bat first.
        pause
        exit /b 1
    )
)

echo === Copy Backup to Emulator ===
echo Source: %SOURCE%
echo Target: %LATEST_DEST%
echo.

REM Write firebase-export-metadata.json into the source folder
set METADATA_FILE=%BACKUP_SUBFOLDER%.overall_export_metadata
echo Writing %SOURCE%\firebase-export-metadata.json...
(
    echo {
    echo   "version": "15.11.0",
    echo   "firestore": {
    echo     "version": "1",
    echo     "path": ".",
    echo     "metadata_file": "%METADATA_FILE%"
    echo   }
    echo }
) > "%SOURCE%\firebase-export-metadata.json"
echo Done.

REM Update prod_latest
echo Updating %LATEST_DEST%...
if exist "%LATEST_DEST%" rmdir /s /q "%LATEST_DEST%"
xcopy /e /i /q "%SOURCE%" "%LATEST_DEST%\" >nul
echo Done.

echo.
echo Start the emulator with:
echo   firebase emulators:start --import=%LATEST_DEST%
echo.
echo Or with auto-export on exit:
echo   firebase emulators:start --import=%LATEST_DEST% --export-on-exit=%LATEST_DEST%
echo.

pause
endlocal
