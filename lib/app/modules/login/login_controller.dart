import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/biometric_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isBiometricAvailable = false.obs;

  late final ApiService _apiService;
  late final BiometricController _biometricC;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
    _biometricC = Get.put(BiometricController());
    _checkBiometric();
  }

  Future<void> _saveDeviceTokenToBackend(String authToken) async {
    try {
      // 1. Ambil FCM Token dari Firebase
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken != null) {
        debugPrint("FCM Token: $fcmToken");
        // 2. Kirim ke backend (pastikan method updateFcmToken sudah ada di ApiService)
        await _apiService.updateFcmToken(fcmToken, authToken);
      }
    } catch (e) {
      debugPrint("Gagal update FCM Token: $e");
    }
  }

  /// Cek apakah ada biometrik yang sudah diaktifkan
  Future<void> _checkBiometric() async {
    isBiometricAvailable.value = await _biometricC.hasBiometricEnabled();
  }

  /// Login menggunakan sidik jari
/// Login menggunakan sidik jari
  Future<void> loginWithBiometric() async {
    // 1. Jalankan verifikasi biometrik
    await _biometricC.loginWithBiometric();

    // 2. Cek apakah setelah login biometric, kita punya token di storage
    final savedToken = AuthStorage.getToken();
    if (savedToken != null) {
      // Update FCM Token ke backend secara asynchronous (tidak perlu ditunggu/await)
      // agar tidak menghambat navigasi ke Home
      _saveDeviceTokenToBackend(savedToken);
      
      // Biasanya navigasi sudah ditangani di dalam BiometricController, 
      // tapi pastikan token FCM terkirim.
    }
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

        await _saveDeviceTokenToBackend(token);

        }


        // Simpan user data — backend kirim response['data'], bukan response['user']
        final rawUser = body['data'] as Map<String, dynamic>?;
        if (rawUser != null) {
          // Normalisasi: pastikan selalu ada key 'id'
          final normalized = Map<String, dynamic>.from(rawUser);
          if (!normalized.containsKey('id') || normalized['id'] == null) {
            normalized['id'] = rawUser['user_id'] ?? rawUser['userId'] ?? 0;
          }
          await AuthStorage.saveUser(normalized);
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
