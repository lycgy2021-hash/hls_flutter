import 'package:get/get.dart';

import '../views/home_placeholder_page.dart';
import '../views/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => const SplashPage()),
    GetPage(name: home, page: () => const HomePlaceholderPage()),
  ];
}
