@echo off
title NHS360 Smart Travel - Port 8000
echo ===================================================================
echo   NHS360 - NEN TANG DU LICH THONG MINH NGU HANH SON (NHOM SE13)
echo   Dang khoi chay ung dung tren Google Chrome tai cong 8000...
echo   URL: http://localhost:8000/
echo ===================================================================
echo.
cd /d "%~dp0Frontend"
flutter run -d chrome --web-port 8000 --no-tree-shake-icons
pause
