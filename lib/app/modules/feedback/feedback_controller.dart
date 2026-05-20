import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/local_db_service.dart';

class FeedbackController extends GetxController {
  final LocalDbService _localDbService = Get.find<LocalDbService>();

  final saranController = TextEditingController();
  final kesanController = TextEditingController();

  final RxList<Map<String, dynamic>> feedbacks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    isLoading.value = true;
    try {
      final data = await _localDbService.getFeedbacks();
      feedbacks.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFeedback() async {
    final saran = saranController.text.trim();
    final kesan = kesanController.text.trim();

    if (saran.isEmpty || kesan.isEmpty) {
      Get.snackbar('Error', 'Saran dan Kesan tidak boleh kosong', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _localDbService.saveFeedback(saran, kesan);
      saranController.clear();
      kesanController.clear();
      
      Get.snackbar('Sukses', 'Saran dan Kesan berhasil disimpan ke DB lokal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      
      // Refresh list
      await loadFeedbacks();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    saranController.dispose();
    kesanController.dispose();
    super.onClose();
  }
}
