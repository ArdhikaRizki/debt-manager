import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    required String toUsername,
    required double amount,
    required String description,
  }) async {
    final g = group.value;
    if (g == null) return;
    final token = AuthStorage.getToken();
    if (token == null) return;

    try {
      final res = await _api.createGroupTransaction(
        g.id,
        {
          'toUsername': toUsername,
          'amount': amount,
          'description': description,
        },
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

  // Menghitung debt chain: siapa bisa dibayar oleh siapa secara tidak langsung
  // Contoh: A hutang B 100rb, B hutang C 50rb → A bisa langsung bayar C 50rb
  void _computeDebtChains() {
    final chains = <DebtChain>[];

    // Buat mutable map borrow (berhutang dari) dan lend (menghutangi ke)
    // Gunakan algoritma penyederhanaan hutang (debt simplification)
    final debts = <int, Map<int, double>>{};

    for (final tx in transactions) {
      // Skip transaksi yang sudah lunas (approved)
      final isApproved = (tx.settlementRequests ?? []).any((r) => r.status == 'approved');
      if (isApproved) continue;

      debts[tx.fromUserId] ??= {};
      debts[tx.fromUserId]![tx.toUserId] =
          (debts[tx.fromUserId]![tx.toUserId] ?? 0) + tx.amount;
    }

    // Sederhanakan: jika A berhutang B dan B berhutang C,
    // maka A bisa bayar langsung ke C
    debts.forEach((fromId, toMap) {
      toMap.forEach((toId, amount) {
        // Cek apakah toId juga berhutang ke orang lain (chain)
        if (debts.containsKey(toId)) {
          debts[toId]!.forEach((nextId, nextAmount) {
            if (nextId != fromId) {
              // A bisa bayar ke nextId sebesar min(amount, nextAmount)
              final transferable = amount < nextAmount ? amount : nextAmount;
              chains.add(DebtChain(
                fromId: fromId,
                middleId: toId,
                toId: nextId,
                amount: transferable,
              ));
            }
          });
        }
      });
    });

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
class DebtChain {
  final int fromId;
  final int middleId;
  final int toId;
  final double amount;

  const DebtChain({
    required this.fromId,
    required this.middleId,
    required this.toId,
    required this.amount,
  });
}
