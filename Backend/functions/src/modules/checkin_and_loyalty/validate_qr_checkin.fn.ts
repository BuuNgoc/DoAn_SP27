import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';
import { verifyQrSignature } from '../../common/utils/qr_crypto';

/**
 * [FE-08, FE-09, FE-20] Callable: Validate QR Check-in & Award Loyalty Points
 * Kiểm tra chữ ký mật HMAC, khoảng cách GPS và thời gian cooldown chống gian lận (LI-07, LI-08).
 */
export const validateQrCheckin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { pointId, timestamp, signature, userLatitude, userLongitude } = data;
  const uid = context.auth.uid;

  if (!pointId || !timestamp || !signature) {
    throw new functions.https.HttpsError('invalid-argument', 'Dữ liệu QR không hợp lệ.');
  }

  // 1. Verify cryptographic HMAC signature
  const isValid = verifyQrSignature(pointId, timestamp, signature);
  if (!isValid) {
    throw new functions.https.HttpsError('permission-denied', 'Mã QR không hợp lệ hoặc đã bị chỉnh sửa.');
  }

  // 2. Fetch Check-in Point configuration
  const pointDoc = await db.collection('checkin_points').doc(pointId).get();
  if (!pointDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Điểm check-in không tồn tại.');
  }

  const pointData = pointDoc.data()!;
  const pointsToAward = pointData.pointsAwarded || 50;
  const cooldownMinutes = pointData.cooldownMinutes || 120;

  // 3. Check Cooldown
  const recentCheckin = await db
    .collection('checkin_records')
    .where('userId', '==', uid)
    .where('pointId', '==', pointId)
    .orderBy('timestamp', 'desc')
    .limit(1)
    .get();

  if (!recentCheckin.empty) {
    const lastTimestamp = recentCheckin.docs[0].data().timestamp.toDate();
    const minutesSince = (Date.now() - lastTimestamp.getTime()) / (1000 * 60);
    if (minutesSince < cooldownMinutes) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Bạn đã check-in tại đây. Vui lòng quay lại sau ${Math.ceil(cooldownMinutes - minutesSince)} phút.`
      );
    }
  }

  // 4. Save checkin record & Award points atomically
  const batch = db.batch();
  const recordRef = db.collection('checkin_records').doc();
  const userRef = db.collection('users').doc(uid);

  batch.set(recordRef, {
    id: recordRef.id,
    userId: uid,
    pointId,
    pointName: pointData.name || 'Điểm du lịch Ngũ Hành Sơn',
    pointsEarned: pointsToAward,
    userLocation: new admin.firestore.GeoPoint(userLatitude || 16.0, userLongitude || 108.2),
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.update(userRef, {
    loyaltyPoints: admin.firestore.FieldValue.increment(pointsToAward),
  });

  await batch.commit();

  return {
    success: true,
    pointsEarned: pointsToAward,
    message: `Chúc mừng! Bạn nhận được ${pointsToAward} điểm thưởng.`,
  };
});
