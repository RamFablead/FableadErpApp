import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Send timeout. Please try again.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Receive timeout. Server took too long to respond.',
          statusCode: dioException.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException.response);
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection or server unreachable.',
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: dioException.message ?? 'Unexpected network error occurred.',
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final int? statusCode = response?.statusCode;
    final dynamic data = response?.data;

    String errorMessage = 'Server error ($statusCode)';

    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        errorMessage = data['message'].toString();
      } else if (data['error'] != null && data['error'].toString().isNotEmpty) {
        errorMessage = data['error'].toString();
      } else if (data['errors'] != null) {
        if (data['errors'] is Map) {
          final errorsMap = data['errors'] as Map;
          final List<String> errorList = [];
          errorsMap.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else {
              errorList.add(value.toString());
            }
          });
          if (errorList.isNotEmpty) {
            errorMessage = errorList.join('\n');
          }
        } else if (data['errors'] is List) {
          errorMessage = (data['errors'] as List).join('\n');
        }
      }
    } else if (data is String && data.isNotEmpty) {
      errorMessage = data;
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: errorMessage, statusCode: statusCode);
      case 401:
        return ApiException(
          message: errorMessage.isNotEmpty && errorMessage != 'Server error (401)'
              ? errorMessage
              : 'Unauthorized: Invalid email or password.',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          message: 'Access forbidden: You do not have permission.',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(
          message: 'Resource not found (404).',
          statusCode: statusCode,
        );
      case 422:
        return ApiException(message: errorMessage, statusCode: statusCode);
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: 'Internal server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ApiException(message: errorMessage, statusCode: statusCode);
    }
  }
}
