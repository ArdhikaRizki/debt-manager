import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/debt_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

import '../home/home_controller.dart'; // Sesuaikan path-nya jika beda folder
import 'debt_controller.dart';

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
        _refreshBackgroundControllers(); // Refresh layar lain yang mungkin terpengaruh
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

  Future<void> deleteDebt(int id) async {
    if (isActing.value) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      final res = await _api.deleteDebt(id, token);
      if (res.statusCode == 200 || res.statusCode == 204) {
        Get.snackbar('Berhasil', 'Catatan hutang berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
            _refreshBackgroundControllers();
        Get.back(result: true); // Kembali ke list & beri tau untuk refresh
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar('Gagal', body?['message'] ?? 'Gagal menghapus hutang',
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
        _refreshBackgroundControllers();
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
  Future<void> rejectDebt() async {
    if (isActing.value || debt.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      final res = await _api.rejectDebt(debt.value!.id, token);
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Kamu telah menolak tagihan hutang ini',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
        await _fetchDetail(debt.value!.id); // Refresh detail

        _refreshBackgroundControllers();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar('Gagal', body?['message'] as String? ?? 'Gagal menolak hutang',
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

  Future<void> confirmSettlement() async {
    if (isActing.value || debt.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      final res = await _api.confirmSettlement(debt.value!.id, token);
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Hutang telah dinyatakan lunas!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
        await _fetchDetail(debt.value!.id);
        _refreshBackgroundControllers();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar('Gagal', body?['message'] as String? ?? 'Gagal konfirmasi pelunasan',
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

  Future<void> rejectSettlement() async {
    if (isActing.value || debt.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isActing.value = true;
    try {
      final res = await _api.rejectSettlement(debt.value!.id, token);
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Pelunasan ditolak',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12));
        await _fetchDetail(debt.value!.id);
        _refreshBackgroundControllers();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar('Gagal', body?['message'] as String? ?? 'Gagal menolak pelunasan',
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

  // --- Fungsi untuk me-refresh layar di background ---
  void _refreshBackgroundControllers() {
    // Refresh Home (Dashboard) kalau controller-nya sedang aktif
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchDashboard();
    }
    // Refresh List Hutang kalau controller-nya sedang aktif
    if (Get.isRegistered<DebtController>()) {
      Get.find<DebtController>().fetchDebts();
    }
  }
}
