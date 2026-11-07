import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-01] Trigger when a new user signs up on Firebase Auth (Email/Password or Google).
 * Automatically initializes Firestore User Profile with default fields and assigns custom claims { role: 'TOURIST' }.
 */
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userDocRef = db.collection('users').doc(user.uid);

  const initialProfile = {
    uid: user.uid,
    fullName: user.displayName || 'Du khách SmartTravel',
    email: user.email || '',
    phoneNumber: user.phoneNumber || '',
    avatarUrl: user.photoURL || '',
    role: 'TOURIST',
    loyaltyPoints: 0,
    totalEarnedPoints: 0,
    favoriteDestinationIds: [],
    isActive: true,
    fcmTokens: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await userDocRef.set(initialProfile, { merge: true });

  // Assign custom claims for RBAC rules (LI-02)
  await admin.auth().setCustomUserClaims(user.uid, { role: 'TOURIST' });
});
