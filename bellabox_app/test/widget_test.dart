import 'package:bellabox/core/env/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig', () {
    test('uses the Android emulator development API by default', () {
      expect(EnvConfig.environment, 'dev');
      expect(EnvConfig.apiBaseUrl, 'http://10.0.2.2:8000/api/v1');
      expect(EnvConfig.enableLogging, isTrue);
      expect(EnvConfig.isProduction, isFalse);
    });
  });
}
