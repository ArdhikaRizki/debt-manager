import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  late final ApiService _apiService;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ─── VALIDASI LOKAL ────────────────────────────────
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // ─── HIT API LOGIN ────────────────────────────────
    isLoading.value = true;
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body as Map<String, dynamic>;

        // Simpan token
        final token = body['token'] as String?;
        if (token != null) {
          await AuthStorage.saveToken(token);
        }

        // Simpan user data
        final user = body['user'] as Map<String, dynamic>?;
        if (user != null) {
          await AuthStorage.saveUser(user);
        }

        Get.snackbar(
          'Berhasil',
          'Login berhasil!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        // Navigate ke home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Error dari server
        final body = response.body as Map<String, dynamic>?;
        final message =
            body?['message'] as String? ?? 'Email atau password salah';

        Get.snackbar(
          'Login Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server. Coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
