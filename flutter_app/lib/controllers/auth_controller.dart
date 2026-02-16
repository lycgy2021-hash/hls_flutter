import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../utils/app_error.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool loggedIn = false.obs;

  final TextEditingController uidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loggedIn.value = _authService.isLoggedIn;
  }

  Future<bool> login() async {
    loading.value = true;
    errorMessage.value = '';

    try {
      await _authService.login(
        uid: uidController.text.trim(),
        password: passwordController.text.trim(),
      );
      loggedIn.value = true;
      return true;
    } on AppError catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (_) {
      errorMessage.value = '登录失败，请稍后重试';
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    loggedIn.value = false;
  }

  @override
  void onClose() {
    uidController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
