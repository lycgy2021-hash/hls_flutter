import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class FakeHttpAdapter implements HttpClientAdapter {
  RequestOptions? lastRequestOptions;

  int statusCode = 200;
  dynamic responseData = <String, dynamic>{
    'code': 200,
    'data': <String, dynamic>{}
  };
  Map<String, List<String>> responseHeaders = <String, List<String>>{};

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;

    final body = jsonEncode(responseData);
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        ...responseHeaders,
      },
    );
  }
}
