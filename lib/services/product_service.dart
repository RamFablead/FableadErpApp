import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch all products from /api/getAllProduct with Bearer Token
  Future<ProductListResponseModel> getAllProducts() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getAllProductEndpoint,
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : Map<String, dynamic>.from(response.data);

      return ProductListResponseModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch products: ${e.toString()}');
    }
  }
}
