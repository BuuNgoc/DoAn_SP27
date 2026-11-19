import { initializeApp, getApps, getApp, FirebaseApp } from 'firebase/app';
import {
  getAuth,
  signInWithEmailAndPassword,
  signOut as fbSignOut,
  onAuthStateChanged,
  User as FirebaseUser,
  Auth,
} from 'firebase/auth';
import {
  getFirestore,
  doc,
  getDoc,
  Firestore,
} from 'firebase/firestore';

// Configuration from Mobile/lib/firebase_options.dart
export const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || 'AIzaSyBcIRU-3DtPCDveyT6ZiDkw2FLPSlraZzg',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || 'smarttravel-se13.firebaseapp.com',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || 'smarttravel-se13',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || 'smarttravel-se13.firebasestorage.app',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '462033431838',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '1:462033431838:web:3512ce9388d23f187e2d0f',
};

// Initialize Firebase safely
let app: FirebaseApp;
if (!getApps().length) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApp();
}

export const auth: Auth = getAuth(app);
export const db: Firestore = getFirestore(app);

export type UserRole = 'ADMIN' | 'TOURISM_MANAGER' | 'TOURIST';

export interface AdminUserProfile {
  uid: string;
  email: string | null;
  displayName: string | null;
  role: UserRole;
  department?: string;
  phoneNumber?: string;
  avatarUrl?: string;
}

/**
 * Fetch role for authenticated user:
 * 1. Checks Firebase Auth Token Custom Claims (token.role)
 * 2. Checks Firestore document `users/{uid}` field `role`
 */
export async function getUserRole(user: FirebaseUser): Promise<UserRole> {
  try {
    const idTokenResult = await user.getIdTokenResult(true);
    if (idTokenResult.claims.role) {
      return idTokenResult.claims.role as UserRole;
    }
  } catch (err) {
    console.warn('Could not read custom claims:', err);
  }

  try {
    const userDocRef = doc(db, 'users', user.uid);
    const userSnap = await getDoc(userDocRef);
    if (userSnap.exists()) {
      const data = userSnap.data();
      if (data && data.role) {
        return data.role as UserRole;
      }
    }
  } catch (err) {
    console.warn('Could not read user doc from Firestore:', err);
  }

  // Fallback demo for predefined accounts if firestore has not been seeded yet
  if (user.email?.includes('admin')) return 'ADMIN';
  if (user.email?.includes('manager')) return 'TOURISM_MANAGER';

  return 'TOURIST';
}

/**
 * Sign in and strictly enforce RBAC for Admin Portal
 */
export async function loginWithRbac(email: string, pass: string): Promise<AdminUserProfile> {
  const cred = await signInWithEmailAndPassword(auth, email, pass);
  const role = await getUserRole(cred.user);

  if (role === 'TOURIST') {
    await fbSignOut(auth);
    throw new Error('Tài khoản Du khách (TOURIST) không có quyền truy cập Cổng Quản trị. Vui lòng đăng nhập bằng tài khoản Quản trị viên (ADMIN) hoặc Cán bộ Du lịch (TOURISM_MANAGER).');
  }

  return {
    uid: cred.user.uid,
    email: cred.user.email,
    displayName: cred.user.displayName || (role === 'ADMIN' ? 'Tổng Quản Trị Viên' : 'Cán Bộ Ban Quản Lý'),
    role,
    department: role === 'ADMIN' ? 'Ban Quản Trị Hệ Thống UBND' : 'Ban Quản Lý Danh Thắng Ngũ Hành Sơn',
  };
}

export async function logoutAdmin(): Promise<void> {
  await fbSignOut(auth);
}
