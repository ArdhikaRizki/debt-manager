import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/biometric_controller.dart';

class ProfileController extends GetxController {
  // --- STATE UNTUK BIODATA ---
  var username = "Loading...".obs;
  var email = "Loading...".obs;
  var bio = "Tidak ada bio".obs;
  
  // --- STATE UNTUK FOTO PROFIL ---
  var photoPath = "".obs; 

  // --- STATE UNTUK BIOMETRIK ---
  var isBiometricActive = false.obs;

  final ApiService _apiService = Get.put(ApiService());
  final BiometricController _biometricC = Get.put(BiometricController());

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    checkBiometricStatus();
  }

  // --- MENGAMBIL DATA PROFILE ---
  Future<void> fetchUserProfile() async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final response = await _apiService.getMe(token);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.body['data'];
        username.value = data['username'] ?? '';
        email.value = data['email'] ?? '';
        // Sesuaikan dengan field dari API jika ada bio atau avatar
        // bio.value = data['bio'] ?? 'Tidak ada bio';
        // photoPath.value = data['avatar'] ?? '';
      }
    } catch (e) {
      print("Error fetch profile: $e");
    }
  }

  // --- CEK STATUS BIOMETRIK ---
  Future<void> checkBiometricStatus() async {
    isBiometricActive.value = await _biometricC.hasBiometricEnabled();
  }

  // --- FUNGSI UPLOAD FOTO ---
  Future<void> pickAndUploadPhoto() async {
    print("Membuka galeri untuk pilih foto...");
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        photoPath.value = image.path; // Update UI sementara (berupa local path)
        
        // TODO: Panggil API upload foto ke Laravel jika endpoint tersedia
        Get.snackbar(
          "Sukses", 
          "Foto berhasil dipilih (Namun belum terupload ke server)", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error pick image: $e");
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