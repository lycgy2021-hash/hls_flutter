import 'package:get/get.dart';

import 'package:flutter_app/services/api/api_client.dart';
import 'package:flutter_app/services/auth/auth_service.dart';
import 'package:flutter_app/services/identity/identity_manager.dart';
import 'package:flutter_app/services/storage/kv_store.dart';
import '../utils/app_logger.dart';

class AppBindings {
  static Future<void> initServices() async {
    final kvStore = GetStorageKvStore();
    await kvStore.init();
    Get.put<KvStore>(kvStore, permanent: true);

    final identityManager = IdentityManager(kvStore: kvStore);
    await identityManager.init();
    Get.put<IdentityManager>(identityManager, permanent: true);

    final apiClient = ApiClient(identityManager: identityManager);
    Get.put<ApiClient>(apiClient, permanent: true);

    final authService = AuthService(
      apiClient: apiClient,
      identityManager: identityManager,
      kvStore: kvStore,
    );
    Get.put<AuthService>(authService, permanent: true);

    AppLogger.tag('BOOT').logInfo('M0 bootstrap initialized');
    Get.put<String>('m0-ready', tag: 'bootstrap', permanent: true);
  }
}
