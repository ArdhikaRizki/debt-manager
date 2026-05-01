import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/group_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class GroupDetailController extends GetxController {
  late final ApiService _api;

  final group = Rxn<GroupModel>();
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  int get currentUserId {
    final user = AuthStorage.getUser();
    if (user == null) return 0;
    // Backend bisa kirim 'id' atau 'user_id'
    final id = user['id'] ?? user['user_id'] ?? user['userId'];
    if (id == null) return 0;
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();

    if (Get.arguments is int) {
      _fetchDetail(Get.arguments as int);
    } else if (Get.arguments is GroupModel) {
      group.value = Get.arguments as GroupModel;
    }
  }

  Future<void> fetchDetail(int id) async {
    await _fetchDetail(id);
  }

  Future<void> _fetchDetail(int id) async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    isLoading.value = true;
    errorMsg.value = '';

    try {
      final res = await _api.getGroupDetail(id, token);
      if (res.statusCode == 200 && res.body != null) {
        final body = res.body as Map<String, dynamic>;
        final raw = body['data'] ?? body;
        group.value = GroupModel.fromJson(raw as Map<String, dynamic>);
      } else {
        errorMsg.value = 'Gagal memuat detail grup';
      }
    } catch (_) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMember(String username) async {
    if (group.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      // Backend wajib terima username (string), bukan userId
      final res = await _api.addGroupMember(
          group.value!.id, username, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Berhasil', 'Anggota berhasil ditambahkan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(12));
        await _fetchDetail(group.value!.id);
      } else {
        final body = res.body as Map<String, dynamic>?;
        final msg = body?['message'] as String? ?? 'Gagal menambah anggota (${res.statusCode})';
        Get.snackbar('Gagal', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(12));
      }
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat terhubung: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12));
    }
  }

  Future<void> removeMember(int userId) async {
    if (group.value == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final res = await _api.removeGroupMember(group.value!.id, userId, token);
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Anggota berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(12));
        await _fetchDetail(group.value!.id);
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
            'Gagal', body?['message'] as String? ?? 'Gagal menghapus anggota',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFF44336),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(12));
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12));
    }
  }
}
