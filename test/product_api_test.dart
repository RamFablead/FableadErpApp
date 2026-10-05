import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/services/auth_service.dart';
import 'package:fableaderpapp/services/product_service.dart';
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

  test('ProductService live getAllProducts parsing test', () async {
    final authService = AuthService();
    final loginRes = await authService.login(
      email: 'admin@gmail.com',
      password: 'B6@qU1zN',
    );
    expect(loginRes.status, true);

    final productService = ProductService();
    final result = await productService.getAllProducts();
    expect(result.status, true);
    expect(result.data.isNotEmpty, true);
    print('✅ Successfully parsed ${result.data.length} products!');
    print('Sample product 0: Name: "${result.data[0].name}", Price: ₹${result.data[0].numericPrice}, Category: "${result.data[0].categoryName}", Unit: "${result.data[0].unitName}"');
  });
}
