class EnvConfig {
  EnvConfig._();

  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static String get apiBaseUrl {
    switch (_env) {
      case 'prod':
        return 'https://api.bellaboxksa.com/api/v1';
      case 'staging':
        return 'https://staging-api.bellaboxksa.com/api/v1';
      case 'dev':
      default:
        return 'http://10.0.2.2:8000/api/v1';
    }
  }

  static bool get enableLogging => _env != 'prod';
  static bool get isProduction => _env == 'prod';
  static String get environment => _env;
}
