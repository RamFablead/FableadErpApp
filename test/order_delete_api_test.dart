import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fableaderpapp/core/constants/api_constants.dart';
import 'package:fableaderpapp/models/order_model.dart';
import 'package:fableaderpapp/services/order_service.dart';

void main() {
  group('Delete Order API Tests', () {
    test('ApiConstants.deleteOrderEndpoint formats URL correctly', () {
      expect(ApiConstants.deleteOrderEndpoint(231), '/api/delete/231');
      expect(ApiConstants.deleteOrderEndpoint('456'), '/api/delete/456');
    });

    test('DeleteOrderResponseModel parses success response correctly', () {
      final json = {
        "status": true,
        "message": "Order deleted successfully."
      };

      final model = DeleteOrderResponseModel.fromJson(json);

      expect(model.status, isTrue);
      expect(model.message, 'Order deleted successfully.');
      expect(model.toJson()['status'], isTrue);
      expect(model.toJson()['message'], 'Order deleted successfully.');
    });

    test('DeleteOrderResponseModel parses failure response correctly', () {
      final json = {
        "status": false,
        "message": "Order not found or already deleted."
      };

      final model = DeleteOrderResponseModel.fromJson(json);

      expect(model.status, isFalse);
      expect(model.message, 'Order not found or already deleted.');
    });

    test('OrderService has deleteOrder method defined', () {
      final orderService = OrderService();
      expect(orderService.deleteOrder, isA<Function>());
    });
  });
}
