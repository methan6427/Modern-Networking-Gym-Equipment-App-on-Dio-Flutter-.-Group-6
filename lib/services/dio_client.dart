import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Central networking configuration.
///
/// The app reads exercise data from the free, public **wger** workout API
/// (https://wger.de). Read access needs no key, so every team member can run
/// the app out of the box.
///
/// wger also supports optional token auth for write access. If you ever need
/// it, pass a token at run time and [AuthInterceptor] will attach it:
///   flutter run --dart-define=API_TOKEN=your_token
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://wger.de/api/v2';

  /// Optional wger API token (not required for reading exercises).
  static const String apiToken = String.fromEnvironment('API_TOKEN');

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

/// Singleton wrapper around a configured [Dio] instance.
///
/// This is the single place where the HTTP client is built. Every interceptor
/// is attached here, in a deliberate order:
///   1. [AuthInterceptor]    - inject credentials before anything else
///   2. [LoggingInterceptor] - log the outgoing request and incoming response
///   3. [ErrorInterceptor]   - convert raw DioException into typed AppException
///   4. [RetryInterceptor]   - retry transient network failures
class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
      RetryInterceptor(dio: _dio),
    ]);
  }

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;

  /// The configured client the services use to make requests.
  Dio get dio => _dio;
}
