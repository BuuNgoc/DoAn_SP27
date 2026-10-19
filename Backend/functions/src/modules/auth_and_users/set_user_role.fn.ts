import * as functions from 'firebase-functions';
import { auth, db } from '../../config/firebase.config';
import { assertHasRole } from '../../common/middlewares/role_guard';
import { logAuditEvent } from '../../common/utils/audit_logger';

/**
 * [FE-26, FE-27] Admin Callable: Set user role and update Custom Claims
 */
export const setUserRole = functions.https.onCall(async (data, context) => {
  await assertHasRole(context, ['ADMIN']);

  const { targetUid, newRole } = data;
  if (!targetUid || !['TOURIST', 'TOURISM_MANAGER', 'ADMIN'].includes(newRole)) {
    throw new functions.https.HttpsError('invalid-argument', 'Dữ liệu không hợp lệ.');
  }

  await auth.setCustomUserClaims(targetUid, { role: newRole });
  await db.collection('users').doc(targetUid).update({ role: newRole });

  await logAuditEvent({
    actorUid: context.auth!.uid,
    actorRole: 'ADMIN',
    action: 'SET_USER_ROLE',
    targetCollection: 'users',
    targetId: targetUid,
    details: { newRole },
  });

  return { success: true, message: `Đã cập nhật vai trò thành công: ${newRole}` };
});
