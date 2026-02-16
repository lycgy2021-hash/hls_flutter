import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_headers.dart';
import 'package:flutter_app/services/api/endpoints.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';

import 'helpers/fake_http_adapter.dart';
import 'helpers/in_memory_kv_store.dart';

void main() {
  group('Message conditional request', () {
    test('sets If-None-Match and parses ETag/Retry-After', () async {
      final store = InMemoryKvStore();
      final identityManager =
          IdentityManager(kvStore: store, nowMs: () => 1000);
      await identityManager.init();

      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      final adapter = FakeHttpAdapter()
        ..statusCode = 304
        ..responseData = <String, dynamic>{
          'code': 304,
          'data': <String, dynamic>{}
        }
        ..responseHeaders = <String, List<String>>{
          etag.toLowerCase(): <String>['W/"abc123"'],
          retryAfter.toLowerCase(): <String>['10'],
        };
      dio.httpClientAdapter = adapter;

      final client = ApiClient(identityManager: identityManager, dio: dio);
      final result = await client.getConditionalMessageConversations(
        Endpoints.messageConversations,
        ifNoneMatchValue: 'W/"old"',
      );

      expect(adapter.lastRequestOptions?.headers[ifNoneMatch], 'W/"old"');
      expect(result.status, 304);
      expect(result.etag, 'W/"abc123"');
      expect(result.retryAfter, '10');
    });
  });
}
