import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/feed_controller.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/feed_service.dart';
import '../services/identity_manager.dart';
import '../services/storage_service.dart';
import '../services/video_controller_pool.dart';

class AppBindings {
  static Future<void> initServices() async {
    final storage = StorageService();
    await storage.init();
    Get.put<StorageService>(storage, permanent: true);

    final identityManager = IdentityManager(storage);
    await identityManager.init();
    Get.put<IdentityManager>(identityManager, permanent: true);

    final apiClient = ApiClient(identityManager, storage);
    Get.put<ApiClient>(apiClient, permanent: true);

    Get.put<AuthService>(
      AuthService(apiClient, identityManager, storage),
      permanent: true,
    );
    Get.put<FeedService>(
      FeedService(apiClient, identityManager),
      permanent: true,
    );
    Get.put<VideoControllerPool>(VideoControllerPool(), permanent: true);

    Get.put<AuthController>(
      AuthController(Get.find<AuthService>()),
      permanent: true,
    );
    Get.put<FeedController>(
      FeedController(Get.find<FeedService>(), Get.find<VideoControllerPool>()),
      permanent: true,
    );
  }
}
