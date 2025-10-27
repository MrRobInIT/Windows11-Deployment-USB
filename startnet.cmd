:: =========================================================
:: startnet cmd for Hudson Automotive Group IT PC imaging
:: Robert Moss 17OCT25
:: =========================================================

@echo off
wpeinit
color 1F
echo.
echo ============================================
echo   Windows 11 Deployment - Dell Systems
echo ============================================
echo.
echo Starting deployment script...
echo.

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

%BOOT_DRIVE%\Deploy\apply.cmd

