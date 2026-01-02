import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/values/api_constants.dart';
import 'package:flutter/foundation.dart';

class ApiProvider {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiProvider() {
    _dio = Dio();
    _initializeInterceptors();
  }

  String get _baseUrl {
    if (Platform.isAndroid) {
      return ApiConstants.androidBaseUrl;
    }
    return ApiConstants.baseUrl;
  }

  void _initializeInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(
        milliseconds: ApiConstants.connectTimeoutMs,
      ),
      receiveTimeout: const Duration(
        milliseconds: ApiConstants.receiveTimeoutMs,
      ),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
      headers: {'Content-Type': ApiConstants.contentType},
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("Request: ${options.method} ${options.uri}");
          // Add Auth Token globally here
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          debugPrint(
            "Error: ${error.message} Status: ${error.response?.statusCode}",
          );
          if (error.response?.statusCode == 401) {
            // Token might be expired, try to refresh
            try {
              final newAccessToken = await _refreshToken();
              if (newAccessToken != null) {
                // Update the header with the new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                // Clone the request with the new headers
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                );
                final cloneReq = await _dio.request(
                  error.requestOptions.path,
                  options: opts,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );

                return handler.resolve(cloneReq);
              }
            } catch (e) {
              // Refresh failed, propagate error
              debugPrint("Token refresh failed: $e");
            }
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  // --- Wrapper Methods ---

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.sendTimeout:
          return Exception('Send timeout');
        case DioExceptionType.receiveTimeout:
          return Exception('Receive timeout');
        case DioExceptionType.badResponse:
          return Exception(_handleStatusCode(error.response?.statusCode));
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        case DioExceptionType.unknown:
          return Exception('Unknown Error detected');
        default:
          return Exception('Something went wrong!');
      }
    }
    return error;
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Something went wrong';
    }
  }

  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        return null;
      }

      // Use a separate Dio instance to avoid interceptor loop
      final tokenDio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Content-Type': ApiConstants.contentType},
        ),
      );

      // Log the refresh attempt
      debugPrint('Refreshing token...');

      final response = await tokenDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        final role = data['role'];

        if (newAccessToken != null) {
          await _storage.write(key: 'accessToken', value: newAccessToken);
          await _storage.write(key: 'refreshToken', value: newRefreshToken);
          await _storage.write(key: 'role', value: role);
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      // Ideally clear storage here or handle logout
      await _storage.deleteAll();
      return null;
    }
  }
}
