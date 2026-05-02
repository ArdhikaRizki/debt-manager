import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/group_model.dart';
import '../../routes/app_routes.dart';
import 'group_detail_controller.dart';

class GroupDetailView extends GetView<GroupDetailController> {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        title: const Text('Detail Grup',
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

        final group = controller.group.value;
        if (group == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        final isCreator = group.creatorId == controller.currentUserId;

        return RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: () => controller.fetchDetail(group.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER CARD ──────────────────────────
                Card(
                  elevation: 3,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryTeal,
                                AppColors.primaryBlue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              group.name.isNotEmpty
                                  ? group.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          group.name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                        if (group.description != null &&
                            group.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            group.description!,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textGrey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                                Icons.people_outline,
                                '${group.members?.length ?? 0} Anggota',
                                'Total Anggota'),
                            _buildStatItem(
                                Icons.calendar_today_outlined,
                                _formatDate(group.createdAt),
                                'Tanggal Dibuat'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ── TOMBOL LIHAT TRANSAKSI ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(
                      AppRoutes.groupTransaction,
                      arguments: group,
                    ),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Lihat Transaksi & Hutang Grup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── MEMBER LIST ──────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Anggota Grup',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark),
                    ),
                    if (isCreator)
                      TextButton.icon(
                        onPressed: () => _showAddMemberSheet(context),
                        icon: const Icon(Icons.person_add_alt_1_rounded,
                            size: 18, color: AppColors.primaryTeal),
                        label: const Text('Tambah',
                            style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (group.members == null || group.members!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('Belum ada anggota',
                          style: TextStyle(color: AppColors.textGrey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: group.members!.length,
                    itemBuilder: (context, index) {
                      final member = group.members![index];
                      // isMe: cek apakah userId member == currentUser
                      final isMe = member.userId == controller.currentUserId;
                      // isAdmin: cek role dari member
                      final isAdmin = member.role == 'admin';
                      final memberUsername = member.user?.username ?? 'User #${member.userId}';
                      final memberEmail = member.user?.email ?? '';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                            child: const Icon(Icons.person,
                                color: AppColors.primaryTeal),
                          ),
                          title: Row(
                            children: [
                              Text(memberUsername,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              if (isMe) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryTeal,
                                      borderRadius:
                                          BorderRadius.circular(4)),
                                  child: const Text('Saya',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                              if (isAdmin) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.amber.shade600,
                                      borderRadius:
                                          BorderRadius.circular(4)),
                                  child: const Text('Admin',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]
                            ],
                          ),
                          subtitle: memberEmail.isNotEmpty
                              ? Text(memberEmail,
                                  style: const TextStyle(fontSize: 12))
                              : null,
                          trailing: (isCreator && !isMe)
                              ? IconButton(
                                  icon: const Icon(
                                      Icons.person_remove_rounded,
                                      color: Colors.redAccent),
                                  onPressed: () =>
                                      _confirmRemoveMember(context, member),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textGrey, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ],
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    final usernameCtrl = TextEditingController();
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
                const Text('Tambah Anggota',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username Pengguna',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: usernameCtrl,
                      keyboardType: TextInputType.text,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan username pengguna...',
                        hintStyle: const TextStyle(color: AppColors.textGrey),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              color: AppColors.primaryTeal, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Get.back();
                      // Backend menerima username (string)
                      await controller.addMember(usernameCtrl.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tambah',
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

  void _confirmRemoveMember(BuildContext context, GroupMemberModel member) {
    final memberUsername = member.user?.username ?? 'User #${member.userId}';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Anggota',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Yakin ingin menghapus $memberUsername dari grup ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // removeMember menerima userId (int)
              controller.removeMember(member.userId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
