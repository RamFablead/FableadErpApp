import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/storage_service.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Login API Call
  /// Sends email and password to /api/loginapi
  /// Automatically stores token and user in local storage upon success
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'email': email.trim(),
        'password': password,
      });

      final response = await _apiClient.post(
        ApiConstants.loginEndpoint,
        data: formData,
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : Map<String, dynamic>.from(response.data);

      final loginResponse = LoginResponseModel.fromJson(responseData);

      if (loginResponse.status && loginResponse.token != null) {
        // Save Auth Session into SharedPreferences
        await StorageService.saveAuthData(
          token: loginResponse.token!,
          user: loginResponse.user ?? UserModel(),
        );
        return loginResponse;
      } else {
        throw ApiException(
          message: loginResponse.message ?? 'Login failed. Please verify your credentials.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Login failed: ${e.toString()}');
    }
  }

  /// Logout User and Clear Session
  Future<void> logout() async {
    await StorageService.clearAuth();
  }

  /// Check Login Status
  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }

  /// Get Current Logged In User
  UserModel? getCurrentUser() {
    return StorageService.getUser();
  }

  /// Get Current Token
  String? getToken() {
    return StorageService.getToken();
  }
}
