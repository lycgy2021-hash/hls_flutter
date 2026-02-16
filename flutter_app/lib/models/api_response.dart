class ApiResponse<T> {
  ApiResponse(
      {required this.success,
      required this.code,
      required this.data,
      this.message});

  final bool success;
  final int code;
  final T? data;
  final String? message;

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    final dynamic rawCode = map['code'];
    final int code =
        rawCode is int ? rawCode : int.tryParse('${rawCode ?? 200}') ?? 200;
    final bool success = map['success'] == true || code == 0 || code == 200;
    return ApiResponse<T>(
      success: success,
      code: code == 0 ? 200 : code,
      data: map['data'] as T?,
      message: map['msg']?.toString() ?? map['message']?.toString(),
    );
  }
}
