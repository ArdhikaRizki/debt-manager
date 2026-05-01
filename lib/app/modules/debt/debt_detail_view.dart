import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import 'debt_detail_controller.dart';

class DebtDetailView extends GetView<DebtDetailController> {
  const DebtDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        title: const Text('Detail Hutang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryTeal));
        }
        if (controller.errorMsg.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 12),
                Text(controller.errorMsg.value,
                    style: const TextStyle(color: AppColors.textGrey)),
              ],
            ),
          );
        }
        final debt = controller.debt.value;
        if (debt == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        // isOwner = user adalah pemilik debt (userId == currentUserId)
        // isOtherUser = user adalah pihak lawan (otherUserId == currentUserId)
        final isOwner = controller.isOwner;
        final otherParty = isOwner
            ? (debt.otherUser?.username ?? 'User #${debt.otherUserId}')
            : (debt.owner?.username ?? 'User #${debt.userId}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── MAIN CARD ──────────────────────────────
              Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Amount & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                              isOwner ? 'Kamu menagih' : 'Kamu berhutang',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(debt.amount),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isOwner
                                      ? Colors.green.shade700
                                      : Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                          _StatusBadge(status: debt.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      // Info rows
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: isOwner ? 'Peminjam' : 'Pemberi Pinjaman',
                        value: otherParty,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Keterangan',
                        value: debt.description,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Dibuat',
                        value: _formatDate(debt.createdAt),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.update_rounded,
                        label: 'Terakhir Diperbarui',
                        value: _formatDate(debt.updatedAt),
                      ),
                      if (debt.groupId != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.group_outlined,
                          label: 'ID Grup',
                          value: debt.groupId.toString(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // ── ACTION BUTTONS ─────────────────────────
              Obx(() => _buildActions(debt.status)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActions(String status) {
    // otherUser (pihak lawan yang di-konfirmasi) yang bisa confirm
    if (controller.isOtherUser && status == 'pending') {
      return _ActionBtn(
        label: 'Konfirmasi Hutang',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.primaryBlue,
        isLoading: controller.isActing.value,
        onTap: controller.confirmDebt,
      );
    }

    // Owner (pembuat debt) yang bisa ajukan pelunasan
    if (controller.isOwner && status == 'confirmed') {
      return _ActionBtn(
        label: 'Ajukan Pelunasan',
        icon: Icons.payment_rounded,
        color: Colors.green.shade600,
        isLoading: controller.isActing.value,
        onTap: controller.requestSettlement,
      );
    }

    // otherUser (pihak lawan) sedang pending → tampilkan info menunggu
    if (controller.isOtherUser && status == 'pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty_rounded,
                color: Colors.orange.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Menunggu konfirmasi dari peminjam',
              style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    // Status sudah settlement_requested atau isPaid
    if (status == 'settlement_requested') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions_rounded,
                color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              'Permintaan pelunasan sedang diproses',
              style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    if (status == 'settled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Text('Hutang sudah lunas',
                style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── INFO ROW ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textGrey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── STATUS BADGE ──────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'confirmed':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        label = 'Dikonfirmasi';
        break;
      case 'settled':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = 'Lunas';
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

// ─── ACTION BUTTON ─────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          isLoading ? 'Memproses...' : label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
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
  final months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
