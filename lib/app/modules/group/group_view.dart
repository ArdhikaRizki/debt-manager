import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'group_controller.dart';

class GroupView extends GetView<GroupController> {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        title: const Text('Grup Hutang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
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
          return _buildErrorState(controller.errorMsg.value);
        }
        if (controller.groups.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: controller.fetchGroups,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: controller.groups.length,
            itemBuilder: (_, i) {
              final group = controller.groups[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      Get.toNamed(AppRoutes.groupDetail, arguments: group.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryTeal,
                                AppColors.primaryBlue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              group.name.isNotEmpty
                                  ? group.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (group.description != null &&
                                  group.description!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  group.description!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.people_outline,
                                      size: 14,
                                      color: AppColors.textGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${group.members?.length ?? 0} anggota',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupSheet(context),
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Grup',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined,
                size: 72, color: AppColors.textGrey.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              'Belum ada grup',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Buat grup untuk mengelola hutang bersama teman.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
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
            onPressed: controller.fetchGroups,
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

  void _showCreateGroupSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final searchCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Local state dikelola dengan StatefulBuilder
    final List<String> members = [];
    String searchError = '';
    bool isSearching = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
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
                    // Drag handle
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
                    const Text('Buat Grup Baru',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    const SizedBox(height: 20),

                    // ── Nama & Deskripsi ──────────────────
                    _buildSheetField(
                      controller: nameCtrl,
                      label: 'Nama Grup',
                      hint: 'Contoh: Kost Bahagia',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    _buildSheetField(
                      controller: descCtrl,
                      label: 'Deskripsi (opsional)',
                      hint: 'Deskripsi singkat...',
                    ),

                    // ── Section Anggota ───────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Anggota',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.textDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            '${members.length + 1} anggota',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryTeal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Search bar ────────────────────────
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,
                          autocorrect: false,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) async {
                            final q = searchCtrl.text.trim();
                            if (q.isEmpty) return;
                            setState(() {
                              isSearching = true;
                              searchError = '';
                            });
                            final found =
                                await controller.searchUser(q);
                            setState(() => isSearching = false);
                            if (found == null) {
                              setState(() =>
                                  searchError = 'User "$q" tidak ditemukan');
                            } else if (found == controller.currentUsername) {
                              setState(() => searchError =
                                  'Kamu otomatis jadi anggota');
                            } else if (members.contains(found)) {
                              setState(
                                  () => searchError = '@$found sudah ditambahkan');
                            } else {
                              setState(() {
                                members.add(found);
                                searchCtrl.clear();
                                searchError = '';
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari username (tekan Enter)...',
                            hintStyle:
                                const TextStyle(color: AppColors.textGrey),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  color: AppColors.primaryTeal, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Search
                      GestureDetector(
                        onTap: isSearching
                            ? null
                            : () async {
                                final q = searchCtrl.text.trim();
                                if (q.isEmpty) return;
                                setState(() {
                                  isSearching = true;
                                  searchError = '';
                                });
                                final found =
                                    await controller.searchUser(q);
                                setState(() => isSearching = false);
                                if (found == null) {
                                  setState(() => searchError =
                                      'User "$q" tidak ditemukan');
                                } else if (found ==
                                    controller.currentUsername) {
                                  setState(() => searchError =
                                      'Kamu otomatis jadi anggota');
                                } else if (members.contains(found)) {
                                  setState(() =>
                                      searchError = '@$found sudah ditambahkan');
                                } else {
                                  setState(() {
                                    members.add(found);
                                    searchCtrl.clear();
                                    searchError = '';
                                  });
                                }
                              },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSearching
                                ? Colors.grey.shade300
                                : AppColors.textDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Icon(Icons.search_rounded,
                                  color: Colors.white),
                        ),
                      ),
                    ]),

                    // Error text
                    if (searchError.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(searchError,
                          style: TextStyle(
                              color: Colors.red.shade600, fontSize: 12)),
                    ],
                    const SizedBox(height: 12),

                    // ── Creator card (Saya) ───────────────
                    _MemberCard(
                      username: controller.currentUsername.isNotEmpty
                          ? controller.currentUsername
                          : 'Saya',
                      isCreator: true,
                    ),

                    // ── Added members ─────────────────────
                    ...members.map((uname) => _MemberCard(
                          username: uname,
                          isCreator: false,
                          onRemove: () =>
                              setState(() => members.remove(uname)),
                        )),

                    const SizedBox(height: 20),

                    // ── Tombol Buat ───────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          Get.back();
                          await controller.createGroup(
                            nameCtrl.text.trim(),
                            descCtrl.text.trim(),
                            memberUsernames: List.from(members),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Buat Grup',
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
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide:
                  BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── _MemberCard Widget ─────────────────────────────────
class _MemberCard extends StatelessWidget {
  final String username;
  final bool isCreator;
  final VoidCallback? onRemove;

  const _MemberCard({
    required this.username,
    required this.isCreator,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCreator
            ? AppColors.primaryTeal.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCreator
              ? AppColors.primaryTeal.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCreator
                  ? [AppColors.primaryTeal, AppColors.primaryBlue]
                  : [Colors.grey.shade400, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('@$username',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark)),
              if (isCreator)
                const Text('Kamu (Admin)',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.primaryTeal)),
            ],
          ),
        ),
        if (isCreator)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('ADMIN',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal)),
          )
        else
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded,
                  size: 16, color: Colors.red.shade400),
            ),
          ),
      ]),
    );
  }
}
