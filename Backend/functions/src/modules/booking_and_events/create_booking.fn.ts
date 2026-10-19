import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-07, FE-19] Callable: Transactional Event & Workshop Booking
 * Đảm bảo kiểm tra dung lượng maxCapacity và trừ currentParticipants nguyên tử (LI-07).
 */
export const createBooking = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Vui lòng đăng nhập.');
  }

  const { serviceId, serviceType, participantsCount } = data;
  const count = Number(participantsCount) || 1;

  if (!serviceId || count <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Dữ liệu đặt chỗ không hợp lệ.');
  }

  const serviceRef = db.collection('events_workshops').doc(serviceId);
  const bookingRef = db.collection('bookings').doc();

  return await db.runTransaction(async (transaction) => {
    const serviceDoc = await transaction.get(serviceRef);
    if (!serviceDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Không tìm thấy sự kiện/workshop.');
    }

    const serviceData = serviceDoc.data()!;
    const maxCapacity = serviceData.maxCapacity || 50;
    const current = serviceData.currentParticipants || 0;

    if (current + count > maxCapacity) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Sự kiện/workshop đã hết chỗ khả dụng.'
      );
    }

    // Increment participants
    transaction.update(serviceRef, {
      currentParticipants: admin.firestore.FieldValue.increment(count),
    });

    // Create booking record
    transaction.set(bookingRef, {
      id: bookingRef.id,
      userId: context.auth!.uid,
      serviceId,
      serviceType: serviceType || 'workshop',
      eventTitle: serviceData.title?.vi || serviceData.title || 'Sự kiện',
      participantsCount: count,
      status: 'CONFIRMED',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      bookingId: bookingRef.id,
      message: 'Đặt chỗ thành công!',
    };
  });
});
