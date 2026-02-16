import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_bindings.dart';
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
    AppLogger.info('App started');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Short Video Flutter',
      initialRoute: AppRoutes.entry,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
