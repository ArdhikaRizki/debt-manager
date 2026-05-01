import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/debt_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class DebtController extends GetxController {
  late final ApiService _api;

  final myDebts = <DebtModel>[].obs;    // current user is debtor
  final owedToMe = <DebtModel>[].obs;   // current user is creditor
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
    fetchDebts();
  }

  Future<void> fetchDebts() async {
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

            myDebts.value =
                all.where((d) => d.otherUserId == currentUserId).toList();
            owedToMe.value =
                all.where((d) => d.userId == currentUserId).toList();
          } catch (e) {
            errorMsg.value = 'Parsing error: $e';
            debugPrint('DEBT PARSE ERROR: $e');
          }
        }
      } else {
        final body = response.body as Map<String, dynamic>?;
        errorMsg.value = body?['message'] as String? ?? 'Gagal memuat data';
      }
    } catch (e) {
      errorMsg.value = 'Network error: $e';
      debugPrint('DEBT NETWORK ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
