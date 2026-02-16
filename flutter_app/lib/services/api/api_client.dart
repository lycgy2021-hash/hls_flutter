import 'package:dio/dio.dart';

import 'package:flutter_app/config/app_config.dart';
import 'package:flutter_app/services/api/api_headers.dart';
import 'package:flutter_app/services/api/interceptors/error_interceptor.dart';
import 'package:flutter_app/services/api/interceptors/header_interceptor.dart';
import 'package:flutter_app/services/api/interceptors/logging_interceptor.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';
import 'package:flutter_app/utils/app_logger.dart';

class ConditionalResponse {
  const ConditionalResponse({
    required this.status,
    required this.payload,
    this.etag,
    this.retryAfter,
  });

  final int status;
  final Map<String, dynamic>? payload;
  final String? etag;
  final String? retryAfter;
}

class ApiClient {
  ApiClient({
    required IdentityManager identityManager,
    Dio? dio,
  })  : _identityManager = identityManager,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBase,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
              ),
            ) {
    _dio.interceptors.addAll(<Interceptor>[
      HeaderInterceptor(_identityManager),
      LoggingInterceptor(AppLogger.tag('API')),
      ErrorInterceptor(),
    ]);
  }

  final IdentityManager _identityManager;
  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
    ValidateStatus? validateStatus,
  }) async {
    final response = await _dio.get<dynamic>(
      _path(path, baseUrl),
      queryParameters: queryParameters,
      options: Options(headers: headers, validateStatus: validateStatus),
    );
    return _normalize(response.data);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    Map<String, dynamic>? headers,
    String? contentTypeValue,
    ValidateStatus? validateStatus,
  }) async {
    final response = await _dio.post<dynamic>(
      _path(path, baseUrl),
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        contentType: contentTypeValue,
        validateStatus: validateStatus,
      ),
    );
    return _normalize(response.data);
  }

  Future<ConditionalResponse> getConditionalMessageConversations(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? ifNoneMatchValue,
  }) async {
    final headers = <String, dynamic>{};
    if (ifNoneMatchValue != null && ifNoneMatchValue.isNotEmpty) {
      headers[ifNoneMatch] = ifNoneMatchValue;
    }

    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
        validateStatus: (status) {
          if (status == null) return false;
          return (status >= 200 && status < 300) ||
              status == 304 ||
              status == 429;
        },
      ),
    );

    return ConditionalResponse(
      status: response.statusCode ?? 0,
      payload: response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null,
      etag: response.headers.value(etag) ??
          response.headers.value(etag.toLowerCase()),
      retryAfter: response.headers.value(retryAfter) ??
          response.headers.value(retryAfter.toLowerCase()),
    );
  }

  Future<Map<String, String>> currentIdentityHeaders() async {
    return <String, String>{
      xActorId: await _identityManager.getActorId(),
      xDid: await _identityManager.getDid(),
    };
  }

  String _path(String path, String? baseUrl) {
    if (baseUrl == null || baseUrl.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${baseUrl.replaceAll(RegExp(r'/+$'), '')}${path.startsWith('/') ? '' : '/'}$path';
  }

  Map<String, dynamic> _normalize(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final rawCode = raw['code'];
      final code =
          rawCode is int ? rawCode : int.tryParse('${rawCode ?? 200}') ?? 200;
      final success = raw['success'] == true || code == 200 || code == 0;
      return <String, dynamic>{
        ...raw,
        'success': success,
        'code': code == 0 ? 200 : code,
        'data': raw['data'] ?? raw,
      };
    }
    return <String, dynamic>{
      'success': true,
      'code': 200,
      'data': raw,
    };
  }
}
