@echo off
setlocal enabledelayedexpansion

echo.
echo ============================================
echo   Windows 11 Deployment Script
echo ============================================
echo.

REM Identify USB drive letters
set BOOT_DRIVE=
set DATA_DRIVE=

echo Detecting USB partitions...
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%D:\Deploy\apply.cmd (
        set BOOT_DRIVE=%%D:
        echo Boot partition found: %%D:
    )
    if exist %%D:\Drivers\ (
        set DATA_DRIVE=%%D:
        echo Data partition found: %%D:
    )
)

if "%BOOT_DRIVE%"=="" (
    echo ERROR: Boot partition not found!
    pause
    exit /b 1
)

if "%DATA_DRIVE%"=="" (
    echo ERROR: Data partition with drivers not found!
    pause
    exit /b 1
)

echo.
echo Boot Partition: %BOOT_DRIVE%
echo Data Partition: %DATA_DRIVE%
echo.

REM Detect system model
echo Detecting system model...
for /f "tokens=2 delims==" %%i in ('wmic computersystem get model /value') do set MODEL=%%i
echo System Model: %MODEL%
echo.

REM Map model to driver folder
set DRIVER_FOLDER=
if /i "%MODEL%"=="Latitude 5440" set DRIVER_FOLDER=Latitude_5440
if /i "%MODEL%"=="Latitude 7440" set DRIVER_FOLDER=Latitude_7440
if /i "%MODEL%"=="Precision 3581" set DRIVER_FOLDER=Precision_3581
if /i "%MODEL%"=="OptiPlex 7010" set DRIVER_FOLDER=OptiPlex_7010
if /i "%MODEL%"=="OptiPlex 7020" set DRIVER_FOLDER=OptiPlex_7020

if "%DRIVER_FOLDER%"=="" (
    echo WARNING: Unknown model. Driver injection may fail.
    echo Press any key to continue or Ctrl+C to abort...
    pause >nul
) else (
    echo Driver folder: %DRIVER_FOLDER%
)
echo.

REM Confirm deployment
echo WARNING: This will ERASE ALL DATA on the internal disk!
echo.
echo Press any key to continue or Ctrl+C to abort...
pause >nul

echo.
echo Creating disk partitions...
diskpart /s %BOOT_DRIVE%\Deploy\createdisk_GPT.txt
if errorlevel 1 (
    echo ERROR: Disk partitioning failed!
    pause
    exit /b 1
)

echo.
echo Applying Windows image from split files...
echo This may take 15-30 minutes...
dism /Apply-Image /ImageFile:%BOOT_DRIVE%\Deploy\Images\install.swm /SWMFile:%BOOT_DRIVE%\Deploy\Images\install*.swm /Index:1 /ApplyDir:W:\
if errorlevel 1 (
    echo ERROR: Image application failed!
    pause
    exit /b 1
)

echo.
echo Creating boot files...
W:\Windows\System32\bcdboot W:\Windows /s S: /f UEFI
if errorlevel 1 (
    echo ERROR: Boot configuration failed!
    pause
    exit /b 1
)

REM Inject drivers if model detected
if not "%DRIVER_FOLDER%"=="" (
    if exist "%DATA_DRIVE%\Drivers\%DRIVER_FOLDER%" (
        echo.
        echo Injecting drivers for %MODEL%...
        echo This may take 10-20 minutes...
        dism /Image:W:\ /Add-Driver /Driver:%DATA_DRIVE%\Drivers\%DRIVER_FOLDER% /Recurse /ForceUnsigned
        if errorlevel 1 (
            echo WARNING: Some drivers failed to inject. Continuing...
        ) else (
            echo Driver injection completed successfully.
        )
    ) else (
        echo WARNING: Driver folder not found: %DATA_DRIVE%\Drivers\%DRIVER_FOLDER%
    )
)

REM Copy unattend.xml to Windows\Panther
echo.
echo Copying unattend.xml...
if not exist W:\Windows\Panther mkdir W:\Windows\Panther
copy /Y %BOOT_DRIVE%\Deploy\unattend.xml W:\Windows\Panther\unattend.xml
if errorlevel 1 (
    echo WARNING: unattend.xml copy failed!
) else (
    echo unattend.xml copied successfully.
)

REM Copy PostOOBE to Windows partition
echo.
echo Copying PostOOBE scripts...
if exist %BOOT_DRIVE%\Deploy\PostOOBE (
    xcopy %BOOT_DRIVE%\Deploy\PostOOBE W:\PostOOBE\ /E /I /H /Y
    if errorlevel 1 (
        echo WARNING: PostOOBE copy failed!
    ) else (
        echo PostOOBE scripts copied successfully.
    )
)

echo.
echo ============================================
echo   Deployment Complete!
echo ============================================
echo.
echo The system will reboot in 10 seconds...
echo Remove the USB drive after reboot.
echo.
timeout /t 10
wpeutil reboot
