import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-10] Callable: Tourist reports an offensive review
 */
export const reportReview = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { destinationId, reviewId, reason } = data;
  if (!destinationId || !reviewId || !reason) {
    throw new functions.https.HttpsError('invalid-argument', 'Dữ liệu không đầy đủ.');
  }

  await db.collection('system_administration').doc('review_reports').collection('reports').add({
    reporterUid: context.auth.uid,
    destinationId,
    reviewId,
    reason,
    status: 'PENDING_REVIEW',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, message: 'Đã gửi báo cáo đánh giá.' };
});
