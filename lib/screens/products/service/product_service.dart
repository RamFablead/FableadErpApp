import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../modal/AddProductModal.dart';
import '../modal/AllBrandModal.dart';
import '../modal/AllCateGoryModal.dart';
import '../modal/AllproductViewLIstModal.dart';
import '../modal/AllunitsModal.dart';
import '../modal/DeleateproductModal.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  /// 1. Fetch All Products
  /// Endpoint: /api/getAllProduct
  Future<AllproductViewLIstModal> getAllProducts() async {
    try {
      final response = await _apiClient.get(ApiConstants.getAllProducts);
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AllproductViewLIstModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching products: $e');
      }
      throw ApiException(message: 'Failed to fetch products: ${e.toString()}');
    }
  }

  /// 2. Fetch All Brands
  /// Endpoint: /api/getAllBrand
  Future<AllBrandModal> getAllBrands() async {
    try {
      final response = await _apiClient.get(ApiConstants.getAllBrands);
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AllBrandModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching brands: $e');
      }
      throw ApiException(message: 'Failed to fetch brands: ${e.toString()}');
    }
  }

  /// 3. Fetch All Categories
  /// Endpoint: /api/getAllCategory
  Future<AllCateGoryModal> getAllCategories() async {
    try {
      final response = await _apiClient.get(ApiConstants.getAllCategories);
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AllCateGoryModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching categories: $e');
      }
      throw ApiException(message: 'Failed to fetch categories: ${e.toString()}');
    }
  }

  /// 4. Fetch All Units
  /// Endpoint: /api/units
  Future<AllunitsModal> getAllUnits() async {
    try {
      final response = await _apiClient.get(ApiConstants.getUnits);
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AllunitsModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e,stackTrace) {
      if (kDebugMode) {
        debugPrint('Error fetching units: $e');
        debugPrint('Error fetching units: $stackTrace');
      }
      throw ApiException(message: 'Failed to fetch units: ${e.toString()}');
    }
  }

  /// 5. Create Product
  /// Endpoint: /api/createProduct
  Future<AddProductModal> createProduct(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createProduct,
        data: payload,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AddProductModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating product: $e');
      }
      throw ApiException(message: 'Failed to create product: ${e.toString()}');
    }
  }

  /// 6. Update Product
  /// Endpoint: /api/updateProduct/{id} or /api/updateProduct
  Future<AddProductModal> updateProduct(Map<String, dynamic> payload) async {
    try {
      final productId = payload['id'];
      Response response;
      if (productId != null) {
        try {
          // Attempt POST to /api/updateProduct/{id} (Laravel route model binding requirement)
          response = await _apiClient.post(
            '${ApiConstants.updateProduct}/$productId',
            data: payload,
          );
        } on ApiException catch (e) {
          if (e.statusCode == 404) {
            // Fallback to /api/updateProduct
            response = await _apiClient.post(
              ApiConstants.updateProduct,
              data: payload,
            );
          } else {
            rethrow;
          }
        }
      } else {
        response = await _apiClient.post(
          ApiConstants.updateProduct,
          data: payload,
        );
      }

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return AddProductModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating product: $e');
      }
      throw ApiException(message: 'Failed to update product: ${e.toString()}');
    }
  }

  /// 7. Delete Product
  /// Endpoint: /api/deleteProduct/{id}
  Future<DeleateproductModal> deleteProduct(int productId) async {
    try {
      final endpoint = '${ApiConstants.deleteProduct}/$productId';
      Response response;
      try {
        response = await _apiClient.post(endpoint);
      } catch (_) {
        response = await _apiClient.get(endpoint);
      }

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data
          : Map<String, dynamic>.from(response.data);
      return DeleateproductModal.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting product: $e');
      }
      throw ApiException(message: 'Failed to delete product: ${e.toString()}');
    }
  }
}
