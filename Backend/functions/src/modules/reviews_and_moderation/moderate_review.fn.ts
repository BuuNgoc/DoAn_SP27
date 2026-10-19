import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import { assertHasRole } from '../../common/middlewares/role_guard';
import { logAuditEvent } from '../../common/utils/audit_logger';

/**
 * [FE-10, FE-28] Manager/Admin Callable: Moderate or Remove Inappropriate Review
 */
export const moderateReview = functions.https.onCall(async (data, context) => {
  await assertHasRole(context, ['TOURISM_MANAGER', 'ADMIN']);

  const { destinationId, reviewId, action } = data; // action: 'REMOVE' | 'KEEP'
  if (!destinationId || !reviewId || !['REMOVE', 'KEEP'].includes(action)) {
    throw new functions.https.HttpsError('invalid-argument', 'Tham số không hợp lệ.');
  }

  if (action === 'REMOVE') {
    await db
      .collection('destinations')
      .doc(destinationId)
      .collection('reviews')
      .doc(reviewId)
      .delete();
  }

  await logAuditEvent({
    actorUid: context.auth!.uid,
    actorRole: 'TOURISM_MANAGER',
    action: `MODERATE_REVIEW_${action}`,
    targetCollection: 'reviews',
    targetId: reviewId,
  });

  return { success: true, action };
});
