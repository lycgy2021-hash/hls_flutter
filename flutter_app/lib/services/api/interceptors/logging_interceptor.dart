import 'package:dio/dio.dart';

import 'package:flutter_app/utils/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.logInfo('HTTP request', data: <String, dynamic>{
      'method': options.method,
      'url': options.uri.toString(),
      'headers': _redactHeaders(options.headers),
    });
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.logInfo('HTTP response', data: <String, dynamic>{
      'statusCode': response.statusCode,
      'url': response.requestOptions.uri.toString(),
    });
    handler.next(response);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('authorization') || key.contains('session')) {
        sanitized[entry.key] = '***';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }
}
