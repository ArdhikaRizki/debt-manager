import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/debt_model.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }
          return RefreshIndicator(
            color: AppColors.primaryTeal,
            onRefresh: controller.fetchDashboard,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(child: _buildSummaryCards()),
                SliverToBoxAdapter(child: _buildQuickActions()),
                SliverToBoxAdapter(child: _buildRecentDebtsHeader()),
                controller.errorMsg.value.isNotEmpty
                    ? SliverToBoxAdapter(
                        child: _buildErrorState(controller.errorMsg.value))
                    : controller.recentDebts.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildDebtCard(
                                  controller.recentDebts[index]),
                              childCount: controller.recentDebts.length,
                            ),
                          ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryTeal, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${controller.currentUsername} 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola hutangmu dengan mudah',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.offAllNamed(AppRoutes.login);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SUMMARY CARDS ─────────────────────────────────────
  Widget _buildSummaryCards() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Saya Berhutang',
                  amount: controller.totalIOwe,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red.shade400,
                  bgColor: Colors.red.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Saya Dihutangi',
                  amount: controller.totalOwedToMe,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.green.shade600,
                  bgColor: Colors.green.shade50,
                ),
              ),
            ],
          ),
        ));
  }

  // ─── QUICK ACTIONS ─────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: '+ Tambah Hutang',
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.primaryTeal,
              onTap: () => Get.toNamed(AppRoutes.debt),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: 'Lihat Grup',
              icon: Icons.group_outlined,
              color: AppColors.primaryBlue,
              onTap: () => Get.toNamed(AppRoutes.group),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT DEBTS HEADER ───────────────────────────────
  Widget _buildRecentDebtsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hutang Terkini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.debt),
            child: const Text(
              'Lihat Semua →',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DEBT CARD ─────────────────────────────────────────
  Widget _buildDebtCard(DebtModel debt) {
    final isOwner = debt.userId == controller.currentUserId;
    final otherParty = isOwner
        ? (debt.otherUser?.username ?? 'User #${debt.otherUserId}')
        : (debt.owner?.username ?? 'User #${debt.userId}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.debtDetail, arguments: debt),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOwner
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOwner
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isOwner
                        ? Colors.green.shade600
                        : Colors.red.shade400,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOwner
                            ? 'Piutang ke $otherParty'
                            : 'Hutang ke $otherParty',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        debt.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(debt.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isOwner
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(status: debt.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── EMPTY STATE ───────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data hutang',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap tombol "+ Tambah Hutang" untuk mulai mencatat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ───────────────────────────────────────
  Widget _buildErrorState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red),
          const SizedBox(height: 12),
          Text(msg,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textGrey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.fetchDashboard,
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

  // ─── BOTTOM NAV ────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryTeal,
      unselectedItemColor: AppColors.textGrey,
      backgroundColor: Colors.white,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Get.toNamed(AppRoutes.debt);
            break;
          case 2:
            Get.toNamed(AppRoutes.group);
            break;
          case 3:
            Get.toNamed(AppRoutes.timezone);
            break;
          case 4:
            Get.toNamed(AppRoutes.currency);
            break;
          case 5:
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined), label: 'Hutang'),
        BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined), label: 'Grup'),
        BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded), label: 'Waktu'),
        BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange_rounded), label: 'Kurs'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
      ],
    );
  }
}

// ─── HELPER FUNCTION ───────────────────────────────────
String _formatCurrency(double amount) {
  final parts = amount.toStringAsFixed(0).split('');
  final buffer = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
    buffer.write(parts[i]);
  }
  return 'Rp ${buffer.toString()}';
}

// ─── SUMMARY CARD WIDGET ───────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACTION BUTTON WIDGET ──────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STATUS CHIP WIDGET ────────────────────────────────
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
      case 'settlement_requested':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        label = 'Diajukan';
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
