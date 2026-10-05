import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../modal/profile_modal.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch User Profile
  /// Endpoint: /api/getProfile
  Future<ProfileModal> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.getProfile);
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return ProfileModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching profile: $e');
      }
      throw ApiException(message: 'Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Update User Profile
  /// Endpoint: /api/updateProfile
  /// Payload: { "name": "...", "email": "...", "phone": "..." }
  Future<ProfileModal> updateProfile(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.updateProfile,
        data: payload,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return ProfileModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating profile: $e');
      }
      throw ApiException(message: 'Failed to update profile: ${e.toString()}');
    }
  }
}
