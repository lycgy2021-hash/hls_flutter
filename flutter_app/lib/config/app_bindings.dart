import 'package:get/get.dart';

import '../utils/app_logger.dart';

class AppBindings {
  static Future<void> initServices() async {
    AppLogger.tag('BOOT').logInfo('M0 bootstrap initialized');
    Get.put<String>('m0-ready', tag: 'bootstrap', permanent: true);
  }
}
