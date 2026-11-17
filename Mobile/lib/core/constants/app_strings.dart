import '../localization/app_localizations.dart';

class AppStrings {
  AppStrings._();

  static String get appName => AppLocalizations.trStatic('app_name');
  static String get appTagline => AppLocalizations.trStatic('tagline');
  static const String groupName = 'SE13 - FPT University Da Nang';

  // Role Names (LI-02)
  static const String roleTourist = 'TOURIST';
  static const String roleTourismManager = 'TOURISM_MANAGER';
  static const String roleAdmin = 'ADMIN';

  // Error Messages (LI-06 localized)
  static String get defaultErrorMessage => AppLocalizations.trStatic('common.error');
  static String get networkErrorMessage => AppLocalizations.trStatic('core.network_error');
  static String get unauthenticatedMessage => AppLocalizations.trStatic('core.unauthenticated_error');
  static String get unauthorizedMessage => AppLocalizations.trStatic('core.unauthorized_error');

  // FE-02 Recently Viewed (LI-06 localized, tập trung tại AppStrings)
  static const String recentlyViewedTitleKey = 'home.recently_viewed_title';
  static const String recentlyViewedSubtitleKey = 'home.recently_viewed_subtitle';
  static const String clearHistoryActionKey = 'home.clear_history_action';
  static const String clearHistoryConfirmTitleKey = 'home.clear_history_confirm_title';
  static const String clearHistoryConfirmMsgKey = 'home.clear_history_confirm_msg';
  static const String clearHistorySuccessKey = 'home.clear_history_success';

  static String get recentlyViewedTitle => AppLocalizations.trStatic(recentlyViewedTitleKey);
  static String get recentlyViewedSubtitle => AppLocalizations.trStatic(recentlyViewedSubtitleKey);
  static String get clearHistoryAction => AppLocalizations.trStatic(clearHistoryActionKey);
  static String get clearHistoryConfirmTitle => AppLocalizations.trStatic(clearHistoryConfirmTitleKey);
  static String get clearHistoryConfirmMessage => AppLocalizations.trStatic(clearHistoryConfirmMsgKey);
  static String get clearHistorySuccess => AppLocalizations.trStatic(clearHistorySuccessKey);
}
