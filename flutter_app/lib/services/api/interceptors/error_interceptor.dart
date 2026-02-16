import 'package:dio/dio.dart';

import 'package:flutter_app/services/errors/app_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appError = AppError.fromDioException(err);
    handler.reject(
      err.copyWith(
        error: appError,
        message: appError.message,
      ),
    );
  }
}
