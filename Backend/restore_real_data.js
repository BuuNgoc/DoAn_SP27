/**
 * ============================================================================
 * SmartTravel – Ngu Hanh Son (SE13 Capstone Project)
 * Script Restore Dữ Liệu Thật 100% Lên Cloud Firestore
 *
 * Tác giả: Nhóm SE13 - Đại học FPT Đà Nẵng
 * ============================================================================
 *
 * Cách chạy:
 *   1. Đảm bảo file `serviceAccountKey.json` đã được đặt tại thư mục `Backend/`
 *   2. Cài đặt thư viện:
 *      npm install firestore-export-import firebase-admin
 *   3. Chạy script:
 *      node restore_real_data.js
 */

const fs = require('fs');
const path = require('path');

// Đường dẫn file cấu hình và dữ liệu
const SERVICE_ACCOUNT_FILE = path.resolve(__dirname, 'serviceAccountKey.json');
const DATA_FILE = path.resolve(__dirname, 'SmartTravel_RealData_NguHanhSon.json');
const PROJECT_ID = 'smarttravel-se13';

console.log('================================================================');
console.log('  SmartTravel Ngu Hanh Son – Firestore Restore Real Data Script');
console.log('================================================================');

// 1. Kiểm tra file serviceAccountKey.json
if (!fs.existsSync(SERVICE_ACCOUNT_FILE)) {
  console.error('\n❌ LỖI: Không tìm thấy file `serviceAccountKey.json` tại:');
  console.error(`   ${SERVICE_ACCOUNT_FILE}`);
  console.error('\n👉 Hướng dẫn khắc phục:');
  console.error('   1. Truy cập: https://console.firebase.google.com/project/smarttravel-se13/settings/serviceaccounts/adminsdk');
  console.error('   2. Nhấn nút "Generate new private key" (Tạo khóa riêng tư mới).');
  console.error('   3. Đổi tên file tải về thành `serviceAccountKey.json` và đặt vào thư mục `Backend/`.');
  process.exit(1);
}

// 2. Kiểm tra file dữ liệu SmartTravel_RealData_NguHanhSon.json
if (!fs.existsSync(DATA_FILE)) {
  console.error('\n❌ LỖI: Không tìm thấy file dữ liệu:');
  console.error(`   ${DATA_FILE}`);
  process.exit(1);
}

// 3. Khởi tạo thư viện và kết nối Firebase Admin
let admin;
try {
  admin = require('firebase-admin');
} catch (e) {
  try {
    admin = require(path.resolve(__dirname, 'functions/node_modules/firebase-admin'));
  } catch (err) {
    console.error('❌ Vui lòng cài đặt firebase-admin: npm install firebase-admin');
    process.exit(1);
  }
}

const serviceAccount = require(SERVICE_ACCOUNT_FILE);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID
  });
  console.log(`✅ Khởi tạo Firebase Admin thành công với dự án: ${PROJECT_ID}`);
}

const db = admin.firestore();
const auth = admin.auth();

// Biểu thức chính quy phát hiện định dạng ngày giờ ISO 8601
const ISO_DATE_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})?$/;

/**
 * Hàm đệ quy tự động chuyển đổi các kiểu dữ liệu đặc thù của Firestore:
 * - Chuỗi ngày tháng ISO 8601 -> admin.firestore.Timestamp
 * - Object chứa { latitude, longitude } -> admin.firestore.GeoPoint
 */
