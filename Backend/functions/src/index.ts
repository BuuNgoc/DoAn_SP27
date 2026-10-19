/**
 * SmartTravel Backend Cloud Functions Entry Point
 * Group SE13 - FPT University Da Nang
 */

// Module 1: Auth & Users [FE-01, FE-26, FE-27]
export { onUserCreated } from './modules/auth_and_users/on_user_created.trigger';
export { setUserRole } from './modules/auth_and_users/set_user_role.fn';
export { manageUserStatus } from './modules/auth_and_users/manage_user_status.fn';

// Module 2: AI & RAG [FE-05 & RAG]
export { analyzeLandmarkImage } from './modules/ai_and_rag/analyze_landmark_image.fn';
export { generateRagItinerary } from './modules/ai_and_rag/generate_rag_itinerary.fn';
export { syncDestinationEmbeddings } from './modules/ai_and_rag/sync_destination_embeddings.trigger';

// Module 3: Booking & Events [FE-06, FE-07, FE-15, FE-16, FE-19, FE-22]
export { createBooking } from './modules/booking_and_events/create_booking.fn';
export { cancelBooking } from './modules/booking_and_events/cancel_booking.fn';
export { voteContestEntry } from './modules/booking_and_events/vote_contest_entry.fn';

// Module 4: Check-in & Loyalty [FE-08, FE-09, FE-20]
export { validateQrCheckin } from './modules/checkin_and_loyalty/validate_qr_checkin.fn';
export { redeemLoyaltyReward } from './modules/checkin_and_loyalty/redeem_loyalty_reward.fn';
export { generateCheckinQr } from './modules/checkin_and_loyalty/generate_checkin_qr.fn';

// Module 5: Reviews & Moderation [FE-10]
export { onReviewWritten } from './modules/reviews_and_moderation/on_review_written.trigger';
export { reportReview } from './modules/reviews_and_moderation/report_review.fn';
export { moderateReview } from './modules/reviews_and_moderation/moderate_review.fn';

// Module 6: Analytics & System [FE-25, FE-28]
export { aggregateDailyStats } from './modules/analytics_and_system/aggregate_daily_stats.schedule';
export { exportAnalyticsReport } from './modules/analytics_and_system/export_analytics_report.fn';
export { backupFirestoreData } from './modules/analytics_and_system/backup_firestore_data.schedule';
