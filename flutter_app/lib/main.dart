import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_bindings.dart';
import 'config/app_config.dart';
import 'config/app_routes.dart';
import 'utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBindings.initServices();
  runApp(const MigrationApp());
}

class MigrationApp extends StatelessWidget {
  const MigrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.tag('APP')
        .logInfo('App started', data: {'env': AppConfig.envLabel});
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Short Video Flutter (${AppConfig.envLabel})',
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
