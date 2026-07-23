import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favoritesKey = 'favorites';
  static const _recentKey = 'recently_viewed';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []);
  }

  static Future<void> toggleFavorite(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    if (list.contains(listingId)) {
      list.remove(listingId);
    } else {
      list.add(listingId);
    }
    await prefs.setStringList(_favoritesKey, list);
  }

  static Future<bool> isFavorite(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? []).contains(listingId);
  }

  static Future<void> addRecentView(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_recentKey) ?? [];
    list.remove(listingId);
    list.insert(0, listingId);
    if (list.length > 20) list.removeLast();
    await prefs.setStringList(_recentKey, list);
  }

  static Future<List<String>> getRecentViews() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? [];
  }
}
