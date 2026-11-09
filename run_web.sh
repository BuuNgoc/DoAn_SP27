#!/bin/bash
echo "==================================================================="
echo "  NHS360 - NEN TANG DU LICH THONG MINH NGU HANH SON (NHOM SE13)"
echo "  Dang khoi chay ung dung tren Chrome cong 8000..."
echo "  URL: http://localhost:8000/"
echo "==================================================================="
cd "$(dirname "$0")/Frontend" || exit
flutter run -d chrome --web-port 8000

