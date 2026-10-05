import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch orders list with pagination from /api/get_orders
  Future<OrderListResponseModel> getOrders({
    int page = 1,
    int perPage = 25,
    String? gstOption,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'per_page': perPage,
      };

      if (gstOption != null && gstOption.isNotEmpty) {
        queryParams['gst_option'] = gstOption;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiConstants.getOrdersEndpoint,
        queryParameters: queryParams,
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : (response.data is String
                  ? jsonDecode(response.data) as Map<String, dynamic>
                  : Map<String, dynamic>.from(response.data));

      return OrderListResponseModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch orders: ${e.toString()}');
    }
  }

  /// Place a new order sale via POST /api/order_sale
  Future<CreateOrderSaleResponseModel> createOrderSale(dynamic saleData) async {
    try {
      final Map<String, dynamic> requestPayload =
          saleData is CreateOrderSaleRequestModel
              ? saleData.toJson()
              : (saleData is Map<String, dynamic>
                  ? saleData
                  : (saleData is Map
                      ? Map<String, dynamic>.from(saleData)
                      : {}));

      // Print proper JSON request log matching Apidog
      final String prettyJson =
          const JsonEncoder.withIndent('  ').convert(requestPayload);
      debugPrint(
          '\n==================== [POST /api/order_sale JSON REQUEST] ====================');
      debugPrint(
          'Endpoint: ${ApiConstants.baseUrl}${ApiConstants.orderSaleEndpoint}');
      debugPrint(
          'Header: Content-Type: application/json, Accept: application/json');
      debugPrint('Body (JSON):\n$prettyJson');
      debugPrint(
          '===============================================================================\n');

      final response = await _apiClient.post(
        ApiConstants.orderSaleEndpoint,
        data: requestPayload,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : (response.data is String
                  ? jsonDecode(response.data) as Map<String, dynamic>
                  : Map<String, dynamic>.from(response.data));

      final String prettyResponse =
          const JsonEncoder.withIndent('  ').convert(responseData);
      debugPrint(
          '\n==================== [POST /api/order_sale JSON RESPONSE (${response.statusCode})] ====================');
      debugPrint('Response Body (JSON):\n$prettyResponse');
      debugPrint(
          '========================================================================================\n');

      return CreateOrderSaleResponseModel.fromJson(responseData);
    } on ApiException catch (e) {
      debugPrint('❌ [POST /api/order_sale API EXCEPTION]: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [POST /api/order_sale ERROR]: $e\n$stack');
      throw ApiException(
          message: 'Failed to create order sale: ${e.toString()}');
    }
  }

  /// Delete an order via POST /api/delete/{orderId}
  Future<DeleteOrderResponseModel> deleteOrder(dynamic orderId) async {
    try {
      final endpoint = ApiConstants.deleteOrderEndpoint(orderId);
      final fullUrl = '${ApiConstants.baseUrl}$endpoint';

      debugPrint(
          '\n==================== [POST /api/delete/$orderId JSON REQUEST] ====================');
      debugPrint('Endpoint: $fullUrl');
      debugPrint(
          'Header: Content-Type: application/json, Accept: application/json');
      debugPrint('Method: POST');
      debugPrint(
          '===================================================================================\n');

      final response = await _apiClient.post(
        endpoint,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : (response.data is String
                  ? jsonDecode(response.data) as Map<String, dynamic>
                  : Map<String, dynamic>.from(response.data));

      final String prettyResponse =
          const JsonEncoder.withIndent('  ').convert(responseData);
      debugPrint(
          '\n==================== [POST /api/delete/$orderId JSON RESPONSE (${response.statusCode})] ====================');
      debugPrint('Response Body (JSON):\n$prettyResponse');
      debugPrint(
          '============================================================================================\n');

      return DeleteOrderResponseModel.fromJson(responseData);
    } on ApiException catch (e) {
      debugPrint('❌ [POST /api/delete/$orderId API EXCEPTION]: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [POST /api/delete/$orderId ERROR]: $e\n$stack');
      throw ApiException(message: 'Failed to delete order: ${e.toString()}');
    }
  }

  /// Fetch sales order details by ID via GET /api/getsalseById/{id}
  Future<SalesDetailResponseModel> getSalesById(dynamic id) async {
    try {
      final endpoint = ApiConstants.getSalesByIdEndpoint(id);
      final fullUrl = '${ApiConstants.baseUrl}$endpoint';

      debugPrint(
          '\n==================== [GET /api/getsalseById/$id REQUEST] ====================');
      debugPrint('Endpoint: $fullUrl');
      debugPrint('Header: Accept: application/json');
      debugPrint('Method: GET');
      debugPrint(
          '==============================================================================\n');

      final response = await _apiClient.get(
        endpoint,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : (response.data is String
                  ? jsonDecode(response.data) as Map<String, dynamic>
                  : Map<String, dynamic>.from(response.data));

      final String prettyResponse =
          const JsonEncoder.withIndent('  ').convert(responseData);
      debugPrint(
          '\n==================== [GET /api/getsalseById/$id RESPONSE (${response.statusCode})] ====================');
      debugPrint('Response Body (JSON):\n$prettyResponse');
      debugPrint(
          '========================================================================================\n');

      return SalesDetailResponseModel.fromJson(responseData);
    } on ApiException catch (e) {
      debugPrint('❌ [GET /api/getsalseById/$id API EXCEPTION]: ${e.message}');
      rethrow;
    } catch (e, stack) {
      debugPrint('❌ [GET /api/getsalseById/$id ERROR]: $e\n$stack');
      throw ApiException(
          message: 'Failed to fetch sales detail: ${e.toString()}');
    }
  }
}
