import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch dashboard metrics, counts, recent products, latest sales & charts from /api/dashboard-api
  Future<DashboardResponseModel> getDashboardData() async {
    try {
      if (kDebugMode) {
        debugPrint('\n==================== [GET /api/dashboard-api REQUEST] ====================');
        debugPrint('Endpoint: ${ApiConstants.baseUrl}${ApiConstants.dashboardEndpoint}');
        debugPrint('Method: GET');
        debugPrint('==============================================================================\n');
      }

      final response = await _apiClient.get(
        ApiConstants.dashboardEndpoint,
      );

      final Map<String, dynamic> responseData =
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : (response.data is String
                  ? jsonDecode(response.data as String) as Map<String, dynamic>
                  : <String, dynamic>{});

      if (kDebugMode) {
        debugPrint('\n==================== [GET /api/dashboard-api RESPONSE] ====================');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Status: ${responseData['status']}');
        if (responseData['data'] is Map) {
          final data = responseData['data'] as Map;
          debugPrint('Totals: ${data['totals']}');
          debugPrint('Counts: ${data['counts']}');
        }
        debugPrint('==============================================================================\n');
      }

      return DashboardResponseModel.fromJson(responseData);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DASHBOARD SERVICE ERROR] DioException: ${e.message}');
        if (e.response != null) {
          debugPrint('Response Data: ${e.response?.data}');
        }
      }
      final apiException = ApiException.fromDioError(e);
      throw apiException.message;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DASHBOARD SERVICE ERROR] Unexpected: $e');
      }
      throw 'Failed to load dashboard data: $e';
    }
  }
}
