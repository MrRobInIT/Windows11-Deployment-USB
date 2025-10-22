@echo off
setlocal enabledelayedexpansion

REM Log file
set LOGFILE=C:\Windows\Temp\PostOOBE.log
echo PostOOBE Script Started: %DATE% %TIME% > %LOGFILE%

REM Detect USB data partition
set DATA_DRIVE=
for %%D in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%D:\Drivers\ (
        set DATA_DRIVE=%%D:
        echo Data partition found: %%D: >> %LOGFILE%
        goto :FoundDataDrive
    )
)

:FoundDataDrive
if "%DATA_DRIVE%"=="" (
    echo ERROR: Data partition not found! >> %LOGFILE%
    goto :Cleanup
)

REM Detect system model
for /f "tokens=2 delims==" %%i in ('wmic computersystem get model /value') do set MODEL=%%i
echo System Model: %MODEL% >> %LOGFILE%

REM Map model to driver folder
set DRIVER_FOLDER=
if /i "%MODEL%"=="Latitude 5440" set DRIVER_FOLDER=Latitude_5440
if /i "%MODEL%"=="Latitude 7440" set DRIVER_FOLDER=Latitude_7440
if /i "%MODEL%"=="Precision 3581" set DRIVER_FOLDER=Precision_3581
if /i "%MODEL%"=="OptiPlex 7010" set DRIVER_FOLDER=OptiPlex_7010
if /i "%MODEL%"=="OptiPlex 7020" set DRIVER_FOLDER=OptiPlex_7020

REM Install remaining drivers via PnPUtil
if not "%DRIVER_FOLDER%"=="" (
    if exist "%DATA_DRIVE%\Drivers\%DRIVER_FOLDER%" (
        echo Installing drivers from %DATA_DRIVE%\Drivers\%DRIVER_FOLDER% >> %LOGFILE%
        pnputil /add-driver %DATA_DRIVE%\Drivers\%DRIVER_FOLDER%\*.inf /subdirs /install >> %LOGFILE% 2>&1
    )
)

REM Install Dell Command | Update if available
if exist "%DATA_DRIVE%\Apps\Dell-Command-Update*.exe" (
    echo Installing Dell Command Update... >> %LOGFILE%
    for %%F in ("%DATA_DRIVE%\Apps\Dell-Command-Update*.exe") do (
        start /wait "" "%%F" /s >> %LOGFILE% 2>&1
    )
)

REM Apply BIOS updates if available
if exist "%DATA_DRIVE%\BIOS\%DRIVER_FOLDER%" (
    echo Applying BIOS updates... >> %LOGFILE%
    for %%F in ("%DATA_DRIVE%\BIOS\%DRIVER_FOLDER%\*.exe") do (
        start /wait "" "%%F" /s /f >> %LOGFILE% 2>&1
    )
)

:Cleanup
REM Remove PostOOBE folder
echo Cleaning up PostOOBE... >> %LOGFILE%
rd /s /q C:\PostOOBE >> %LOGFILE% 2>&1

echo PostOOBE Script Completed: %DATE% %TIME% >> %LOGFILE%
exit
