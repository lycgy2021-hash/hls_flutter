import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import '../utils/app_error.dart';
import 'api_client.dart';
import 'identity_manager.dart';
import 'storage_service.dart';

class AuthService {
  AuthService(this._apiClient, this._identityManager, this._storage);

  final ApiClient _apiClient;
  final IdentityManager _identityManager;
  final StorageService _storage;

  bool get isLoggedIn => (_storage.getString('auth_uid') ?? '').isNotEmpty;

  String? get currentUid => _storage.getString('auth_uid');

  Future<void> login({
    required String uid,
    required String password,
    String mode = 'login',
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'uid': uid,
      'password': password,
      'mode': mode,
      'did': _identityManager.did,
    });

    try {
      final response = await _apiClient.post(
        Endpoints.userLogin,
        data: formData,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
      );

      if (response['success'] != true) {
        throw AppError(response['message']?.toString() ?? '登录失败',
            code: response['code'] as int?);
      }

      final data =
          (response['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      await _storage.setString('auth_uid', uid);

      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await _storage.setString('auth_token', token);
      }

      final actorIdFromServer = data['actor_id']?.toString();
      await _identityManager.setActorIdIfValid(actorIdFromServer);
      await _identityManager.refreshSessionIfExpired();
    } on DioException catch (e) {
      if (e.error is AppError) {
        throw e.error as AppError;
      }
      throw AppError('登录失败，请稍后重试');
    }
  }

  Future<void> logout() async {
    await _storage.remove('auth_uid');
    await _storage.remove('auth_token');
    await _identityManager.resetSession();
  }
}
