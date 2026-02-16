import 'package:get/get.dart';

import '../views/app_entry_page.dart';
import '../views/feed_page.dart';
import '../views/login_page.dart';

class AppRoutes {
  static const String entry = '/';
  static const String login = '/login';
  static const String feed = '/home';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: entry, page: () => const AppEntryPage()),
    GetPage(name: login, page: () => const LoginPage()),
    GetPage(name: feed, page: () => const FeedPage()),
  ];
}
