import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/debt_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class DebtDetailController extends GetxController {
  late final ApiService _api;

  final debt = Rxn<DebtModel>();
  final isLoading = false.obs;
  final isActing = false.obs; // confirm / settle in progress
  final errorMsg = ''.obs;

  int get currentUserId {
    final user = AuthStorage.getUser();
    if (user == null) return 0;
    final id = user['id'] ?? user['user_id'] ?? user['userId'];
    if (id == null) return 0;
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  // User adalah 'otherUser' (pihak lawan) jika otherUserId == currentUserId
  // → mereka yang confirm, artinya hutang adalah milik mereka
  bool get isOtherUser =>
      debt.value != null && debt.value!.otherUserId == currentUserId;

  // User adalah pemilik debt (yang membuat)
  bool get isOwner =>
      debt.value != null && debt.value!.userId == currentUserId;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    // Debt bisa dikirim via Get.arguments dari halaman sebelumnya
    if (Get.arguments is DebtModel) {
      debt.value = Get.arguments as DebtModel;
    } else if (Get.arguments is int) {
      _fetchDetail(Get.arguments as int);
    }
  }

  Future<void> _fetchDetail(int id) async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    isLoading.value = true;
    try {
      final res = await _api.getDebtDetail(id, token);
      if (res.statusCode == 200 && res.body != null) {
        final body = res.body as Map<String, dynamic>;
        final raw = body['data'] ?? body;
        debt.value = DebtModel.fromJson(raw as Map<String, dynamic>);
      } else {
        errorMsg.value = 'Gagal memuat detail';
      }
    } catch (_) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmDebt() async {
    if (isActing.value || debt.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      final res = await _api.confirmDebt(debt.value!.id, token);
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Hutang berhasil dikonfirmasi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
        await _fetchDetail(debt.value!.id);
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
            'Gagal', body?['message'] as String? ?? 'Gagal konfirmasi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    } finally {
      isActing.value = false;
    }
  }

  Future<void> requestSettlement() async {
    if (isActing.value || debt.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      // POST /settlement-requests dengan body { "debtId": id }
      final res = await _api.requestSettlement(debt.value!.id, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Berhasil', 'Permintaan pelunasan telah dikirim',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
        await _fetchDetail(debt.value!.id);
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
            'Gagal', body?['message'] as String? ?? 'Gagal ajukan pelunasan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    } finally {
      isActing.value = false;
    }
  }
}
