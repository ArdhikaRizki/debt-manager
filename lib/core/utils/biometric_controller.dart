import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../app/data/services/auth_storage.dart';
import '../../app/routes/app_routes.dart';

class BiometricController extends GetxController {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Keys untuk secure storage
  static const _biometricKey = 'active_biometric_token';
  static const _savedAuthToken = 'bio_auth_token';
  static const _savedUserData = 'bio_user_data';

  // 1. Fungsi Utama untuk memunculkan Sensor Jari
  Future<bool> _authenticateUser() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await auth.authenticate(
        localizedReason: 'Scan sidik jari Anda untuk melanjutkan',
      );
    } catch (e) {
      print("Error Auth: $e");
      return false;
    }
  }

  /// Cek apakah biometrik sudah pernah diaktifkan
  Future<bool> hasBiometricEnabled() async {
    final token = await secureStorage.read(key: _biometricKey);
    return token != null;
  }

  // 2. Dipanggil dari Halaman PROFILE (Saat Toggle Diaktifkan)
  Future<void> activateBiometric() async {
    bool isAuthenticated = await _authenticateUser();
    
    if (isAuthenticated) {
      // Generate token acak yang unik
      String newToken = const Uuid().v4(); 
      
      // Simpan biometric key
      await secureStorage.write(key: _biometricKey, value: newToken);

      // Simpan juga auth token & user data yang sedang aktif
      // supaya bisa di-restore saat login biometrik
      final currentToken = AuthStorage.getToken();
      final currentUser = AuthStorage.getUser();

      if (currentToken != null) {
        await secureStorage.write(key: _savedAuthToken, value: currentToken);
      }
      if (currentUser != null) {
        // Simpan user data sebagai string sederhana (key=value pairs)
        final userStr = currentUser.entries
            .map((e) => '${e.key}=${e.value}')
            .join('||');
        await secureStorage.write(key: _savedUserData, value: userStr);
      }

      Get.snackbar(
        "Sukses", 
        "Biometrik berhasil diaktifkan!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Gagal", 
        "Verifikasi sidik jari dibatalkan.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  // 3. Dipanggil dari Halaman LOGIN (Saat klik ikon Sidik Jari)
  Future<void> loginWithBiometric() async {
    // Cek dulu apakah ada biometric key di brankas HP
    String? savedBioKey = await secureStorage.read(key: _biometricKey);
    
    if (savedBioKey == null) {
      Get.snackbar(
        "Info", 
        "Anda belum mengaktifkan login biometrik. Aktifkan di halaman Profile.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Jika ada, munculkan sensor jari
    bool isAuthenticated = await _authenticateUser();
    
    if (isAuthenticated) {
      // Restore auth token dari brankas HP
      final savedToken = await secureStorage.read(key: _savedAuthToken);
      final savedUserStr = await secureStorage.read(key: _savedUserData);

      if (savedToken == null) {
        Get.snackbar(
          "Gagal", 
          "Sesi biometrik kadaluarsa. Silakan login manual.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }

      // Restore ke AuthStorage
      await AuthStorage.saveToken(savedToken);

      if (savedUserStr != null) {
        final userMap = <String, dynamic>{};
        for (final pair in savedUserStr.split('||')) {
          final parts = pair.split('=');
          if (parts.length == 2) {
            // Coba parse angka
            final val = int.tryParse(parts[1]) ?? parts[1];
            userMap[parts[0]] = val;
          }
        }
        await AuthStorage.saveUser(userMap);
      }

      Get.snackbar(
        "Berhasil", 
        "Login biometrik berhasil!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.home);
    }
  }

  // 4. Dipanggil saat LOGOUT
  Future<void> clearBiometricOnLogout() async {
    // Jangan hapus biometric key & saved auth token
    // supaya user masih bisa login biometrik setelah logout
    // Hanya hapus jika user mematikan toggle biometrik di profile
  }

  // 5. Hapus semua data biometrik (saat toggle dimatikan)
  Future<void> deactivateBiometric() async {
    await secureStorage.delete(key: _biometricKey);
    await secureStorage.delete(key: _savedAuthToken);
    await secureStorage.delete(key: _savedUserData);
  }
}