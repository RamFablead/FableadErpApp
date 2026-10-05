import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/services/auth_service.dart';
import 'package:fableaderpapp/services/category_service.dart';
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

  test('CategoryService live getAllCategories parsing test', () async {
    final authService = AuthService();
    final categoryService = CategoryService();

    // 1. Authenticate to store Bearer token
    final loginRes = await authService.login(
      email: 'admin@gmail.com',
      password: 'B6@qU1zN',
    );
    expect(loginRes.token, isNotEmpty);

    // 2. Fetch all categories
    final categories = await categoryService.getAllCategories();
    expect(categories, isNotEmpty);

    print('✅ Successfully parsed ${categories.length} categories!');
    for (var i = 0; i < categories.length && i < 5; i++) {
      final c = categories[i];
      print('Category $i: ID: ${c.id}, Name: "${c.name}", Img: ${c.imageUrl}');
    }
  });
}
