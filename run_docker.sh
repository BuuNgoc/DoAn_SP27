#!/bin/bash
set -e

echo "==================================================================="
echo "  NHS360 - NEN TANG DU LICH THONG MINH NGU HANH SON (NHOM SE13)"
echo "  Dang khoi chay toan bo he thong bang Docker..."
echo "==================================================================="
echo ""

docker-compose up -d --build

echo ""
echo "==================================================================="
echo "  HE THONG KHOI CHAY HOAN TAT:"
echo "  - Frontend Web App:     http://localhost:8000"
echo "  - Firebase Emulator UI: http://localhost:4000"
echo "  - Firestore Database:   http://localhost:8080"
echo "  - Cloud Functions API:  http://localhost:5001"
echo "  - Firebase Auth:        http://localhost:9099"
echo "  - Cloud Storage:        http://localhost:9199"
echo "==================================================================="
