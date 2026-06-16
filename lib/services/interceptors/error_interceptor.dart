import 'package:dio/dio.dart';

/// The category of a failed network call, used to show the right message/UI.
enum ApiErrorType { network, timeout, server, notFound, cancelled, unknown }

/// A clean, UI-friendly exception the rest of the app understands.
///
/// The UI and providers never see a raw [DioException]; [ErrorInterceptor]
/// translates everything into one of these.
class AppException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;

  const AppException(this.message, this.type, {this.statusCode});

  @override
  String toString() => message;
}

/// Converts low-level [DioException]s into typed [AppException]s.
///
/// It rejects with an [AppException] placed in `err.error`, so callers can do:
///   `if (e.error is AppException) ...`
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _map(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        message: appException.message,
      ),
    );
  }

  AppException _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
          'The connection timed out. Please try again.',
          ApiErrorType.timeout,
        );

      case DioExceptionType.connectionError:
        return const AppException(
          'No internet connection. Check your network and retry.',
          ApiErrorType.network,
        );

      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        if (code == 404) {
          return AppException(
            'The requested data was not found.',
            ApiErrorType.notFound,
            statusCode: code,
          );
        }
        return AppException(
          'Server error${code != null ? ' ($code)' : ''}. Please try again later.',
          ApiErrorType.server,
          statusCode: code,
        );

      case DioExceptionType.cancel:
        return const AppException(
          'The request was cancelled.',
          ApiErrorType.cancelled,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const AppException(
          'Something went wrong. Please try again.',
          ApiErrorType.unknown,
        );
    }
  }
}
