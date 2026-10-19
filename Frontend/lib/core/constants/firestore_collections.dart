/// Centralized collection and sub-collection names matching cautruc.md
class FirestoreCollections {
  FirestoreCollections._();

  // Root Collections
  static const String users = 'users';
  static const String destinations = 'destinations';
  static const String artisans = 'artisans';
  static const String eventsWorkshops = 'events_workshops';
  static const String bookings = 'bookings';
  static const String checkinPoints = 'checkin_points';
  static const String checkinRecords = 'checkin_records';
  static const String rewards = 'rewards';
  static const String rewardRedemptions = 'reward_redemptions';
  static const String stoneCarvingContests = 'stone_carving_contests';
  static const String promotionCampaigns = 'promotion_campaigns';
  static const String aiItinerariesAndLogs = 'ai_itineraries_and_logs';
  static const String systemAdministration = 'system_administration';

  // Sub-Collections
  static const String subVr360Contents = 'vr360_contents';
  static const String subAudioGuides = 'audio_guides';
  static const String subReviews = 'reviews';
  static const String subContestEntries = 'entries';
  static const String subContestVotes = 'votes';
  static const String subAnalyticsDaily = 'analytics_daily';
  static const String subAuditLogs = 'audit_logs';
}
