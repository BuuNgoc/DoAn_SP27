import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-16, FE-22] Callable: Stone Carving Contest Voting
 * Ngăn chặn du khách bình chọn trùng lặp cho một tác phẩm.
 */
export const voteContestEntry = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập để bình chọn.');
  }

  const { contestId, entryId } = data;
  const uid = context.auth.uid;
  const voteDocRef = db.collection('stone_carving_contests').doc(contestId).collection('votes').doc(`${uid}_${entryId}`);
  const entryDocRef = db.collection('stone_carving_contests').doc(contestId).collection('entries').doc(entryId);

  return await db.runTransaction(async (transaction) => {
    const voteDoc = await transaction.get(voteDocRef);
    if (voteDoc.exists) {
      throw new functions.https.HttpsError('already-exists', 'Bạn đã bình chọn cho tác phẩm này rồi.');
    }

    transaction.set(voteDocRef, {
      userId: uid,
      contestId,
      entryId,
      votedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(entryDocRef, {
      voteCount: admin.firestore.FieldValue.increment(1),
    });

    return { success: true, message: 'Bình chọn thành công!' };
  });
});
