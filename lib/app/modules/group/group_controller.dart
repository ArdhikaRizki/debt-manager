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

  String get currentUsername {
    final user = AuthStorage.getUser();
    return user?['username'] as String? ?? '';
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

  /// Cari user by username — returns username string atau null jika tidak ditemukan
  Future<String?> searchUser(String username) async {
    final token = AuthStorage.getToken();
    if (token == null) return null;
    try {
      final res = await _api.searchUser(username, token);
      if (res.statusCode == 200 && res.body != null) {
        final body = res.body as Map<String, dynamic>;
        final data = body['data'];
        if (data is List && data.isNotEmpty) {
          final exact = data.firstWhere(
            (u) =>
                (u['username'] as String?)?.toLowerCase() ==
                username.toLowerCase(),
            orElse: () => data.first,
          );
          return exact['username'] as String?;
        }
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Buat grup dan langsung tambahkan members
  Future<void> createGroup(
    String name,
    String? description, {
    List<String> memberUsernames = const [],
  }) async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final body = <String, dynamic>{'name': name};
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      final res = await _api.createGroup(body, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        final resBody = res.body as Map<String, dynamic>?;
        final groupData = resBody?['data'] as Map<String, dynamic>?;
        final groupId = groupData?['id'];

        if (groupId != null && memberUsernames.isNotEmpty) {
          final id = groupId is int
              ? groupId
              : int.tryParse(groupId.toString());
          if (id != null) {
            for (final uname in memberUsernames) {
              try {
                await _api.addGroupMember(id, uname, token);
              } catch (_) {}
            }
          }
        }

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
