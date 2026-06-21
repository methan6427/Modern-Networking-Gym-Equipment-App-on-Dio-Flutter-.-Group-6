import 'package:dio/dio.dart';

import '../dio_client.dart';

/// Injects authentication into every outgoing request.
///
/// Reading exercises from wger needs no auth, so by default this adds nothing.
/// If an optional token is supplied (via `--dart-define=API_TOKEN=...`) it is
/// attached as an `Authorization` header, which wger uses for write access.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (ApiConfig.apiToken.isNotEmpty) {
      options.headers['Authorization'] = 'Token ${ApiConfig.apiToken}';
    }
    handler.next(options);
  }
}
