@echo off
title NHS360 Smart Travel - Android Emulator
echo ===================================================================
echo   NHS360 - NEN TANG DU LICH THONG MINH NGU HANH SON (NHOM SE13)
echo   Dang khoi chay ung dung tren Gia Lap Android...
echo ===================================================================
echo.

rem 1. Them Flutter va Android SDK vao PATH de luon chay dung
set "PATH=%LOCALAPPDATA%\Android\Sdk\emulator;%LOCALAPPDATA%\Android\Sdk\platform-tools;C:\Users\Lenovo\flutter\bin;%PATH%"

rem 2. Xu ly cat bo dau gach cheo cuoi cung de lenh subst khong bi loi cu phap
set "CURRENT_DIR=%~dp0"
if "%CURRENT_DIR:~-1%"=="\" set "CURRENT_DIR=%CURRENT_DIR:~0,-1%"

if not exist "X:\" (
    subst X: "%CURRENT_DIR%"
)

rem 3. Kiem tra may ao Android, neu chua bat thi tu dong khoi dong Pixel_7a
echo [1/2] Kiem tra may ao Android...
adb devices | findstr /R "emulator-[0-9]*" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [!] May ao chua bat. Dang khoi dong gia lap Pixel_7a...
    del /f /s /q "%USERPROFILE%\.android\avd\Pixel_7a.avd\*.lock" >nul 2>&1
    rmdir /s /q "%USERPROFILE%\.android\avd\Pixel_7a.avd\hardware-qemu.ini.lock" >nul 2>&1
    start "" emulator -avd Pixel_7a
    echo [*] Dang cho may ao ket noi, vui long doi giay lat...
    adb wait-for-device
    echo [*] May ao da ket noi!
) else (
    echo [*] May ao Android da san sang!
)

rem 4. Chay ung dung tren may ao
echo.
echo [2/2] Dang build va chay ung dung Flutter Mobile...
cd /d "X:\Mobile"
flutter run
pause
