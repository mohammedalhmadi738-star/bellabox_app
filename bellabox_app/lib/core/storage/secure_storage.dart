import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bellabox/core/constants/storage_keys.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const String tokenKey = StorageKeys.authToken;
  static const String userKey = StorageKeys.userJson;

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> init() async {
    // Warm up if needed
  }

  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> clearAll() => _storage.deleteAll();
}
