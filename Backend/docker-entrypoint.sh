#!/bin/sh
set -e

# Đảm bảo thư mục lưu trữ dữ liệu emulator tồn tại
mkdir -p /workspace/emulator-data

echo "======================================================================"
echo "  NHS360 - SMART TRAVEL BACKEND & DATABASE (SE13)"
echo "  Khoi chay Firebase Emulators Suite..."
echo "  - Emulator UI:        http://localhost:4000"
echo "  - Cloud Functions:    http://localhost:5001"
echo "  - Firestore Database: http://localhost:8080"
echo "  - Firebase Auth:      http://localhost:9099"
echo "  - Cloud Storage:      http://localhost:9199"
echo "======================================================================"

# Khởi chạy Firebase Emulators với tính năng tự động export/import dữ liệu khi dừng/chạy container
if [ -d "/workspace/emulator-data" ] && [ "$(ls -A /workspace/emulator-data 2>/dev/null)" ]; then
    echo "[*] Phat hien du lieu emulator cu, dang tien hanh import..."
    exec firebase emulators:start \
        --project smarttravel-se13 \
        --import=/workspace/emulator-data \
        --export-on-exit=/workspace/emulator-data
else
    echo "[*] Khoi chay emulator lan dau (chua co du lieu mau san co)..."
    exec firebase emulators:start \
        --project smarttravel-se13 \
        --export-on-exit=/workspace/emulator-data
fi
