import 'package:dio/dio.dart';

/// Base interface for all API services
abstract class BaseApiInterface {
  /// The Dio instance used for making HTTP requests
  Dio get dio;

  /// Base URL for the API
  String get baseUrl;

  /// Headers to be included in all requests
  Map<String, String> get defaultHeaders;

  /// Initialize the API service
  Future<void> initialize();

  /// Handle API errors
  Future<void> handleError(DioException error);

  /// Add authentication token to requests
  Future<void> addAuthToken(String token);

  /// Remove authentication token from requests
  Future<void> removeAuthToken();

  /// Make a GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Make a POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Make a PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Make a DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });
}
