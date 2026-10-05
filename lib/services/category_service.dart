import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/category_model.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch categories with pagination
  Future<CategoryListResponseModel> getCategories({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.getAllCategoryEndpoint}?page=$page',
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : Map<String, dynamic>.from(response.data);

      return CategoryListResponseModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch categories: ${e.toString()}');
    }
  }

  /// Fetch all categories across all pages
  Future<List<CategoryItemModel>> getAllCategories() async {
    final List<CategoryItemModel> allCategories = [];
    int currentPage = 1;
    int lastPage = 1;

    try {
      do {
        final res = await getCategories(page: currentPage);
        allCategories.addAll(res.data);
        if (res.pagination != null) {
          lastPage = res.pagination!.lastPage;
        }
        currentPage++;
      } while (currentPage <= lastPage);

      return allCategories;
    } catch (_) {
      // Return what we have gathered so far or rethrow if empty
      if (allCategories.isNotEmpty) return allCategories;
      rethrow;
    }
  }
}
