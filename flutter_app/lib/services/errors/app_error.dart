import 'package:dio/dio.dart';

enum AppErrorType { network, timeout, unauthorized, server, unknown }

class AppError implements Exception {
  AppError({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final AppErrorType type;
  final String message;
  final int? statusCode;

  @override
  String toString() {
    return 'AppError(type: $type, statusCode: $statusCode, message: $message)';
  }

  static AppError fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AppError(
        type: AppErrorType.timeout,
        message: '请求超时，请稍后重试',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return AppError(
        type: AppErrorType.network,
        message: '网络连接失败，请检查网络',
        statusCode: statusCode,
      );
    }

    if (statusCode == 401) {
      return AppError(
        type: AppErrorType.unauthorized,
        message: '认证失败，请重新登录',
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppError(
        type: AppErrorType.server,
        message: '服务暂不可用，请稍后重试',
        statusCode: statusCode,
      );
    }

    return AppError(
      type: AppErrorType.unknown,
      message: error.message ?? '未知错误',
      statusCode: statusCode,
    );
  }
}
