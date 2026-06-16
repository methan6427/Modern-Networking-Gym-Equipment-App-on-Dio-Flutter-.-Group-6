import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs every request/response cycle to the debug console.
///
/// Demonstrates Dio interceptors (FR-12). Each request is stamped so the
/// matching response/error can report how long the call took.
class LoggingInterceptor extends Interceptor {
  static const String _tag = 'Dio';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    developer.log(
      '--> ${options.method} ${options.uri}',
      name: _tag,
    );
    if (options.queryParameters.isNotEmpty) {
      developer.log('    query: ${options.queryParameters}', name: _tag);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri} '
      '(${_elapsed(response.requestOptions)}ms)',
      name: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.response?.statusCode ?? ''} '
      '${err.requestOptions.uri} '
      '(${_elapsed(err.requestOptions)}ms): ${err.message}',
      name: _tag,
    );
    handler.next(err);
  }

  int _elapsed(RequestOptions options) {
    final start = options.extra['startTime'];
    if (start is int) {
      return DateTime.now().millisecondsSinceEpoch - start;
    }
    return 0;
  }
}
