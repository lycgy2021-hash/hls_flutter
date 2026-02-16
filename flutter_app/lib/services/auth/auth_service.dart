import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/api/api_headers.dart';
import 'package:flutter_app/services/api/endpoints.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';
import 'package:flutter_app/services/storage/kv_store.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required IdentityManager identityManager,
    required KvStore kvStore,
  })  : _apiClient = apiClient,
        _identityManager = identityManager,
        _kvStore = kvStore;

  final ApiClient _apiClient;
  final IdentityManager _identityManager;
  final KvStore _kvStore;

  static const String _tokenKey = 'auth_token';

  Future<Map<String, dynamic>> login(
    String uid,
    String password, {
    String mode = 'login',
    String? did,
  }) async {
    await _identityManager.ensureDid(did);
    final didValue = await _identityManager.getDid();

    final fields = <String, String>{
      'uid': uid,
      'password': password,
      'mode': mode,
    };

    if (didValue.isNotEmpty) {
      fields['did'] = didValue;
    }

    final body = Uri(queryParameters: fields).query;
    final response = await _apiClient.post(
      Endpoints.userLogin,
      data: body,
      headers: <String, dynamic>{
        contentType: formUrlEncoded,
      },
      contentTypeValue: formUrlEncoded,
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final token = data['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await _kvStore.writeString(_tokenKey, token);
    }

    final sessionId = data['session_id']?.toString();
    if (sessionId != null && sessionId.isNotEmpty) {
      await _identityManager.setSession(sessionId);
    }

    return response;
  }

  Future<void> logout() async {
    await _identityManager.clearSession();
    await _kvStore.remove(_tokenKey);
  }

  String? getStoredToken() {
    return _kvStore.readString(_tokenKey);
  }
}
