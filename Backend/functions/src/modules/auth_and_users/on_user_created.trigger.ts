import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import * as admin from 'firebase-admin';

/**
 * [FE-01] Trigger when a new user signs up
 * Automatically initializes Firestore User Profile with role 'TOURIST' and 0 loyalty points.
 */
export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const userDocRef = db.collection('users').doc(user.uid);
  
  await userDocRef.set({
    uid: user.uid,
    email: user.email || '',
    fullName: user.displayName || 'Du khách',
    role: 'TOURIST',
    loyaltyPoints: 0,
    favoriteDestinationIds: [],
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Assign custom claims
  await admin.auth().setCustomUserClaims(user.uid, { role: 'TOURIST' });
});
