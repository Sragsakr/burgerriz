import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../interfaces/base_api_interface.dart';

/// Base implementation of the API service interface
abstract class BaseApiService implements BaseApiInterface {
  late final Dio _dio;
  bool _dioInitialized = false;
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  BaseApiService({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
  })  : _baseUrl = baseUrl,
        _defaultHeaders = defaultHeaders ?? {};

  @override
  Dio get dio => _dio;

  @override
  String get baseUrl => _baseUrl;

  @override
  Map<String, String> get defaultHeaders => _defaultHeaders;

  @override
  Future<void> initialize() async {
    // Avoid LateInitializationError: late final Dio cannot be assigned twice.
    // Token-auth and other callers may invoke initialize() on each request/retry.
    if (_dioInitialized) {
      return;
    }
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: _defaultHeaders,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    // Add logging interceptor
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
          printRequestData: true,
          printResponseData: true,
        ),
      ),
    );

    // Add error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          await handleError(error);
          return handler.next(error);
        },
      ),
    );
    _dioInitialized = true;
  }

  @override
  Future<void> handleError(DioException error) async {
    // Implement common error handling logic here
    if (error.response?.statusCode == 401) {
      // Handle unauthorized error
      await removeAuthToken();
    }
    // Add more error handling as needed
  }

  @override
  Future<void> addAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future<void> removeAuthToken() async {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