function transformFirestoreTypes(value) {
  if (value === null || value === undefined) {
    return value;
  }

  // 1. Chuyển đổi GeoPoint nếu là object có vĩ độ và kinh độ số
  if (
    typeof value === 'object' &&
    !Array.isArray(value) &&
    typeof value.latitude === 'number' &&
    typeof value.longitude === 'number' &&
    Object.keys(value).length === 2
  ) {
    return new admin.firestore.GeoPoint(value.latitude, value.longitude);
  }

  // 2. Chuyển đổi chuỗi ISO 8601 sang Timestamp
  if (typeof value === 'string' && ISO_DATE_REGEX.test(value)) {
    const parsedDate = new Date(value);
    if (!isNaN(parsedDate.getTime())) {
      return admin.firestore.Timestamp.fromDate(parsedDate);
    }
  }

  // 3. Đệ quy cho mảng
  if (Array.isArray(value)) {
    return value.map(item => transformFirestoreTypes(item));
  }

  // 4. Đệ quy cho object
  if (typeof value === 'object' && value.constructor === Object) {
    const result = {};
    for (const [k, v] of Object.entries(value)) {
      result[k] = transformFirestoreTypes(v);
    }
    return result;
  }

  return value;
}

/**
 * Ghi đệ quy từng Collection và Sub-collection (theo cấu trúc __collections__)
 */
async function importDocumentWithSubcollections(docRef, data) {
  const { __collections__, ...documentFields } = data;
  const transformedData = transformFirestoreTypes(documentFields);

  // Ghi document chính
  await docRef.set(transformedData, { merge: true });

  // Nếu có sub-collections lồng bên trong
  if (__collections__ && typeof __collections__ === 'object') {
    for (const [subColName, subDocs] of Object.entries(__collections__)) {
      for (const [subDocId, subDocData] of Object.entries(subDocs)) {
        const subDocRef = docRef.collection(subColName).doc(subDocId);
        await importDocumentWithSubcollections(subDocRef, subDocData);
      }
    }
  }
}

/**
 * Thiết lập Custom Claims cho các tài khoản Quản trị & Du khách
 */
async function assignAuthCustomClaims(usersData) {
  console.log('\n🔐 Đang cấu hình Firebase Auth Custom Claims cho người dùng...');
  for (const [uid, userData] of Object.entries(usersData)) {
    if (userData.customClaims) {
      try {
        await auth.setCustomUserClaims(uid, userData.customClaims);
        console.log(`  ⭐ Đã gán Custom Claims cho ${uid} (${userData.fullName}): role = ${userData.customClaims.role}`);
      } catch (err) {
        console.warn(`  ⚠️ Lưu ý: Chưa thể gán Custom Claims cho ${uid} (Người dùng chưa đăng nhập Auth lần nào: ${err.message})`);
      }
    }
  }
}

/**
 * Chương trình chính
 */
async function main() {
  console.log(`\n📂 Đang đọc dữ liệu từ: ${path.basename(DATA_FILE)}...`);
  const rawData = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  const collectionNames = Object.keys(rawData);
  console.log(`📦 Tìm thấy ${collectionNames.length} root collections:`, collectionNames.join(', '));

  let totalDocs = 0;

  for (const collectionName of collectionNames) {
    const collectionData = rawData[collectionName];
    if (!collectionData || typeof collectionData !== 'object') continue;

    const docEntries = Object.entries(collectionData);
    console.log(`\n🚀 Đang import collection: \x1b[36m${collectionName}\x1b[0m (${docEntries.length} documents)...`);

    for (const [docId, docData] of docEntries) {
      const docRef = db.collection(collectionName).doc(docId);
      await importDocumentWithSubcollections(docRef, docData);
      totalDocs++;
      process.stdout.write(`  ✔ Document: ${docId}\n`);
    }
  }

  // Cấu hình Custom Claims nếu có collection users
  if (rawData.users) {
    await assignAuthCustomClaims(rawData.users);
  }

  console.log('\n================================================================');
  console.log(`🎉 HOÀN THÀNH XUẤT SẮC!`);
  console.log(`📊 Tổng cộng đã import: ${totalDocs} root documents cùng toàn bộ subcollections.`);
  console.log(`🌐 Tọa độ GeoPoint và thời gian Timestamp đã được chuyển đổi chính xác.`);
  console.log('================================================================');
}

main().catch(err => {
  console.error('\n❌ Đã xảy ra lỗi nghiêm trọng trong quá trình restore:', err);
  process.exit(1);
});
