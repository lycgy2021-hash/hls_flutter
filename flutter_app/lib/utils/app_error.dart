class AppError implements Exception {
  AppError(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => 'AppError(code: $code, message: $message)';

  static AppError fromStatusCode(int? statusCode) {
    if (statusCode == null) {
      return AppError('网络连接失败，请检查网络后重试');
    }
    if (statusCode == 401) {
      return AppError('用户名或密码不正确', code: statusCode);
    }
    if (statusCode == 403) {
      return AppError('会话已失效，请重新登录', code: statusCode);
    }
    if (statusCode == 404) {
      return AppError('接口不存在', code: statusCode);
    }
    if (statusCode >= 500) {
      return AppError('服务器错误，请稍后重试', code: statusCode);
    }
    return AppError('请求失败，请稍后重试', code: statusCode);
  }
}
