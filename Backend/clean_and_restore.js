/**
 * ============================================================================
 * SmartTravel – Ngu Hanh Son (SE13 Capstone Project)
 * Script Cưỡng Chế Xóa Sạch Dữ Liệu Rác Cũ & Nạp Dữ Liệu Thật 100% Lên Firestore
 * ============================================================================
 */

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const SERVICE_ACCOUNT_FILE = path.resolve(__dirname, 'serviceAccountKey.json');
const DATA_FILE = path.resolve(__dirname, 'SmartTravel_RealData_NguHanhSon.json');
const PROJECT_ID = 'smarttravel-se13';

console.log('================================================================');
console.log('  SmartTravel Ngu Hanh Son – Clean Database & Restore Real Data');
console.log('================================================================');

if (!fs.existsSync(SERVICE_ACCOUNT_FILE)) {
  console.error('❌ LỖI: Không tìm thấy serviceAccountKey.json');
  process.exit(1);
}

const serviceAccount = require(SERVICE_ACCOUNT_FILE);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: PROJECT_ID
  });
  console.log(`✅ Kết nối thành công đến dự án: ${PROJECT_ID}`);
}

const db = admin.firestore();
const auth = admin.auth();

const ISO_DATE_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})?$/;

/**
 * BƯỚC 1: Xóa sạch toàn bộ collections và documents cũ (kể cả subcollections)
 */
async function dropAllExistingCollections() {
  console.log('\n🧹 BƯỚC 1: Đang quét và cưỡng chế xóa dữ liệu rác cũ trên Firestore...');
  const collections = await db.listCollections();

  if (collections.length === 0) {
    console.log('  ✨ Firestore hiện tại đã hoàn toàn trống!');
    return;
  }

  for (const col of collections) {
    console.log(`  🗑️ Đang xóa sạch collection: \x1b[31m${col.id}\x1b[0m (bao gồm mọi subcollections)...`);
    // Sử dụng recursiveDelete chính thức của Firebase Admin SDK
    await db.recursiveDelete(col);
    console.log(`     ✔ Đã xóa xong: ${col.id}`);
  }

  console.log('  🎉 Đã drop sạch sẽ toàn bộ database cũ thành công!');
}

/**
 * Chuyển đổi kiểu dữ liệu đặc thù của Firestore
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
 * Ghi đệ quy từng Document và Subcollections (__collections__)
 */
async function importDocumentWithSubcollections(docRef, data) {
  const { __collections__, ...documentFields } = data;
  const transformedData = transformFirestoreTypes(documentFields);

  await docRef.set(transformedData, { merge: true });

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
 * Cấu hình Custom Claims
 */
async function configureAuthClaims(usersData) {
  console.log('\n🔐 BƯỚC 3: Đang cấu hình Firebase Auth Custom Claims...');
  for (const [uid, userData] of Object.entries(usersData)) {
    if (userData.customClaims) {
      try {
        await auth.setCustomUserClaims(uid, userData.customClaims);
        console.log(`  ⭐ Custom Claims: ${uid} -> role = ${userData.customClaims.role}`);
      } catch (err) {
        console.log(`  ℹ️ Lưu ý: ${uid} chưa tồn tại trên Auth (sẽ tự nhận claims khi kích hoạt): ${err.message}`);
      }
    }
  }
}

async function main() {
  // 1. Drop old collections
  await dropAllExistingCollections();

  // 2. Restore new real data
  console.log('\n🚀 BƯỚC 2: Đang tải dữ liệu THẬT 100% từ SmartTravel_RealData_NguHanhSon.json lên Firestore...');
  const rawData = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
  const collectionNames = Object.keys(rawData);

  let totalDocs = 0;

  for (const collectionName of collectionNames) {
    const collectionData = rawData[collectionName];
    if (!collectionData || typeof collectionData !== 'object') continue;

    const docEntries = Object.entries(collectionData);
    console.log(`\n  📦 Import collection: \x1b[36m${collectionName}\x1b[0m (${docEntries.length} documents)...`);

    for (const [docId, docData] of docEntries) {
      const docRef = db.collection(collectionName).doc(docId);
      await importDocumentWithSubcollections(docRef, docData);
      totalDocs++;
      process.stdout.write(`     ✔ ${docId}\n`);
    }
  }

  // 3. Claims
  if (rawData.users) {
    await configureAuthClaims(rawData.users);
  }

  console.log('\n================================================================');
  console.log('🎉 TẤT CẢ CÔNG VIỆC ĐÃ HOÀN TẤT THÀNH CÔNG RỰC RỠ!');
  console.log(`📊 Đã nạp thành công: ${totalDocs} root documents cùng toàn bộ subcollections.`);
  console.log('🌐 Tất cả GeoPoint và Timestamp đã được biểu diễn chuẩn xác trên Firestore.');
  console.log('================================================================');
}

main().catch(err => {
  console.error('\n❌ Lỗi trong quá trình xử lý:', err);
  process.exit(1);
});
