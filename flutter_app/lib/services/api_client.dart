import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../config/endpoints.dart';
import '../utils/app_error.dart';
import '../utils/app_logger.dart';
import 'identity_manager.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient(this._identityManager, this._storage)
      : _dio = Dio(
          BaseOptions(
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            contentType: 'application/json',
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _identityManager.refreshSessionIfExpired();
          options.headers.addAll(_identityManager.buildDefaultHeaders());
          final token = _storage.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = token;
          }
          options.baseUrl = _resolveBaseUrl(options.path);
          handler.next(options);
        },
        onError: (error, handler) {
          final status = error.response?.statusCode;
          final appError = AppError.fromStatusCode(status);
          AppLogger.error('API request failed', error: {
            'path': error.requestOptions.path,
            'status': status,
            'message': error.message,
          });
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: appError,
              type: error.type,
              message: appError.message,
            ),
          );
        },
      ),
    );
  }

  final Dio _dio;
  final IdentityManager _identityManager;
  final StorageService _storage;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: query,
      options: Options(headers: headers),
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? contentType,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers, contentType: contentType),
    );
    return _normalizeResponse(response.data);
  }

  String _resolveBaseUrl(String path) {
    if (path.startsWith(Endpoints.postRecommended)) {
      return AppConfig.apiNewBase;
    }

    if (path.startsWith('/api/')) {
      return AppConfig.algoBase;
    }

    if (path.startsWith('/video/long_recommended') ||
        path.startsWith('/user/video_list_by_upid')) {
      return AppConfig.longVideoBase;
    }

    return AppConfig.apiBase;
  }

  Map<String, dynamic> _normalizeResponse(dynamic raw) {
    if (raw == null) {
      return <String, dynamic>{
        'success': false,
        'code': 500,
        'data': null,
        'message': 'empty response',
      };
    }

    if (raw is Map<String, dynamic>) {
      final codeRaw = raw['code'];
      final code =
          codeRaw is int ? codeRaw : int.tryParse('${codeRaw ?? 200}') ?? 200;
      final success = raw['success'] == true || code == 0 || code == 200;
      return <String, dynamic>{
        ...raw,
        'code': code == 0 ? 200 : code,
        'success': success,
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
