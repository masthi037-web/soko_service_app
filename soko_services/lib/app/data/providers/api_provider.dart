import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/values/api_constants.dart';

class ApiProvider {
  late Dio _dio;
  final _storage = GetStorage();

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
          print("Request: ${options.method} ${options.uri}");
          // Add Auth Token globally here
          final token = await _storage.read('accessToken');
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) {
          print("Error: ${error.message}");
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
}
