import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../data/models/group_model.dart';
import '../../data/models/group_transaction_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';

class GroupTransactionController extends GetxController {
  late final ApiService _api;

  // ─── State ─────────────────────────────────────────────
  final group = Rxn<GroupModel>();
  final transactions = <GroupTransactionModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final isFetchingLocation = false.obs;

  // ─── LBS / GPS Helper ─────────────────────────────────
  Future<String?> getLocationAsString() async {
    isFetchingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Mati', 'Tolong nyalakan GPS (Lokasi) HP kamu.',
            backgroundColor: Colors.orangeAccent, colorText: Colors.white);
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Izin Ditolak', 'Izin lokasi dibutuhkan untuk fitur ini.',
              backgroundColor: Colors.redAccent, colorText: Colors.white);
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Izin Ditolak Permanen', 'Silakan izinkan lewat pengaturan HP.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Contoh: "Jl. Sudirman, Sleman"
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? place.locality ?? '';
        final combined = [street, subLocality].where((e) => e.isNotEmpty).join(', ');
        return combined.isNotEmpty ? combined : 'Koordinat: ${position.latitude}, ${position.longitude}';
      }
    } catch (e) {
      debugPrint('LBS Error: $e');
    } finally {
      isFetchingLocation.value = false;
    }
    return null;
  }

  // ─── Computed: net balance per member ──────────────────
  // key=userId, value=netAmount (positif = dihutangi, negatif = berhutang)
  final netBalances = <int, double>{}.obs;

  // ─── Debt chain: siapa bisa bayar siapa ────────────────
  // Daftar pasangan (fromId, toId, amount) yang bisa diselesaikan
  final debtChains = <DebtChain>[].obs;

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
    if (user == null) return '';
    return user['username']?.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    if (Get.arguments is GroupModel) {
      group.value = Get.arguments as GroupModel;
      fetchTransactions();
    }
  }

  // ─── Fetch Transactions ─────────────────────────────────
  Future<void> fetchTransactions() async {
    final g = group.value;
    if (g == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    isLoading.value = true;
    errorMsg.value = '';

    try {
      final res = await _api.getGroupTransactions(g.id, token);
      if (res.statusCode == 200 && res.body != null) {
        final body = res.body as Map<String, dynamic>;
        final raw = body['data'] ?? res.body;
        if (raw is List) {
          transactions.value = raw
              .map((e) =>
                  GroupTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _computeNetBalances();
          _computeDebtChains();
        }
      } else {
        errorMsg.value = 'Gagal memuat transaksi';
      }
    } catch (e) {
      errorMsg.value = 'Tidak dapat terhubung ke server';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Create Transaction ─────────────────────────────────
  Future<void> createTransaction({
    String? fromUsername,
    required String toUsername,
    required double amount,
    required String description,
  }) async {
    final g = group.value;
    if (g == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final body = {
        'toUsername': toUsername,
        'amount': amount,
        'description': description,
      };
      if (fromUsername != null) {
        body['fromUsername'] = fromUsername;
      }

      final res = await _api.createGroupTransaction(
        g.id,
        body,
        token,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchTransactions();
        Get.snackbar(
          'Berhasil',
          'Transaksi berhasil dicatat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12),
        );
      } else {
        final body = res.body as Map<String, dynamic>?;
        final msg = body?['message'] as String? ?? 'Gagal membuat transaksi';
        Get.snackbar(
          'Gagal',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ─── Settle Debt Chain ─────────────────────────────────
  // Membuat settlement request untuk setiap transaksi aktif antara fromId → toId
  // agar tidak membuat hutang baru (yang menyebabkan duplikasi angka)
  Future<void> settleDebtChain(DebtChain chain) async {
    final token = AuthStorage.getToken();
    if (token == null) return;

    // Cari semua transaksi aktif (belum lunas & belum ada pending) antara fromId → toId
    final activeTxs = transactions.where((tx) {
      final isApproved = (tx.settlementRequests ?? []).any((r) => r.status == 'approved');
      final hasPending  = (tx.settlementRequests ?? []).any((r) => r.status == 'pending');
      return !isApproved && !hasPending &&
             tx.fromUserId == chain.fromId &&
             tx.toUserId  == chain.toId;
    }).toList();

    if (activeTxs.isEmpty) {
      Get.snackbar(
        'Info',
        'Tidak ada transaksi aktif yang bisa diselesaikan untuk chain ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    int successCount = 0;
    for (final tx in activeTxs) {
      try {
        final res = await _api.createGroupSettlement(tx.id, token);
        if (res.statusCode == 200 || res.statusCode == 201) successCount++;
      } catch (_) {
        // lanjut ke transaksi berikutnya
      }
    }

    await fetchTransactions();

    if (successCount > 0) {
      Get.snackbar(
        'Berhasil',
        'Pengajuan pelunasan terkirim ($successCount transaksi)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal mengajukan pelunasan. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ─── Delete Transaction ─────────────────────────────────

  Future<void> deleteTransaction(int txId) async {
    final token = AuthStorage.getToken();
    if (token == null) return;
    try {
      final res = await _api.deleteGroupTransaction(txId, token);
      if (res.statusCode == 200) {
        await fetchTransactions();
        Get.snackbar(
          'Dihapus',
          'Transaksi berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
          'Gagal',
          body?['message'] as String? ?? 'Gagal menghapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    }
  }

  // ─── Request Settlement for Group Transaction ────────────
  Future<void> requestSettlementForTx(int groupTransactionId) async {
    final token = AuthStorage.getToken();
    if (token == null) return;
    try {
      final res = await _api.createGroupSettlement(groupTransactionId, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar(
          'Berhasil',
          'Pengajuan pelunasan terkirim',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        await fetchTransactions();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
          'Gagal',
          body?['message'] as String? ?? 'Gagal mengajukan pelunasan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12));
    }
  }

  // ─── Approve Settlement ─────────────────────────────────
  Future<void> approveSettlement(int settlementId) async {
    final token = AuthStorage.getToken();
    if (token == null) return;
    try {
      final res = await _api.approveSettlementReq(settlementId, token);
      if (res.statusCode == 200) {
        Get.snackbar(
          'Berhasil',
          'Pelunasan berhasil disetujui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        await fetchTransactions();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
          'Gagal',
          body?['message'] as String? ?? 'Gagal menyetujui pelunasan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    }
  }

  // ─── Reject Settlement ─────────────────────────────────
  Future<void> rejectSettlement(int settlementId) async {
    final token = AuthStorage.getToken();
    if (token == null) return;
    try {
      final res = await _api.rejectSettlementReq(settlementId, token);
      if (res.statusCode == 200) {
        Get.snackbar(
          'Berhasil',
          'Pelunasan ditolak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        await fetchTransactions();
      } else {
        final body = res.body as Map<String, dynamic>?;
        Get.snackbar(
          'Gagal',
          body?['message'] as String? ?? 'Gagal menolak pelunasan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF44336),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat terhubung ke server');
    }
  }

  // ─── DEBT CHAIN LOGIC ────────────────────────────────────
  // Menghitung net balance: positif = dihutangi orang ini, negatif = berhutang
  void _computeNetBalances() {
    final balances = <int, double>{};
    for (final tx in transactions) {
      // Skip transaksi yang sudah lunas (approved)
      final isApproved = (tx.settlementRequests ?? []).any((r) => r.status == 'approved');
      if (isApproved) continue;

      // fromUser berhutang kepada toUser → fromUser - amount, toUser + amount
      balances[tx.fromUserId] = (balances[tx.fromUserId] ?? 0) - tx.amount;
      balances[tx.toUserId] = (balances[tx.toUserId] ?? 0) + tx.amount;
    }
    netBalances.value = balances;
  }

  void _computeDebtChains() {
    // Algoritma greedy berbasis saldo bersih:
    // Semua debitor (saldo negatif) langsung bayar ke kreditor (saldo positif)
    // tanpa perantara (via). Chain hanya muncul jika ada >1 kreditor.
    final chains = <DebtChain>[];

    // Buat salinan saldo yang bisa dimodifikasi
    final debtors = <int, double>{}; // userId -> jumlah yang harus dibayar
    final creditors = <int, double>{}; // userId -> jumlah yang akan diterima

    netBalances.forEach((userId, balance) {
      if (balance < -0.01) {
        debtors[userId] = -balance; // simpan sebagai positif
      } else if (balance > 0.01) {
        creditors[userId] = balance;
      }
    });

    // Greedy matching: setiap debitor bayar ke kreditor satu per satu
    final debtorList = debtors.keys.toList();
    final creditorList = creditors.keys.toList();

    int ci = 0;
    int di = 0;

    while (di < debtorList.length && ci < creditorList.length) {
      final fromId = debtorList[di];
      final toId = creditorList[ci];

      final owes = debtors[fromId]!;
      final receives = creditors[toId]!;

      final transfer = owes < receives ? owes : receives;

      if (transfer > 0.01) {
        chains.add(DebtChain(
          fromId: fromId,
          toId: toId,
          amount: transfer,
        ));
      }

      debtors[fromId] = owes - transfer;
      creditors[toId] = receives - transfer;

      if (debtors[fromId]! <= 0.01) di++;
      if (creditors[toId]! <= 0.01) ci++;
    }

    debtChains.value = chains;
  }

  // ─── Helper: username dari userId ────────────────────────
  String usernameOf(int userId) {
    final members = group.value?.members;
    if (members == null) return 'User #$userId';
    try {
      final member = members.firstWhere((m) => m.userId == userId);
      return member.user?.username ?? 'User #$userId';
    } catch (_) {
      return 'User #$userId';
    }
  }
}

// ─── Data class untuk debt chain (public) ────────────────
// Pembayaran langsung: fromId bayar toId sejumlah amount (tanpa perantara)
class DebtChain {
  final int fromId;
  final int toId;
  final double amount;

  const DebtChain({
    required this.fromId,
    required this.toId,
    required this.amount,
  });
}
