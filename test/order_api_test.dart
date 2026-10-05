import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/services/auth_service.dart';
import 'package:fableaderpapp/services/order_service.dart';
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

  test('OrderService live getOrders parsing test', () async {
    final authService = AuthService();
    final orderService = OrderService();

    // 1. Authenticate to store Bearer token
    final loginRes = await authService.login(
      email: 'admin@gmail.com',
      password: 'B6@qU1zN',
    );
    expect(loginRes.token, isNotEmpty);

    // 2. Fetch orders from live API
    final orderRes = await orderService.getOrders(page: 1);
    expect(orderRes.status, isTrue);
    expect(orderRes.data, isNotEmpty);

    print('✅ Successfully parsed ${orderRes.data.length} orders!');
    print('Total Amount: ₹${orderRes.totalAmount}');
    print('Total Pending: ₹${orderRes.totalPendingAmount}');
    print('Total Paid: ₹${orderRes.totalPaidAmount}');
    if (orderRes.pagination != null) {
      print('Page: ${orderRes.pagination!.currentPage}/${orderRes.pagination!.lastPage}, Total: ${orderRes.pagination!.total}');
    }

    final first = orderRes.data.first;
    print('Sample Order: #${first.orderNumber}, Customer: "${first.customerName}", Total: ₹${first.totalAmount}, Status: ${first.displayPaymentStatus}, Date: ${first.createdDate}');
  });
}
