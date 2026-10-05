import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() in main()');
    }
    return _prefs!;
  }

  // ==================== AUTH METHODS ====================

  /// Save Auth Data on Login Success
  static Future<void> saveAuthData({
    required String token,
    required UserModel user,
  }) async {
    await prefs.setString(ApiConstants.keyToken, token);
    await prefs.setString(ApiConstants.keyUserData, jsonEncode(user.toJson()));
    await prefs.setBool(ApiConstants.keyIsLoggedIn, true);
  }

  /// Get Stored Auth Token
  static String? getToken() {
    return _prefs?.getString(ApiConstants.keyToken);
  }

  /// Check if User is Logged In
  static bool isLoggedIn() {
    final bool isLogged = _prefs?.getBool(ApiConstants.keyIsLoggedIn) ?? false;
    final String? token = getToken();
    return isLogged && token != null && token.isNotEmpty;
  }

  /// Get Stored User Details
  static UserModel? getUser() {
    final String? userStr = _prefs?.getString(ApiConstants.keyUserData);
    if (userStr != null && userStr.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(userStr);
        return UserModel.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear Auth Data on Logout (Keeps Remember Me if desired)
  static Future<void> clearAuth() async {
    await prefs.remove(ApiConstants.keyToken);
    await prefs.remove(ApiConstants.keyUserData);
    await prefs.setBool(ApiConstants.keyIsLoggedIn, false);
  }

  // ==================== REMEMBER ME ====================

  static Future<void> saveRememberMe({
    required bool remember,
    required String email,
    required String password,
  }) async {
    await prefs.setBool(ApiConstants.keyRememberMe, remember);
    if (remember) {
      await prefs.setString(ApiConstants.keySavedEmail, email);
      await prefs.setString(ApiConstants.keySavedPassword, password);
    } else {
      await prefs.remove(ApiConstants.keySavedEmail);
      await prefs.remove(ApiConstants.keySavedPassword);
    }
  }

  static bool isRememberMe() {
    return _prefs?.getBool(ApiConstants.keyRememberMe) ?? false;
  }

  static String getSavedEmail() {
    return _prefs?.getString(ApiConstants.keySavedEmail) ?? '';
  }

  static String getSavedPassword() {
    return _prefs?.getString(ApiConstants.keySavedPassword) ?? '';
  }
}
