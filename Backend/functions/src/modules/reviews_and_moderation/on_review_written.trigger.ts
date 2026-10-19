import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';

/**
 * [FE-10] Firestore Trigger: Recalculates Destination ratingAvg and reviewCount
 */
export const onReviewWritten = functions.firestore
  .document('destinations/{destinationId}/reviews/{reviewId}')
  .onWrite(async (change, context) => {
    const destinationId = context.params.destinationId;
    const reviewsSnapshot = await db
      .collection('destinations')
      .doc(destinationId)
      .collection('reviews')
      .get();

    if (reviewsSnapshot.empty) {
      await db.collection('destinations').doc(destinationId).update({
        ratingAvg: 5.0,
        reviewCount: 0,
      });
      return;
    }

    let totalRating = 0;
    reviewsSnapshot.forEach((doc) => {
      totalRating += (doc.data().rating || 5);
    });

    const ratingAvg = Math.round((totalRating / reviewsSnapshot.size) * 10) / 10;

    await db.collection('destinations').doc(destinationId).update({
      ratingAvg,
      reviewCount: reviewsSnapshot.size,
    });
  });
