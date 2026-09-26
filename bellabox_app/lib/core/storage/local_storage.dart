import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bellabox/core/constants/storage_keys.dart';

class LocalStorage {
  LocalStorage._();

  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await Hive.initFlutter();
    // Open frequently-used boxes
    await Hive.openBox<String>(StorageKeys.recentSearchesBox);
    await Hive.openBox<int>(StorageKeys.wishlistLocalBox);
  }

  // Recent searches
  static List<String> getRecentSearches() {
    final box = Hive.box<String>(StorageKeys.recentSearchesBox);
    return box.values.toList().reversed.toList();
  }

  static Future<void> addRecentSearch(String query, {int maxItems = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final box = Hive.box<String>(StorageKeys.recentSearchesBox);
    // Remove duplicate
    final existingKeys = box.keys
        .where((k) => box.get(k) == trimmed)
        .toList();
    for (final k in existingKeys) {
      await box.delete(k);
    }
    await box.add(trimmed);
    // Trim to max
    while (box.length > maxItems) {
      await box.deleteAt(0);
    }
  }

  static Future<void> clearRecentSearches() async {
    final box = Hive.box<String>(StorageKeys.recentSearchesBox);
    await box.clear();
  }

  // Local wishlist mirror (product IDs) for optimistic UI
  static List<int> getWishlistIds() {
    final box = Hive.box<int>(StorageKeys.wishlistLocalBox);
    return box.values.toList();
  }

  static Future<void> toggleWishlistLocal(int productId) async {
    final box = Hive.box<int>(StorageKeys.wishlistLocalBox);
    final key = box.keys
        .firstWhere((k) => box.get(k) == productId, orElse: () => null);
    if (key != null) {
      await box.delete(key);
    } else {
      await box.add(productId);
    }
  }
}
