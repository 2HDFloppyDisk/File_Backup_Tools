@echo off
setlocal enabledelayedexpansion

REM Change to the directory containing the 'src' folder
cd /d "%~dp0"

REM Define the backup directory
set BACKUP_DIR=_backups

REM Get the current date (in mm-dd-yyyy format)
for /f "tokens=2,3,4 delims=/- " %%a in ('echo %date%') do (
    set month=%%a
    set day=%%b
    set year=%%c
)

REM Get the current time (format: hh-mm-ss)
for /f "tokens=1-3 delims=: " %%a in ('echo %time%') do (
    set hour=%%a
    set minute=%%b
    set second=%%c
)

REM Remove spaces and add leading zero if hour is a single digit
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%

REM Trim the seconds to remove milliseconds
set second=%second:~0,2%

REM Format the timestamp as mm-dd-yyyy_hh-mm-ss
set datetime=%month%-%day%-%year%_%hour%-%minute%-%second%

REM Create the backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

REM Create a new folder inside _backups with the timestamp
set BACKUP_FOLDER=%BACKUP_DIR%\backup_%datetime%
mkdir "%BACKUP_FOLDER%"

REM Copy files to the new backup folder
echo Copying files to "%BACKUP_FOLDER%"
for /r src %%f in (*) do (
    if /i not "%%~nxf"=="embedded_audio_1.cpp" if /i not "%%~nxf"=="embedded_audio_2.cpp" if /i not "%%~nxf"=="embedded_audio_3.cpp" (
        echo Copying "%%f" to "%BACKUP_FOLDER%"
        copy "%%f" "%BACKUP_FOLDER%" >nul
    )
)

echo All files have been copied to the folder: "%BACKUP_FOLDER%"
pause
