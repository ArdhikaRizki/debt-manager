import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/biometric_controller.dart';

class ProfileController extends GetxController {
  // --- STATE UNTUK BIODATA ---
  var userId = 0.obs;
  var username = "Loading...".obs;
  var email = "Loading...".obs;
  var photoPath = "".obs;
  var localPhotoPath = "".obs; // Path foto dari memori lokal (fallback)
  var photoVersion = 0.obs; // cache-buster: naik tiap upload berhasil
  var isVerified = false.obs;
  var isLoading = true.obs;
  var errorMessage = "".obs; 

  var isBiometricActive = false.obs;

  final ApiService _apiService = Get.put(ApiService());
  final BiometricController _biometricC = Get.put(BiometricController());

  // Getter URL proxy avatar ke backend
  String getProxyAvatarUrl() {
    if (photoPath.value.isEmpty) return "";
    final baseUrl = _apiService.httpClient.baseUrl ?? 'http://192.168.1.18:5000/api/v1';
    return '$baseUrl/users/${userId.value}/avatar-proxy?v=${photoVersion.value}';
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    checkBiometricStatus();
  }

  // --- MENGAMBIL DATA PROFILE ---
  Future<void> fetchUserProfile() async {
    final token = AuthStorage.getToken();
    if (token == null) {
      errorMessage.value = 'Token tidak ditemukan';
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.getMe(token);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.body['data'] as Map<String, dynamic>?;
        
        if (data != null) {
          userId.value = int.tryParse(data['id'].toString()) ?? 0;
          username.value = data['username'] ?? 'Pengguna';
          email.value = data['email'] ?? '';
          photoPath.value = data['photo_path'] ?? '';
          
          // Cek apakah ada foto lokal yang tersimpan di GetStorage untuk user ini
          final savedLocalPath = GetStorage().read<String>('local_avatar_${userId.value}');
          if (savedLocalPath != null) {
            localPhotoPath.value = savedLocalPath;
          }

          isVerified.value = data['is_verified'] == true || data['is_verified'] == 1;
        }
      } else {
        errorMessage.value = 'Gagal memuat profil';
      }
    } catch (e) {
      print("Error fetch profile: $e");
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // --- CEK STATUS BIOMETRIK ---
  Future<void> checkBiometricStatus() async {
    isBiometricActive.value = await _biometricC.hasBiometricEnabled();
  }

  // --- STATE UPLOAD ---
  var isUploading = false.obs;

  // --- FUNGSI UPLOAD FOTO ---
  Future<void> pickAndUploadPhoto() async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Kompres sedikit sebelum kirim
        maxWidth: 800,
      );

      if (image == null) return; // User batal pilih

      isUploading.value = true;

      final response = await _apiService.uploadAvatar(image.path, token);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.body['data'] as Map<String, dynamic>?;
        final newUrl = data?['photo_path'] as String?;

        if (newUrl != null && newUrl.isNotEmpty) {
          photoPath.value = newUrl;
          localPhotoPath.value = image.path; // Set state lokal
          GetStorage().write('local_avatar_${userId.value}', image.path); // Simpan ke SharedPreferences (GetStorage)
          photoVersion.value++; // invalidate Flutter image cache
        }

        Get.snackbar(
          'Berhasil',
          'Foto profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade500,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        final msg = response.body?['message'] as String? ?? 'Gagal upload foto';
        Get.snackbar(
          'Gagal',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      debugPrint('Error upload avatar: $e');
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isUploading.value = false;
    }
  }

  // --- FUNGSI TOGGLE BIOMETRIK ---
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      print("Memanggil UI Sensor Sidik Jari...");
      await _biometricC.activateBiometric();
      // Cek ulang apakah proses verifikasi sidik jari sukses dan token tersimpan
      await checkBiometricStatus();
    } else {
      // Hapus semua data biometrik (key + saved token + user data)
      await _biometricC.deactivateBiometric();
      isBiometricActive.value = false;
      
      Get.snackbar(
        "Info", 
        "Login Biometrik telah dimatikan", 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade400,
        colorText: Colors.white,
      );
    }
  }

  // --- FUNGSI LOGOUT ---
  void logout() async {
    await AuthStorage.clearAll();
    await _biometricC.clearBiometricOnLogout();
    Get.offAllNamed(AppRoutes.login);
  }
}