import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../data/models/debt_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class DebtController extends GetxController {
  late final ApiService _api;

  static const int maxDescriptionLength = 500;

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

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> createDebt(String otherUsername, double amount, String description, DateTime dueDate) async {
    final token = AuthStorage.getToken();
    if (token == null) {
      Get.snackbar('Error', 'Sesi telah habis, silakan login kembali');
      return;
    }

    // Validasi deskripsi
    final descValidation = _validateDescription(description);
    if (descValidation != null) {
      Get.snackbar('Error', descValidation);
      return;
    }

    try {
      // Sanitasi deskripsi
      final sanitizedDesc = _sanitizeDescription(description);
      
      // Format due_date sebagai YYYY-MM-DD
      final dueDateStr = '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
      
      final body = {
        'amount': amount,
        'description': sanitizedDesc,
        'due_date': dueDateStr,
        'otherUsername': otherUsername,
      };

      final response = await _api.createDebt(body, token);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Sukses', 'Berhasil mencatat utang baru');
        fetchDebts(); // Refresh data
      } else {
        final resBody = response.body as Map<String, dynamic>?;
        Get.snackbar('Gagal', resBody?['message'] ?? 'Terjadi kesalahan saat menyimpan data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Kesalahan jaringan: $e');
    }
  }

  /// Validasi deskripsi - return error message jika ada masalah
String? _validateDescription(String description) {
  final trimmed = description.trim();

  if (trimmed.isEmpty) return 'Deskripsi tidak boleh kosong';

  if (trimmed.length > maxDescriptionLength) {
    return 'Deskripsi maksimal $maxDescriptionLength karakter (saat ini: ${trimmed.length})';
  }

  // Hanya blokir SQL/XSS, quotes akan di-sanitasi
  final sqlPattern = RegExp(
    r'(drop\s+table|delete\s+from|insert\s+into|select\s+|update\s+|union\s+)',
    caseSensitive: false,
  );
  final xssPattern = RegExp(
    r'(script|onerror|onclick|onload|javascript)',
    caseSensitive: false,
  );

  if (sqlPattern.hasMatch(trimmed) || xssPattern.hasMatch(trimmed)) {
    return 'Deskripsi mengandung karakter tidak diperbolehkan';
  }

  return null;
}

  /// Sanitasi deskripsi
  String _sanitizeDescription(String description) {
    String sanitized = description.trim();
    
    // Ganti single quote dengan apostrophe yang aman
    sanitized = sanitized.replaceAll("'", "'");
    // Ganti double quote dengan safe double quote  
    sanitized = sanitized.replaceAll('"', '"');
    // Ganti backslash dengan forward slash
    sanitized = sanitized.replaceAll('\\', '/');
    
    return sanitized;
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

            // myDebts (Hutangku): posisiku sebagai otherUserId (peminjam)
            myDebts.value =
                all.where((d) => d.otherUserId == currentUserId).toList();

            // owedToMe (Piutangku): posisiku sebagai userId (yang menagih/owner)
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
