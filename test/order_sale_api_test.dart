import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/services/auth_service.dart';
import 'package:fableaderpapp/services/order_service.dart';
import 'package:fableaderpapp/models/order_model.dart';
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

  test('OrderService live createOrderSale test', () async {
    final authService = AuthService();
    final orderService = OrderService();

    // 1. Authenticate to get and store Bearer token
    final loginRes = await authService.login(
      email: 'admin@gmail.com',
      password: 'B6@qU1zN',
    );
    expect(loginRes.token, isNotEmpty);

    // 2. Verify model serialization with gst_option
    final modelWithoutGst = CreateOrderSaleRequestModel(
      customerId: "1",
      customerPhone: "9876543210",
      gstOption: "without_gst",
      orderDate: "2026-10-05",
      subtotal: 1000.00,
      amount: 1000.00,
      paymentAmount: 1000.00,
      pendingAmount: 0,
      cashAmount: 1000.00,
      total: 1000.00,
      discount: 0,
      remarks: "Without GST order test",
      items: [
        CreateOrderItemRequestModel(
          productId: 1,
          productName: "Mobile Cover",
          quantity: 2,
          price: 500,
          total: 1000.00,
        ),
      ],
    );
    expect(modelWithoutGst.toJson()['gst_option'], equals('without_gst'));

    final modelWithGst = CreateOrderSaleRequestModel(
      customerId: "1",
      customerPhone: "9876543210",
      gstOption: "with_gst",
      orderDate: "2026-10-05",
      subtotal: 1000.00,
      amount: 1180.00,
      paymentAmount: 1180.00,
      pendingAmount: 0,
      cashAmount: 1180.00,
      total: 1180.00,
      discount: 0,
      remarks: "With GST order test",
      items: [
        CreateOrderItemRequestModel(
          productId: 1,
          productName: "Mobile Cover",
          quantity: 2,
          price: 500,
          total: 1000.00,
        ),
      ],
    );
    expect(modelWithGst.toJson()['gst_option'], equals('with_gst'));

    final result = await orderService.createOrderSale(modelWithGst);

    expect(result.status, isTrue);
    expect(result.orderId, isNotNull);
    print('🎉 Order Sale Created successfully!');
    print('Order ID: ${result.orderId}');
    print('Message: ${result.message}');
    if (result.salesInvoice != null) {
      print('Invoice PDF URL: ${result.salesInvoice!.fileUrl}');
      print('Invoice File Name: ${result.salesInvoice!.fileName}');
    }
  });
}
