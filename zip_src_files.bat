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

REM Initialize variables for file splitting
set count=0
set zip_count=1

REM Create a fixed temporary directory for zipping files
set TEMP_DIR=%TEMP%\temp_zip_folder
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Copy files to temporary directory and create ZIPs with a maximum of 20 files each
for /r src %%f in (*) do (
    if /i not "%%~nxf"=="embedded_audio_1.cpp" if /i not "%%~nxf"=="embedded_audio_2.cpp" if /i not "%%~nxf"=="embedded_audio_3.cpp" (
        REM Copy the file to the temporary directory
        echo Copying "%%f" to "%TEMP_DIR%"
        copy "%%f" "%TEMP_DIR%" >nul
        set /a count+=1

        REM If the count reaches 20, create a ZIP file
        if !count! geq 20 (
            set OUTPUT_ZIP=src_files_part!zip_count!_!datetime!.zip
            echo Creating ZIP: "!OUTPUT_ZIP!"
            powershell -command "Compress-Archive -Path '!TEMP_DIR!\*' -DestinationPath '%BACKUP_DIR%\\!OUTPUT_ZIP!'"

            REM Clear the temporary directory for the next batch
            del /q "!TEMP_DIR!\*"
            set /a zip_count+=1
            set count=0
        )
    )
)


REM Create a zip file for the remaining files in the last set if the directory is not empty
if exist "%TEMP_DIR%\*" (
    set OUTPUT_ZIP=src_files_part!zip_count!_!datetime!.zip
    echo Creating final ZIP: "!OUTPUT_ZIP!"
    powershell -command "Compress-Archive -Path '!TEMP_DIR!\*' -DestinationPath '%BACKUP_DIR%\\!OUTPUT_ZIP!'"
)

REM Remove the temporary directory
rd /s /q "%TEMP_DIR%"

echo Files from 'src' have been split into ZIPs with a maximum of 20 files each in the %BACKUP_DIR% directory, excluding embedded_audio.cpp
pause
