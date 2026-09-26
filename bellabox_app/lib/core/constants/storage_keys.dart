class StorageKeys {
  StorageKeys._();

  // Secure
  static const String authToken = 'auth_token';
  static const String userJson = 'user_json';

  // Prefs
  static const String onboardingSeen = 'onboarding_seen';
  static const String language = 'language';
  static const String cartToken = 'cart_token'; // guest cart X-Cart-Token
  static const String settingsCache = 'settings_cache';
  static const String settingsCachedAt = 'settings_cached_at';

  // Hive boxes
  static const String recentSearchesBox = 'recent_searches';
  static const String wishlistLocalBox = 'wishlist_local';
}
