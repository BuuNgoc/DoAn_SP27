import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';
import { assertHasRole } from '../../common/middlewares/role_guard';
import { logAuditEvent } from '../../common/utils/audit_logger';

/**
 * [FE-26] Admin Callable: Activate or deactivate user accounts
 */
export const manageUserStatus = functions.https.onCall(async (data, context) => {
  await assertHasRole(context, ['ADMIN']);

  const { targetUid, isActive } = data;
  if (!targetUid || typeof isActive !== 'boolean') {
    throw new functions.https.HttpsError('invalid-argument', 'Tham số không hợp lệ.');
  }

  await db.collection('users').doc(targetUid).update({ isActive });

  await logAuditEvent({
    actorUid: context.auth!.uid,
    actorRole: 'ADMIN',
    action: isActive ? 'ACTIVATE_USER' : 'DEACTIVATE_USER',
    targetCollection: 'users',
    targetId: targetUid,
  });

  return { success: true, isActive };
});
