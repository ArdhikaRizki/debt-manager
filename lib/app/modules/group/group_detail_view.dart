import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/member_avatar.dart';
import '../../data/models/group_model.dart';
import '../../routes/app_routes.dart';
import 'group_detail_controller.dart';

class GroupDetailView extends GetView<GroupDetailController> {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkGreenText = Color(0xFF0F3D3E);
    const Color lightGreenBg = Color(0xFFF2FBF1);
    const Color buttonBg = Color(0xFFE2F3E4);

    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        centerTitle: true,
        title: const Text('Detail Group',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal)),
          );
        }
        if (controller.errorMsg.value.isNotEmpty) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(controller.errorMsg.value,
                      style: const TextStyle(color: AppColors.textGrey)),
                ],
              ),
            ),
          );
        }

        final group = controller.group.value;
        if (group == null) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: const Center(child: Text('Data tidak ditemukan')),
          );
        }

        final isCreator = group.creatorId == controller.currentUserId;
        final isAdminUser = group.members?.any((m) => m.userId == controller.currentUserId && m.role == 'admin') ?? false;
        final canManage = isCreator || isAdminUser;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: lightGreenBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryTeal,
                  onRefresh: () => controller.fetchDetail(group.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── HEADER CARD ──────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00ACC1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  group.name.isNotEmpty
                                      ? group.name[0].toUpperCase()
                                      : 'G',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                group.name,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreenText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: darkGreenText, fontSize: 16),
                                  children: [
                                    TextSpan(text: '${group.members?.length ?? 0} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: 'Anggota'),
                                  ]
                                )
                              ),
                              const SizedBox(height: 12),
                              const Text('Group Created At:', style: TextStyle(fontSize: 12, color: darkGreenText)),
                              const SizedBox(height: 4),
                              Text(_formatDate(group.createdAt), style: const TextStyle(fontSize: 12, color: darkGreenText)),
                            ]
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // ── MEMBER LIST ──────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Anggota Grup',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreenText),
                            ),
                            if (canManage)
                              IconButton(
                                onPressed: () => _showAddMemberSheet(context),
                                icon: const Icon(Icons.add, size: 28, color: darkGreenText),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
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
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    MemberAvatar(
                                      userId: member.userId,
                                      photoPath: member.user?.photoPath,
                                      radius: 24,
                                      fallbackLabel: memberUsername,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(memberUsername,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: darkGreenText)),
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
                                    ),
                                    if (canManage && !isMe)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.person_remove_rounded,
                                            color: Colors.redAccent,
                                            size: 20),
                                        onPressed: () =>
                                            _confirmRemoveMember(context, member),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // ── TOMBOL LIHAT TRANSAKSI ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(
                      AppRoutes.groupTransaction,
                      arguments: group,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: darkGreenText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Lihat transaksi & hutang grup',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
