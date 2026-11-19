@echo off
chcp 65001 >nul
echo ==============================================================================
echo   KHỞI CHẠY NHS360 WEB ADMIN PORTAL (REACTJS + TYPESCRIPT)
echo ==============================================================================
echo.

cd /d "%~dp0Web"

if not exist "node_modules" (
    echo [1/2] Đang cài đặt thư viện npm...
    call npm install
)

echo [2/2] Đang khởi động Vite Dev Server tại http://localhost:3000 ...
echo.
call npm run dev
pause
