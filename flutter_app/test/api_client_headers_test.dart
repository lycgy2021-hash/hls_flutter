import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_headers.dart';
import 'package:flutter_app/services/api/endpoints.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';

import 'helpers/fake_http_adapter.dart';
import 'helpers/in_memory_kv_store.dart';

void main() {
  group('ApiClient headers and login', () {
    test('injects X-Actor-ID and X-DID on every request', () async {
      final store = InMemoryKvStore();
      final identityManager =
          IdentityManager(kvStore: store, nowMs: () => 1000);
      await identityManager.init();

      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      final adapter = FakeHttpAdapter();
      dio.httpClientAdapter = adapter;
      final client = ApiClient(identityManager: identityManager, dio: dio);

      await client.get('/health');

      final headers =
          adapter.lastRequestOptions?.headers ?? <String, dynamic>{};
      expect(headers.containsKey(xActorId), isTrue);
      expect(headers.containsKey(xDid), isTrue);
      expect('${headers[xActorId]}'.startsWith('a_'), isTrue);
      expect('${headers[xDid]}', isNotEmpty);
    });

    test('login uses form-url-encoded content-type and required fields',
        () async {
      final store = InMemoryKvStore();
      final identityManager =
          IdentityManager(kvStore: store, nowMs: () => 1000);
      await identityManager.init();

      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      final adapter = FakeHttpAdapter();
      adapter.responseData = <String, dynamic>{
        'code': 200,
        'data': <String, dynamic>{'token': 't_123', 'session_id': 's_abc'},
      };
      dio.httpClientAdapter = adapter;

      final client = ApiClient(identityManager: identityManager, dio: dio);
      final authService = AuthService(
        apiClient: client,
        identityManager: identityManager,
        kvStore: store,
      );

      await authService.login('u001', 'p001');

      final options = adapter.lastRequestOptions;
      expect(options?.path, Endpoints.userLogin);
      expect(options?.headers[contentType], formUrlEncoded);
      expect(options?.headers.containsKey(xActorId), isTrue);
      expect(options?.headers.containsKey(xDid), isTrue);
      final body = '${options?.data ?? ''}';
      expect(body.contains('uid=u001'), isTrue);
      expect(body.contains('password=p001'), isTrue);
      expect(body.contains('mode=login'), isTrue);
      expect(body.contains('did='), isTrue);
    });
  });
}
