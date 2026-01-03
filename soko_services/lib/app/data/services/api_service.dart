import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/api_response.dart';
import '../providers/api_provider.dart';

class ApiService {
  final ApiProvider _apiProvider;

  ApiService(this._apiProvider);

  // generic method to handle API calls
  Future<ApiResponse<T>> handleApiCall<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await apiCall();
      debugPrint('Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = fromJson(response.data);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error(
          'Request failed with status : ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        e.message ?? "Network error occurred",
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error : $e');
    }
  }

  // generic method to handle List API calls
  Future<ApiResponse<List<T>>> handleListApiCall<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic) fromJson, {
    String? cacheKey,
    Duration? cacheDuration,
  }) async {
    // 1. Check Cache
    if (cacheKey != null) {
      try {
        final box = Hive.box('api_cache');
        final cachedData = box.get(cacheKey);

        if (cachedData != null) {
          final timestamp = cachedData['timestamp'] as int;
          final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();

          if (now.difference(savedTime) < (cacheDuration ?? Duration.zero)) {
            debugPrint('Returning cached data for $cacheKey');
            final List<dynamic> jsonList = cachedData['data'];
            final List<T> dataList = jsonList
                .map((json) => fromJson(json as Map<String, dynamic>))
                .toList();
            return ApiResponse.success(dataList);
          }
        }
      } catch (e) {
        debugPrint('Cache Error: $e');
      }
    }

    // 2. Network Call
    try {
      final response = await apiCall();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonList = response.data;

        // 3. Save to Cache
        if (cacheKey != null) {
          try {
            final box = Hive.box('api_cache');
            await box.put(cacheKey, {
              'data': jsonList,
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
          } catch (e) {
            debugPrint('Error saving to cache: $e');
          }
        }

        final List<T> dataList = jsonList
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(dataList);
      } else {
        return ApiResponse.error(
          'Request failed with status : ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        e.message ?? "Network error occurred",
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error : $e');
    }
  }

  // specific GET method
  Future<ApiResponse<T>> get<T>(
    String endPoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return handleApiCall<T>(
      () => _apiProvider.get(
        endPoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      fromJson,
    );
  }

  // specific GET method for List
  Future<ApiResponse<List<T>>> getList<T>(
    String endPoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? cacheKey,
    Duration? cacheDuration,
  }) async {
    return handleListApiCall<T>(
      () => _apiProvider.get(
        endPoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      fromJson,
      cacheKey: cacheKey,
      cacheDuration: cacheDuration,
    );
  }

  // specific Post method
  Future<ApiResponse<T>> post<T>(
    String endPoint,
    T Function(dynamic) fromJson, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return handleApiCall<T>(
      () => _apiProvider.post(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      fromJson,
    );
  }

  // specific Put method
  Future<ApiResponse<T>> put<T>(
    String endPoint,
    T Function(dynamic) fromJson, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return handleApiCall<T>(
      () => _apiProvider.put(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      fromJson,
    );
  }

  // specific DELETE method
  Future<ApiResponse<T>> delete<T>(
    String endPoint,
    T Function(dynamic) fromJson, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return handleApiCall<T>(
      () => _apiProvider.delete(
        endPoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      ),
      fromJson,
    );
  }
}
