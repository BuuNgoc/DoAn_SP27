import * as functions from 'firebase-functions';
import { assertHasRole } from '../../common/middlewares/role_guard';
import { db } from '../../config/firebase.config';

/**
 * [FE-25] Callable: Export Tourism Analytics Data for Manager & Admin
 */
export const exportAnalyticsReport = functions.https.onCall(async (data, context) => {
  await assertHasRole(context, ['TOURISM_MANAGER', 'ADMIN']);

  const snapshot = await db
    .collection('system_administration')
    .doc('analytics_daily')
    .collection('records')
    .orderBy('date', 'desc')
    .limit(30)
    .get();

  const reportData = snapshot.docs.map((doc) => doc.data());

  return {
    generatedAt: new Date(),
    reportType: 'MONTHLY_SUMMARY',
    data: reportData,
  };
});
