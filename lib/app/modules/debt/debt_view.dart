import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/debt_model.dart';
import '../../routes/app_routes.dart';
import 'debt_controller.dart';

class DebtView extends GetView<DebtController> {
  const DebtView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          title: const Text('Daftar Hutang',
              style: TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'Hutang Saya'),
                    Tab(text: 'Piutang Saya'),
                  ],
                ),
              ),
              body: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryTeal),
                  );
                }
                if (controller.errorMsg.value.isNotEmpty) {
                  return _buildErrorState(controller.errorMsg.value);
                }
                return TabBarView(
                  children: [
                    _buildDebtList(controller.myDebts, isMyDebt: true),
                    _buildDebtList(controller.owedToMe, isMyDebt: false),
                  ],
                );
              }),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showCreateDebtSheet(context),
                backgroundColor: AppColors.primaryTeal,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Tambah Hutang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  Widget _buildDebtList(List<DebtModel> debts, {required bool isMyDebt}) {
    if (debts.isEmpty) {
      return _buildEmptyState(isMyDebt
          ? 'Tidak ada hutang yang kamu miliki'
          : 'Tidak ada orang yang berhutang padamu');
    }
    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: controller.fetchDebts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: debts.length,
        itemBuilder: (_, i) => _DebtCard(
          debt: debts[i],
          currentUserId: controller.currentUserId,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 72, color: AppColors.textGrey.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red),
          const SizedBox(height: 12),
          Text(msg,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.fetchDebts,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDebtSheet(BuildContext context) {
    final debtorIdCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tambah Hutang',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 20),
                _SheetField(
                  controller: debtorIdCtrl,
                  label: 'Username Peminjam',
                  hint: 'Masukkan username peminjam',
                  keyboardType: TextInputType.text,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                _SheetField(
                  controller: amountCtrl,
                  label: 'Jumlah (Rp)',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (double.tryParse(v) == null) return 'Masukkan angka';
                    return null;
                  },
                ),
                _SheetField(
                  controller: descCtrl,
                  label: 'Keterangan',
                  hint: 'Deskripsi hutang...',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      final otherUsername = debtorIdCtrl.text.trim();
                      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      final desc = descCtrl.text.trim();
                      final dueDate = DateTime.now().add(Duration(days: 30)); // Contoh due date, bisa diubah sesuai kebutuhan

                      Get.back(); // tutup bottom sheet
                      
                      await controller.createDebt(otherUsername, amount, desc, dueDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── DEBT CARD ─────────────────────────────────────────
class _DebtCard extends StatelessWidget {
  final DebtModel debt;
  final int currentUserId;

  const _DebtCard({required this.debt, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    // Jika userId == currentUser → user adalah pemilik (creditor/menagih)
    final isOwner = debt.userId == currentUserId;
    final otherParty = isOwner
        ? (debt.otherUser?.username ?? 'User #${debt.otherUserId}')
        : (debt.owner?.username ?? 'User #${debt.userId}');

    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(AppRoutes.debtDetail, arguments: debt);
        if (result == true) {
          Get.find<DebtController>().fetchDebts();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shadowColor: Colors.black12,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                   isOwner ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOwner
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isOwner
                      ? Colors.green.shade600
                      : Colors.red.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherParty,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      debt.description,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: debt.status),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(debt.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isOwner
                          ? Colors.green.shade700
                          : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(debt.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHEET FIELD ───────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── STATUS CHIP ───────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'confirmed':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        label = 'Dikonfirmasi';
        break;
      case 'settled':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Lunas';
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(0).split('');
  final buffer = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
    buffer.write(parts[i]);
  }
  return 'Rp ${buffer.toString()}';
}

String _formatDate(DateTime dt) {
  return '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}
