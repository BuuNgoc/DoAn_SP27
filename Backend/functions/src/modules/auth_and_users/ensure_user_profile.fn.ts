import * as functions from 'firebase-functions';
import { auth, db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-01, FE-26] Callable Function: ensureUserProfile
 * Synchronously ensures user profile document exists immediately after Google Sign-In or new registration,
 * avoiding cold-start latency of Auth triggers, checks account status (isActive), and returns user profile & role.
 */
export const ensureUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Yêu cầu xác thực tài khoản trước khi thực hiện.'
    );
  }

  const uid = context.auth.uid;
  const userDocRef = db.collection('users').doc(uid);
  const userSnapshot = await userDocRef.get();

  if (!userSnapshot.exists) {
    // Fetch user details from Firebase Auth
    const userRecord = await auth.getUser(uid);

    const newUserData = {
      uid: userRecord.uid,
      fullName: userRecord.displayName || (data?.fullName as string) || 'Du khách SmartTravel',
      email: userRecord.email || '',
      phoneNumber: userRecord.phoneNumber || (data?.phoneNumber as string) || '',
      avatarUrl: userRecord.photoURL || '',
      role: 'TOURIST',
      loyaltyPoints: 0,
      totalEarnedPoints: 0,
      favoriteDestinationIds: [],
      isActive: true,
      fcmTokens: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await userDocRef.set(newUserData, { merge: true });
    await auth.setCustomUserClaims(uid, { role: 'TOURIST' });

    return {
      ...newUserData,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
  }

  const existingData = userSnapshot.data() || {};

  // Check account lock status (FE-26)
  if (existingData.isActive === false) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Tài khoản của bạn đã bị khóa bởi Quản trị viên.'
    );
  }

  return {
    ...existingData,
    uid,
  };
});
