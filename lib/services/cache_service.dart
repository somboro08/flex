import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _keyListings = 'cached_listings';
  static const String _keyBookings = 'cached_bookings';
  static const String _keyUserProfile = 'cached_user_profile';

  Future<void> saveListings(List<dynamic> listings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(listings);
      await prefs.setString(_keyListings, jsonString);
    } catch (e) {
      debugPrint('Error caching listings: $e');
    }
  }

  Future<List<dynamic>?> getListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyListings);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error reading cached listings: $e');
    }
    return null;
  }

  Future<void> saveBookings(List<dynamic> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(bookings);
      await prefs.setString(_keyBookings, jsonString);
    } catch (e) {
      debugPrint('Error caching bookings: $e');
    }
  }

  Future<List<dynamic>?> getBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyBookings);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error reading cached bookings: $e');
    }
    return null;
  }

  Future<void> saveUserProfile(Map<String, dynamic> userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(userProfile);
      await prefs.setString(_keyUserProfile, jsonString);
    } catch (e) {
      debugPrint('Error caching profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyUserProfile);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error reading cached profile: $e');
    }
    return null;
  }
}
