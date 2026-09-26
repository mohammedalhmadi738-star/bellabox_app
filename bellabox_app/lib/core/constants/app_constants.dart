class AppConstants {
  AppConstants._();

  static const String appName = 'Bella Box';
  static const String currency = 'SAR';
  static const String currencySymbolAr = 'ر.س';
  static const String currencySymbolEn = 'SAR';
  static const int vatPercentage = 15;

  // Pagination
  static const int defaultPageSize = 20;
  static const int homeSectionLimit = 10;

  // OTP
  static const int otpLength = 4;
  static const int otpResendSeconds = 60;

  // Payment polling
  static const Duration paymentPollInterval = Duration(seconds: 3);
  static const Duration paymentPollTimeout = Duration(minutes: 5);

  // Cache
  static const Duration cacheDuration = Duration(minutes: 10);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // Recent searches
  static const int maxRecentSearches = 10;

  // Support / social
  static const String supportPhone = '+966500000000';
  static const String supportEmail = 'support@bellaboxksa.com';
  static const String privacyPolicySlug = 'privacy';
  static const String termsSlug = 'terms';
  static const String aboutSlug = 'about';
}
