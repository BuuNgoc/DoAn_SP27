/**
 * ============================================================================
 * SmartTravel – Ngu Hanh Son
 * Restore Script sử dụng trực tiếp thư viện `firestore-export-import`
 * ============================================================================
 *
 * Cài đặt thư viện:
 *   npm install firestore-export-import
 *
 * Chạy lệnh:
 *   node restore_with_library.js
 */

const path = require('path');
const fs = require('fs');
const { initializeFirebaseApp, restore } = require('firestore-export-import');

const SERVICE_ACCOUNT = path.resolve(__dirname, 'serviceAccountKey.json');
const JSON_FILE = path.resolve(__dirname, 'SmartTravel_RealData_NguHanhSon.json');

async function run() {
  if (!fs.existsSync(SERVICE_ACCOUNT)) {
    console.error('❌ Thiếu file serviceAccountKey.json trong thư mục Backend!');
    process.exit(1);
  }

  console.log('🔄 Đang khởi tạo kết nối qua firestore-export-import...');
  const app = initializeFirebaseApp(SERVICE_ACCOUNT);

  console.log('🚀 Đang tải dữ liệu thật từ SmartTravel_RealData_NguHanhSon.json lên Firestore...');
  
  // Tùy chọn chuyển đổi tự động ngày tháng và tọa độ địa lý
  const options = {
    autoParseDates: true,
    geolocations: [
      'geopoint',
      'location.geopoint',
      'deviceLocation'
    ]
  };

  await restore(JSON_FILE, options);

  console.log('🎉 Tải dữ liệu thành công lên Cloud Firestore!');
}

run().catch(err => {
  console.error('❌ Lỗi khi import:', err);
  process.exit(1);
});
