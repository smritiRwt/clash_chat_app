import 'package:chat_app/utils/constants.dart';
import 'package:dio/dio.dart';

/// API Client Service using Dio
/// Handles all HTTP requests with centralized error handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  static const String baseUrl = '${Constants.baseUrl}/api';

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request details
          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          print('🔑 Headers: ${options.headers}');
          print('📦 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response details
          print(
            '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          print('📥 Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log error details
          print(
            '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          print('❌ ERROR MESSAGE: ${error.message}');
          print('📦 Request Data: ${error.requestOptions.data}');
          print('🔑 Request Headers: ${error.requestOptions.headers}');
          print('📥 Error Response Data: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// GET Request
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Merge custom headers with default headers
      final mergedHeaders = {
        ..._dio.options.headers,
        if (headers != null) ...headers,
      };

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: mergedHeaders),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Merge custom headers with default headers
      final mergedHeaders = {
        ..._dio.options.headers,
        if (headers != null) ...headers,
      };

      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: mergedHeaders),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> putRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> deleteRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      // Merge custom headers with default headers
      final mergedHeaders = {
        ..._dio.options.headers,
        if (headers != null) ...headers,
      };

      final response = await _dio.delete(
        endpoint,
        data: data,
        options: Options(headers: mergedHeaders),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Set Authorization Token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove Authorization Token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Handle Response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  /// Handle Errors
  String _handleError(DioException error) {
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      default:
        errorMessage = 'Something went wrong. Please try again.';
    }

    return errorMessage;
  }

  /// Handle Bad Response Errors
  String _handleBadResponse(Response? response) {
    if (response == null) return 'Unknown error occurred.';

    switch (response.statusCode) {
      case 400:
        return response.data['message'] ?? 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return response.data['message'] ?? 'Conflict occurred.';
      case 422:
        return response.data['message'] ?? 'Validation error.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return response.data['message'] ?? 'Something went wrong.';
    }
  }
}
