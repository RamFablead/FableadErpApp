import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/user_model.dart';
import '../modal/profile_modal.dart';
import '../service/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final Rxn<ProfileData> profileData = Rxn<ProfileData>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  /// Fetch profile from API & sync with local storage
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final res = await _service.getProfile();
      if (res.status == true && res.data != null) {
        profileData.value = res.data;

        // Sync with StorageService user model
        final currentUser = StorageService.getUser();
        final updatedUser = UserModel(
          id: res.data!.id ?? currentUser?.id,
          name: res.data!.name ?? currentUser?.name,
          email: res.data!.email ?? currentUser?.email,
          phone: res.data!.phone ?? currentUser?.phone,
          profileImage: res.data!.profileImage ?? currentUser?.profileImage,
          role: res.data!.role ?? currentUser?.role,
        );
        await StorageService.saveUserData(updatedUser);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update profile via API
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    isUpdating.value = true;
    try {
      final payload = {
        "name": name,
        "email": email,
        "phone": phone,
      };

      final res = await _service.updateProfile(payload);
      if (res.status == true) {
        Get.snackbar(
          'Success',
          res.message ?? 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF15803D),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        // Refresh latest profile details
        await fetchProfile();
        return true;
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Failed to update profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
