import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';

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
      Get.offAllNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
