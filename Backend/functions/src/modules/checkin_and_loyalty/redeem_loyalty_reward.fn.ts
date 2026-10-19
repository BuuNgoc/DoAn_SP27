import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-09, FE-20] Callable: Redeem Loyalty Reward Voucher
 * Trừ điểm tích lũy an toàn và tạo mã voucher (LI-07).
 */
export const redeemLoyaltyReward = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { rewardId } = data;
  const uid = context.auth.uid;

  if (!rewardId) {
    throw new functions.https.HttpsError('invalid-argument', 'Thiếu mã phần thưởng.');
  }

  const rewardRef = db.collection('rewards').doc(rewardId);
  const userRef = db.collection('users').doc(uid);
  const redemptionRef = db.collection('reward_redemptions').doc();

  return await db.runTransaction(async (transaction) => {
    const [rewardDoc, userDoc] = await Promise.all([
      transaction.get(rewardRef),
      transaction.get(userRef),
    ]);

    if (!rewardDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Phần thưởng không tồn tại.');
    }
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Hồ sơ người dùng không tồn tại.');
    }

    const reward = rewardDoc.data()!;
    const user = userDoc.data()!;

    if (reward.stockQuantity <= 0) {
      throw new functions.https.HttpsError('resource-exhausted', 'Phần thưởng này đã hết số lượng.');
    }

    if (user.loyaltyPoints < reward.pointsRequired) {
      throw new functions.https.HttpsError('failed-precondition', 'Bạn không đủ điểm thưởng để đổi.');
    }

    // Deduct stock and points
    transaction.update(rewardRef, {
      stockQuantity: admin.firestore.FieldValue.increment(-1),
    });
    transaction.update(userRef, {
      loyaltyPoints: admin.firestore.FieldValue.increment(-reward.pointsRequired),
    });

    const voucherCode = `ST-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

    transaction.set(redemptionRef, {
      id: redemptionRef.id,
      userId: uid,
      rewardId,
      rewardTitle: reward.title?.vi || reward.title,
      pointsSpent: reward.pointsRequired,
      voucherCode,
      isUsed: false,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      voucherCode,
      message: 'Đổi quà thành công!',
    };
  });
});
