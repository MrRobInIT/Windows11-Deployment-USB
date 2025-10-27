@echo off
setlocal enabledelayedexpansion

color 1F
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
if /i "%MODEL%"=="Latitude 5440" set DRIVER_FOLDER=Latitude-5440
if /i "%MODEL%"=="Latitude 5540" set DRIVER_FOLDER=Latitude-5540
if /i "%MODEL%"=="Latitude 5550" set DRIVER_FOLDER=Latitude-5550
if /i "%MODEL%"=="Dell Pro 16 Plus PB16250" set DRIVER_FOLDER=PRO16250
if /i "%MODEL%"=="PRO QCM1250" set DRIVER_FOLDER=PRO-QCM1250
if /i "%MODEL%"=="OptiPlex 7020" set DRIVER_FOLDER=OptiPlex-7020Micro

if "%DRIVER_FOLDER%"=="" (
    echo WARNING: Unknown model. Driver injection may fail.
    echo Press any key to continue or Ctrl+C to abort...
    pause >nul
) else (
    echo Driver folder: %DRIVER_FOLDER%
)
echo.

REM Confirm deployment
color 4F
echo *********************************************************
echo.
echo  WARNING: This will ERASE ALL DATA on the internal disk!
echo.
echo  Press any key to continue or Ctrl+C to abort...
echo.
echo *********************************************************
pause >nul

cls
color 2F
echo.
echo Creating disk partitions...
diskpart /s %BOOT_DRIVE%\Deploy\createdisk_GPT.txt
if errorlevel 1 (
    echo ERROR: Disk partitioning failed!
    pause
    exit /b 1
)

cls
echo.
echo *******************************************
echo.
echo Applying Windows image from split files...
echo This may take 15-30 minutes...
echo.
echo *******************************************
dism /Apply-Image /ImageFile:%BOOT_DRIVE%\Deploy\Images\Win11GOLD.swm /SWMFile:%BOOT_DRIVE%\Deploy\Images\Win11GOLD*.swm /Index:1 /ApplyDir:W:\
if errorlevel 1 (
    echo ERROR: Image application failed!
    pause
    exit /b 1
)

cls
echo.
echo Creating boot files...
W:\Windows\System32\bcdboot W:\Windows /s S: /f UEFI
if errorlevel 1 (
    echo ERROR: Boot configuration failed!
    pause
    exit /b 1
)

REM Inject drivers if model detected
cls
color 9F
if not "%DRIVER_FOLDER%"=="" (
    if exist "%DATA_DRIVE%\Drivers\Dell\%DRIVER_FOLDER%" (
        echo.
        echo Injecting drivers for %MODEL%...
        echo This may take 10-20 minutes...
        dism /Image:W:\ /Add-Driver /Driver:%DATA_DRIVE%\Drivers\Dell\%DRIVER_FOLDER% /Recurse /ForceUnsigned
        if errorlevel 1 (
            echo WARNING: Some drivers failed to inject. Continuing...
        ) else (
            echo Driver injection completed successfully.
        )
    ) else (
        echo WARNING: Driver folder not found: %DATA_DRIVE%\Drivers\Dell\%DRIVER_FOLDER%
    )
)

REM Copy PostOOBE to Windows partition
cls
echo.
echo Copying PostOOBE scripts...
if exist %BOOT_DRIVE%\Deploy\PostOOBE (
    xcopy %BOOT_DRIVE%\Deploy\PostOOBE W:\PostOOBE\ /E /I /H /Y
    if errorlevel 1 (
        echo WARNING: PostOOBE copy failed!
    )
)

color AF
echo.
echo. ============================================
echo.            Deployment Complete!
echo.          Press enter to reboot...
echo.      Remove USB when computer reboots
echo. ============================================
echo.
echo.
pause
wpeutil reboot
