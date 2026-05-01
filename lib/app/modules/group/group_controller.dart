import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/group_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class GroupController extends GetxController {
  late final ApiService _api;

  final groups = <GroupModel>[].obs;
  final isLoading = false.obs;
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

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    isLoading.value = true;
    errorMsg.value = '';

    try {
      final res = await _api.getGroups(token);
      if (res.statusCode == 200 && res.body != null) {
        final body = res.body as Map<String, dynamic>;
        final raw = body['data'] ?? res.body;
        if (raw is List) {
          try {
            groups.value = raw
                .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
                .toList();
          } catch (e) {
            errorMsg.value = 'Parsing error: $e';
            debugPrint('GROUP PARSE ERROR: $e');
          }
        }
      } else {
        final body = res.body as Map<String, dynamic>?;
        errorMsg.value = body?['message'] as String? ?? 'Gagal memuat grup';
      }
    } catch (e) {
      errorMsg.value = 'Network error: $e';
      debugPrint('GROUP NETWORK ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGroup(String name, String? description) async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      final res = await _api.createGroup(body, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchGroups();
        Get.snackbar('Berhasil', 'Grup berhasil dibuat',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: const Color(0xFFFFFFFF),
            margin: const EdgeInsets.all(12));
      } else {
        final resBody = res.body as Map<String, dynamic>?;
        Get.snackbar(
            'Gagal', resBody?['message'] as String? ?? 'Gagal membuat grup',
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
