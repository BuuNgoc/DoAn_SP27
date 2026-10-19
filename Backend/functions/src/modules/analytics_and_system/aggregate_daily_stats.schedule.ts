import * as functions from 'firebase-functions';
import { db } from '../../config/firebase.config';

/**
 * [FE-25] Scheduled Function: Aggregate daily check-ins, bookings, and visitors
 * Runs every day at 00:05 AM.
 */
export const aggregateDailyStats = functions.pubsub
  .schedule('5 0 * * *')
  .timeZone('Asia/Ho_Chi_Minh')
  .onRun(async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const dateKey = yesterday.toISOString().split('T')[0];

    console.log(`Aggregating tourism analytics for: ${dateKey}`);

    // Aggregation logic stub
    await db
      .collection('system_administration')
      .doc('analytics_daily')
      .collection('records')
      .doc(dateKey)
      .set({
        date: dateKey,
        totalCheckins: 120,
        totalBookings: 35,
        totalNewUsers: 18,
        aggregatedAt: new Date(),
      });
  });
