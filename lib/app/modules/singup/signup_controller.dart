import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import '../../routes/app_routes.dart';

class SignupController extends GetxController {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  // ─── STATE ──────────────────────────────────────────
  final isLoading = false.obs;
  final isVerifying = false.obs;
  final isCheckingOtp = false.obs;
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;
  final otpValue = ''.obs;
  final otpErrorText = ''.obs;
  final verifyStatusText = ''.obs;

  late final ApiService _apiService;

  bool _isSuccessStatus(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.put(ApiService());
    otpController.addListener(() {
      otpValue.value = otpController.text.trim();
      if (isOtpVerified.value) {
        isOtpVerified.value = false;
      }
      if (otpErrorText.value.isNotEmpty || verifyStatusText.value.isNotEmpty) {
        otpErrorText.value = '';
        verifyStatusText.value = '';
      }
    });
  }

  // ─── VERIFY EMAIL (KIRIM OTP) ──────────────────────
  Future<void> verifyEmail() async {
    if (isVerifying.value) return;

    final email = emailController.text.trim();

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

    isVerifying.value = true;
    isOtpVerified.value = false;
    verifyStatusText.value = '';
    otpErrorText.value = '';

    try {
      final response = await _apiService.sendOtp(email: email);

      if (_isSuccessStatus(response.statusCode)) {
        isOtpSent.value = true;
        verifyStatusText.value = 'OTP terkirim ke $email';
        otpController.clear();
        otpValue.value = '';

        Get.snackbar(
          'OTP Terkirim',
          'Cek email kamu untuk kode OTP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        final body = response.body as Map<String, dynamic>?;
        final message =
            body?['message'] as String? ?? 'Gagal mengirim OTP';

        verifyStatusText.value = message;

        Get.snackbar(
          'Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      verifyStatusText.value = 'Tidak dapat terhubung ke server';
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server. Coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> validateOtp() async {
    if (isCheckingOtp.value) return;

    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (!isOtpSent.value) {
      otpErrorText.value = 'Klik Verify email dulu';
      return;
    }

    if (otp.isEmpty) {
      otpErrorText.value = 'Masukkan kode OTP';
      return;
    }

    if (otp.length < 6) {
      otpErrorText.value = 'OTP harus 6 digit';
      return;
    }

    isCheckingOtp.value = true;
    otpErrorText.value = '';
    verifyStatusText.value = '';

    try {
      final response = await _apiService.verifyOtp(email: email, otp: otp);

      if (_isSuccessStatus(response.statusCode)) {
        isOtpVerified.value = true;
        verifyStatusText.value = 'OTP valid, lanjut isi data akun';

        Get.snackbar(
          'OTP Valid',
          'Kode OTP berhasil diverifikasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return;
      }

      isOtpVerified.value = false;
      final body = response.body as Map<String, dynamic>?;
      final message = body?['message'] as String? ?? 'Kode OTP tidak valid';
      otpErrorText.value = message;
    } catch (_) {
      isOtpVerified.value = false;
      otpErrorText.value = 'Tidak dapat verifikasi OTP. Coba lagi.';
    } finally {
      isCheckingOtp.value = false;
    }
  }

  // ─── SIGNUP (REGISTER) ─────────────────────────────
  Future<void> signup() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otp = otpController.text.trim();

    // ─── VALIDASI LOKAL ──────────────────────────────

    if (!isOtpSent.value) {
      Get.snackbar(
        'Error',
        'Kamu harus verifikasi email terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (!isOtpVerified.value) {
      otpErrorText.value = 'Verifikasi OTP dulu sebelum lanjut';
      Get.snackbar(
        'Error',
        'OTP belum diverifikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi password tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (otp.isEmpty) {
      otpErrorText.value = 'Masukkan kode OTP';
      Get.snackbar(
        'Error',
        'Kode OTP tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // ─── HIT API REGISTER ────────────────────────────
    isLoading.value = true;
    otpErrorText.value = '';

    try {
      final response = await _apiService.register(
        email: email,
        username: username,
        password: password,
        passwordConfirmation: confirmPassword,
        otp: otp,
      );

      if (_isSuccessStatus(response.statusCode)) {
        Get.snackbar(
          'Berhasil',
          'Akun berhasil dibuat! Silakan login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        // Navigate ke login
        Get.offNamed(AppRoutes.login);
      } else {
        final body = response.body as Map<String, dynamic>?;
        final message =
            body?['message'] as String? ?? 'Registrasi gagal';

        // Cek apakah error dari OTP
        final errors = body?['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.containsKey('otp')) {
          final otpErrors = errors['otp'];
          if (otpErrors is List && otpErrors.isNotEmpty) {
            otpErrorText.value = otpErrors.first.toString();
          } else {
            otpErrorText.value = 'Kode OTP salah';
          }
        }

        Get.snackbar(
          'Registrasi Gagal',
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

  // ─── RESEND OTP ────────────────────────────────────
  Future<void> resendOtp() async {
    otpController.clear();
    otpValue.value = '';
    otpErrorText.value = '';
    verifyStatusText.value = '';
    isOtpVerified.value = false;
    await verifyEmail();
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
