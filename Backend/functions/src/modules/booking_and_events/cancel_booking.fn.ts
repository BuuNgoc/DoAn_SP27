import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-07] Callable: Cancel Booking & Restore Capacity
 */
export const cancelBooking = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { bookingId } = data;
  if (!bookingId) {
    throw new functions.https.HttpsError('invalid-argument', 'Thiếu mã đơn đặt chỗ.');
  }

  const bookingRef = db.collection('bookings').doc(bookingId);

  return await db.runTransaction(async (transaction) => {
    const bookingDoc = await transaction.get(bookingRef);
    if (!bookingDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Không tìm thấy đơn đặt chỗ.');
    }

    const booking = bookingDoc.data()!;
    if (booking.userId !== context.auth!.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Bạn không sở hữu đơn đặt chỗ này.');
    }

    if (booking.status === 'CANCELLED') {
      return { success: true, message: 'Đơn đặt chỗ đã được hủy trước đó.' };
    }

    const serviceRef = db.collection('events_workshops').doc(booking.serviceId);
    transaction.update(serviceRef, {
      currentParticipants: admin.firestore.FieldValue.increment(-booking.participantsCount),
    });

    transaction.update(bookingRef, {
      status: 'CANCELLED',
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: 'Đã hủy đặt chỗ thành công.' };
  });
});
