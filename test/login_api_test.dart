import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/models/login_response_model.dart';
import 'package:fableaderpapp/services/auth_service.dart';
import 'package:fableaderpapp/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = RealHttpOverrides();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('LoginResponseModel parsing test with sample response', () {
    final sampleJson = {
      "status": true,
      "token": "test_jwt_token_sample",
      "user": {
        "id": 1,
        "name": "Main Branch",
        "email": "admin@gmail.com",
        "phone": "1234567890",
        "role": "admin",
        "status": 1,
        "profile_image_url": "https://erp-demo.fableadtech.com/public/storage/profile_images/p9ZG5DEk8BeHAldRTQNWVagkm4fw68DRX93QsAn0.jpg"
      },
      "redirect": "https://erp-demo.fableadtech.com/dashboard",
      "permissions": [],
      "showAppointments": true
    };

    final model = LoginResponseModel.fromJson(sampleJson);
    expect(model.status, true);
    expect(model.token, "test_jwt_token_sample");
    expect(model.user?.name, "Main Branch");
    expect(model.user?.email, "admin@gmail.com");
    expect(model.showAppointments, true);
  });

  test('StorageService save and retrieve auth data', () async {
    final sampleJson = {
      "status": true,
      "token": "token_12345",
      "user": {
        "id": 1,
        "name": "Admin User",
        "email": "admin@gmail.com",
        "role": "admin",
      }
    };

    final model = LoginResponseModel.fromJson(sampleJson);
    await StorageService.saveAuthData(
      token: model.token!,
      user: model.user!,
    );

    expect(StorageService.isLoggedIn(), true);
    expect(StorageService.getToken(), "token_12345");
    expect(StorageService.getUser()?.name, "Admin User");

    await StorageService.clearAuth();
    expect(StorageService.isLoggedIn(), false);
    expect(StorageService.getToken(), null);
  });

  test('Live login API test with Dio, AuthService, and StorageService', () async {
    final authService = AuthService();
    final response = await authService.login(
      email: 'admin@gmail.com',
      password: 'B6@qU1zN',
    );

    expect(response.status, true);
    expect(response.token, isNotNull);
    expect(response.user?.email, 'admin@gmail.com');
    expect(StorageService.isLoggedIn(), true);
    expect(StorageService.getToken(), isNotNull);
    expect(StorageService.getUser()?.name, 'Main Branch');
    print('🎉 LIVE LOGIN PASSED: Welcome ${response.user?.name}, Token: ${response.token?.substring(0, 25)}...');
  });
}
