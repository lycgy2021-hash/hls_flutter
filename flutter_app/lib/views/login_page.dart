import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_routes.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            children: <Widget>[
              TextField(
                controller: controller.uidController,
                decoration: const InputDecoration(labelText: 'UID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (controller.errorMessage.value.isNotEmpty)
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.loading.value
                      ? null
                      : () async {
                          final ok = await controller.login();
                          if (ok) {
                            Get.offAllNamed(AppRoutes.home);
                          }
                        },
                  child: controller.loading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
