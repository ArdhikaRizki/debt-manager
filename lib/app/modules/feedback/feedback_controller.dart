import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_storage.dart';

class FeedbackController extends GetxController {
  static const int maxCharsPerField = 1000;

  final saranController = TextEditingController();
  final kesanController = TextEditingController();

  final RxList<Map<String, dynamic>> feedbacks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString saranError = ''.obs;
  final RxString kesanError = ''.obs;
  final RxInt saranCharCount = 0.obs;
  final RxInt kesanCharCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeedbacks();
    
    // Listen untuk perubahan pada saran
    saranController.addListener(() {
      final text = saranController.text;
      _updateSaranStats(text);
    });
    
    // Listen untuk perubahan pada kesan
    kesanController.addListener(() {
      final text = kesanController.text;
      _updateKesanStats(text);
    });
  }

  void _updateSaranStats(String text) {
    saranCharCount.value = text.length;
    _validateSaran(text);
  }

  void _updateKesanStats(String text) {
    kesanCharCount.value = text.length;
    _validateKesan(text);
  }

  void _validateSaran(String text) {
    if (text.isEmpty) {
      saranError.value = '';
      return;
    }
    
    if (_containsDangerousChars(text)) {
      saranError.value = 'Tidak boleh mengandung karakter berbahaya';
      return;
    }
    
    if (text.length > maxCharsPerField) {
      saranError.value = 'Maksimal $maxCharsPerField karakter';
      return;
    }
    
    saranError.value = '';
  }

  void _validateKesan(String text) {
    if (text.isEmpty) {
      kesanError.value = '';
      return;
    }
    
    if (_containsDangerousChars(text)) {
      kesanError.value = 'Tidak boleh mengandung karakter berbahaya';
      return;
    }
    
    if (text.length > maxCharsPerField) {
      kesanError.value = 'Maksimal $maxCharsPerField karakter';
      return;
    }
    
    kesanError.value = '';
  }

  bool _containsDangerousChars(String text) {
    // Check untuk karakter yang bisa berbahaya (SQL injection, XSS)
    // Kami tidak akan memblokir quotes tapi akan sanitasi
    // Hanya blokir jika ada pattern yang mencurigakan
    final suspiciousPatterns = [
      'script',
      'onclick',
      'onerror',
      'onload',
      'drop table',
      'delete from',
      'insert into',
      'select ',
      'update ',
      'union',
    ];
    
    final lowerText = text.toLowerCase();
    return suspiciousPatterns.any((pattern) => lowerText.contains(pattern));
  }

  String _getFeedbackKey() {
    final user = AuthStorage.getUser();
    final userId = user?['id']?.toString() ?? 'anonymous';
    return 'feedbacks_$userId';
  }

  Future<void> loadFeedbacks() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getFeedbackKey();
      final String? dataString = prefs.getString(key);
      
      if (dataString != null) {
        final List<dynamic> decodedList = jsonDecode(dataString);
        final List<Map<String, dynamic>> data = decodedList
            .map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final createdAt = map['created_at'];

              if (createdAt is String) {
                final parsedDate = DateTime.tryParse(createdAt);
                map['created_at'] = parsedDate?.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch;
              } else if (createdAt is! int) {
                map['created_at'] = DateTime.now().millisecondsSinceEpoch;
              }

              map['saran'] = map['saran']?.toString() ?? '';
              map['kesan'] = map['kesan']?.toString() ?? '';
              return map;
            })
            .toList();
        feedbacks.assignAll(data);
      } else {
        feedbacks.clear();
      }
    } catch (e) {
      debugPrint('Error loading feedbacks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFeedback() async {
    final saran = saranController.text.trim();
    final kesan = kesanController.text.trim();

    // Validasi awal
    if (saran.isEmpty || kesan.isEmpty) {
      Get.snackbar('Error', 'Saran dan Kesan tidak boleh kosong', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validasi error
    if (saranError.value.isNotEmpty) {
      Get.snackbar('Error Saran', saranError.value, 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (kesanError.value.isNotEmpty) {
      Get.snackbar('Error Kesan', kesanError.value, 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getFeedbackKey();
      
      final newFeedback = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'saran': saran,
        'kesan': kesan,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Tambahkan ke list (di awal agar terbaru di atas)
      feedbacks.insert(0, newFeedback);
      
      final success = await prefs.setString(key, jsonEncode(feedbacks));
      
      if (success) {
        saranController.clear();
        kesanController.clear();
        saranError.value = '';
        kesanError.value = '';
        saranCharCount.value = 0;
        kesanCharCount.value = 0;
        
        Get.snackbar('Sukses', 'Saran dan Kesan berhasil disimpan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Rollback jika gagal
        feedbacks.removeAt(0);
        Get.snackbar('Error', 'Gagal menyimpan feedback. Coba lagi.', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
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

  void clearErrors() {
    saranError.value = '';
    kesanError.value = '';
  }
}
