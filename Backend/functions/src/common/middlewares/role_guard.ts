import * as functions from 'firebase-functions';
import { auth } from '../config/firebase.config';

export type UserRole = 'TOURIST' | 'TOURISM_MANAGER' | 'ADMIN';

/**
 * Validates user role via Auth Context & Custom Claims (LI-02, LI-07)
 */
export async function assertHasRole(
  context: functions.https.CallableContext,
  allowedRoles: UserRole[]
): Promise<void> {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Yêu cầu xác thực tài khoản trước khi thực hiện.'
    );
  }

  const token = context.auth.token;
  let userRole = (token.role as UserRole) || 'TOURIST';

  if (!allowedRoles.includes(userRole)) {
    // Fallback: Fetch user record from Auth to check custom claims
    const userRecord = await auth.getUser(context.auth.uid);
    userRole = (userRecord.customClaims?.role as UserRole) || 'TOURIST';
  }

  if (!allowedRoles.includes(userRole)) {
    throw new functions.https.HttpsError(
      'permission-denied',
      `Bạn không có quyền thực hiện hành động này. Yêu cầu một trong các quyền: ${allowedRoles.join(', ')}`
    );
  }
}
