import 'package:dio/dio.dart';

/// Automatically retries requests that fail due to transient network issues.
///
/// Retries up to [maxRetries] times with a fixed [retryDelay] between attempts.
/// Only connection/timeout errors are retried — a 404 or 500 is returned
/// immediately because retrying would not help.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  static const String _retryCountKey = 'retryCount';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (_shouldRetry(err) && attempt < maxRetries) {
      await Future<void>.delayed(retryDelay);

      final options = err.requestOptions
        ..extra[_retryCountKey] = attempt + 1;

      try {
        final response = await dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
