import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch orders list with pagination from /api/get_orders
  Future<OrderListResponseModel> getOrders({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getOrdersEndpoint,
        queryParameters: {'page': page},
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : Map<String, dynamic>.from(response.data);

      return OrderListResponseModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch orders: ${e.toString()}');
    }
  }
}
