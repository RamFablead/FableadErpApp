import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/customer_model.dart';

class CustomerService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch customers with pagination and optional search
  Future<CustomerListResponseModel> getCustomers({
    int page = 1,
    int? perPage,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
      };

      if (perPage != null) {
        queryParams['per_page'] = perPage;
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.get(
        ApiConstants.getAllCustomerEndpoint,
        queryParameters: queryParams,
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : Map<String, dynamic>.from(response.data);

      return CustomerListResponseModel.fromJson(responseData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch customers: ${e.toString()}');
    }
  }

  /// Fetch all customers across all pages for fast in-memory searching & selection
  Future<List<CustomerItemModel>> getAllCustomers() async {
    final List<CustomerItemModel> allCustomers = [];
    int currentPage = 1;
    int lastPage = 1;

    try {
      do {
        final res = await getCustomers(page: currentPage, perPage: 50);
        allCustomers.addAll(res.data);
        if (res.pagination != null && res.pagination!.lastPage > 0) {
          lastPage = res.pagination!.lastPage;
        } else {
          break;
        }
        currentPage++;
      } while (currentPage <= lastPage);

      return allCustomers;
    } catch (e) {
      // If some customers were already retrieved, return them instead of failing completely
      if (allCustomers.isNotEmpty) return allCustomers;
      rethrow;
    }
  }
}
