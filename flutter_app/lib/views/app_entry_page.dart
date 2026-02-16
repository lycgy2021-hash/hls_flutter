import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';
import '../controllers/auth_controller.dart';

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Get.find<AuthController>();
      Get.offAllNamed(auth.loggedIn.value ? AppRoutes.feed : AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
