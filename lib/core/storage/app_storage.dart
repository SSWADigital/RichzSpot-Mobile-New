import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_data';
  static const _keyFaceToken = 'face_token';
  static const _keyFCMDeviceToken = 'fcm_device_token';
  static const _keyPlatform = 'platform';
  static const _keyFCMServerToken = 'fcm_server_token';

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(userData));
  }

  /// Save login token and user info
  static Future<void> saveLoginData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, json.encode(user));
    await prefs.setString(_keyFaceToken, user['face_token'] ?? '');

  }

  /// Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Get saved face token
  static Future<String?> getFaceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFaceToken);
  }

  static Future<String?> getFCMDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFCMDeviceToken);
  }

  static Future<String?> getPlatform() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlatform);
  }

  static Future<String?> getFCMServerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFCMServerToken);
  }

  // Set FCM Device Token
  static Future<void> setFCMDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFCMDeviceToken, token);
  }

  // Set Platform
  static Future<void> setPlatform(String platform) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlatform, platform);
  }

  // Set FCM Server Token
  static Future<void> setFCMServerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFCMServerToken, token);
  }
  

  /// Get saved user as Map
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUser);
    if (jsonString == null) return null;
    return json.decode(jsonString);
  }

  /// Clear all saved login data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


}
