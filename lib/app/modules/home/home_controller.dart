import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/debt_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class HomeController extends GetxController {
  late final ApiService _api;

  final recentDebts = <DebtModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  // Diisi dari AuthStorage setelah login
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
  String get currentUsername =>
      AuthStorage.getUser()?['username'] as String? ?? 'Pengguna';

  double get totalIOwe {
    // User adalah pihak yang berhutang = otherUserId (pihak lawan yang dikonfirmasi)
    return recentDebts
        .where((d) => d.otherUserId == currentUserId && d.status != 'settlement_requested' && !d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  double get totalOwedToMe {
    // User adalah pemilik debt = userId (yang membuat debt)
    return recentDebts
        .where((d) => d.userId == currentUserId && d.status != 'settlement_requested' && !d.isPaid)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    isLoading.value = true;
    errorMsg.value = '';

    try {
      final response = await _api.getDebts(token);
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body as Map<String, dynamic>;
        final raw = body['data'] ?? response.body;
        if (raw is List) {
          try {
            final all = raw
                .map((e) => DebtModel.fromJson(e as Map<String, dynamic>))
                .toList();
            recentDebts.value = all.take(5).toList();
          } catch (parseError) {
            errorMsg.value = 'Data parsing error: $parseError';
            debugPrint('HOME PARSE ERROR: $parseError');
          }
        }
      } else {
        errorMsg.value = 'Gagal memuat data (${response.statusCode})';
      }
    } catch (e) {
      errorMsg.value = 'Network error: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
