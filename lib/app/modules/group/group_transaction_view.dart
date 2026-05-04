import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/group_transaction_model.dart';
import 'group_transaction_controller.dart';
import 'spin_wheel_screen.dart';

class GroupTransactionView extends GetView<GroupTransactionController> {
  const GroupTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          title: Obx(() => Text(
                controller.group.value?.name ?? 'Transaksi Grup',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.casino_outlined),
              tooltip: 'Roda Pengatur Nasib Hutangmu',
              onPressed: () {
                final members = controller.group.value?.members
                    ?.map((m) => m.user?.username ?? 'User #${m.userId}')
                    .toList() ?? [];
                if (members.length >= 2) {
                  Get.to(() => SpinWheelGameScreen(usernames: members));
                } else {
                  Get.snackbar('Info', 'Butuh minimal 2 anggota grup',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Transaksi'),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Ringkasan'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }
          if (controller.errorMsg.value.isNotEmpty) {
            return _buildError();
          }
          return TabBarView(children: [
            _TransactionTab(controller: controller),
            _SummaryTab(controller: controller),
          ]);
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateSheet(context),
          backgroundColor: AppColors.primaryTeal,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Catat Transaksi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red),
        const SizedBox(height: 12),
        Text(controller.errorMsg.value,
            style: const TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: controller.fetchTransactions,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }

  void _showCreateSheet(BuildContext context) {
    final toCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Pre-fill dropdown from members
    final members = controller.group.value?.members ?? [];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Catat Transaksi Grup',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 20),

                // ── Pilih penerima ──
                if (members.isNotEmpty) ...[
                  const Text('Tagih ke (pilih anggota)',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: members
                        .where((m) => m.userId != controller.currentUserId)
                        .map((m) {
                      final uname = m.user?.username ?? 'User #${m.userId}';
                      return StatefulBuilder(builder: (ctx, setState) {
                        final isSelected = toCtrl.text == uname;
                        return ChoiceChip(
                          label: Text(uname),
                          selected: isSelected,
                          selectedColor: AppColors.primaryTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (_) {
                            toCtrl.text = uname;
                            (ctx as Element).markNeedsBuild();
                          },
                        );
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // ── Username manual ──
                _buildField(
                  controller: toCtrl,
                  label: 'Username Penerima',
                  hint: 'Masukkan username...',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                _buildField(
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
                _buildField(
                  controller: descCtrl,
                  label: 'Keterangan',
                  hint: 'Contoh: Bayar makan siang...',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Get.back();
                      await controller.createTransaction(
                        toUsername: toCtrl.text.trim(),
                        amount: double.parse(amountCtrl.text.trim()),
                        description: descCtrl.text.trim(),
                      );
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppColors.primaryTeal, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─── TAB 1: Daftar Transaksi ──────────────────────────────
class _TransactionTab extends StatelessWidget {
  final GroupTransactionController controller;
  const _TransactionTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.receipt_long_outlined,
                size: 72, color: AppColors.textGrey.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Belum ada transaksi grup',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey)),
            const SizedBox(height: 8),
            const Text('Tap tombol + untuk mencatat transaksi baru.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
          ]),
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryTeal,
      onRefresh: controller.fetchTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: controller.transactions.length,
        itemBuilder: (_, i) =>
            _TxCard(tx: controller.transactions[i], controller: controller),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final GroupTransactionModel tx;
  final GroupTransactionController controller;
  const _TxCard({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isIAm = tx.fromUserId == controller.currentUserId;
    final isToMe = tx.toUserId == controller.currentUserId;
    final fromName = tx.fromUser?.username ?? controller.usernameOf(tx.fromUserId);
    final toName = tx.toUser?.username ?? controller.usernameOf(tx.toUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isIAm ? Colors.red.shade50 : Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIAm ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isIAm ? Colors.red.shade400 : Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── chain label ──
              Row(children: [
                Text(fromName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isIAm ? Colors.red.shade600 : AppColors.textDark)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.textGrey),
                ),
                Text(toName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: !isIAm ? Colors.green.shade600 : AppColors.textDark)),
              ]),
              const SizedBox(height: 3),
              Text(tx.description.isNotEmpty ? tx.description : '-',
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(_fmtDate(tx.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmtCurrency(tx.amount),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isIAm ? Colors.red.shade600 : Colors.green.shade700)),
            const SizedBox(height: 6),
            
            // Logika Status Settlement
            Builder(builder: (context) {
              final requests = tx.settlementRequests ?? [];
              final pendingReq = requests.where((r) => r.status == 'pending').lastOrNull;
              final isApproved = requests.any((r) => r.status == 'approved');

              if (isApproved) {
                return _buildBadge('Lunas', Colors.green);
              }

              if (pendingReq != null) {
                if (isIAm) {
                  // Saya yang hutang, dan saya sudah ajukan pelunasan
                  return _buildBadge('Menunggu Konfirmasi', Colors.orange);
                } else if (isToMe) {
                  // Saya yang menghutangi, ada orang ajukan pelunasan ke saya
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _confirmApprove(context, pendingReq.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmReject(context, pendingReq.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Pihak ketiga (bukan fromUserId dan bukan toUserId)
                  return _buildBadge('Menunggu Konfirmasi', Colors.orange);
                }
              }

              // Jika belum ada request pending/approved
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isIAm)
                    GestureDetector(
                      onTap: () => _confirmSettle(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryTeal, AppColors.primaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Lunasi',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (isIAm) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _confirmDelete(context),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                    ),
                  ],
                ],
              );
            }),
          ]),
        ]),
      ),
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color.shade700),
      ),
    );
  }

  void _confirmApprove(BuildContext context, int settlementId) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Terima Pelunasan',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Terima pelunasan untuk transaksi ini?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.approveSettlement(settlementId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Terima'),
        ),
      ],
    ));
  }

  void _confirmReject(BuildContext context, int settlementId) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Tolak Pelunasan',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Tolak pelunasan untuk transaksi ini?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.rejectSettlement(settlementId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Tolak'),
        ),
      ],
    ));
  }

  void _confirmSettle(BuildContext context) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Ajukan Pelunasan',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          'Ajukan pelunasan ${_fmtCurrency(tx.amount)} kepada ${tx.toUser?.username ?? ''}?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal',
              style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.requestSettlementForTx(tx.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Ajukan'),
        ),
      ],
    ));
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Hapus Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Yakin ingin menghapus transaksi ini?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Batal',
              style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteTransaction(tx.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Hapus'),
        ),
      ],
    ));
  }
}

// ─── TAB 2: Ringkasan Saldo & Debt Chain ──────────────────
class _SummaryTab extends StatelessWidget {
  final GroupTransactionController controller;
  const _SummaryTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final balances = controller.netBalances;
    final chains = controller.debtChains;
    final myId = controller.currentUserId;

    final validBalances = balances.entries.where((e) => e.value != 0).toList();

    if (validBalances.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.balance_outlined,
              size: 72, color: AppColors.textGrey.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('Semua hutang sudah lunas',
              style: TextStyle(fontSize: 15, color: AppColors.textGrey)),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Saldo per Anggota ──
        _sectionTitle('Saldo Bersih per Anggota'),
        const SizedBox(height: 8),
        ...validBalances.map((e) {
          final name = controller.usernameOf(e.key);
          final net = e.value;
          final isPositive = net > 0;
          final isMe = e.key == myId;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isPositive ? Colors.green.shade50 : Colors.red.shade50,
                child: Icon(
                  isPositive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade400,
                ),
              ),
              title: Row(children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('Saya',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
              subtitle: Text(
                  isPositive ? 'Dihutangi sebesar' : 'Berhutang sebesar'),
              trailing: Text(
                _fmtCurrency(net.abs()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isPositive ? Colors.green.shade700 : Colors.red.shade600,
                ),
              ),
            ),
          );
        }),

        if (chains.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('💡 Rantai Hutang (Debt Chain)'),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              'Hutang di bawah ini bisa diselesaikan langsung tanpa perantara.',
              style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
            ),
          ),
          ...chains.map((chain) {
            final from = controller.usernameOf(chain.fromId);
            final via = controller.usernameOf(chain.middleId);
            final to = controller.usernameOf(chain.toId);
            final isMyChain = chain.fromId == myId;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isMyChain
                      ? const BorderSide(color: AppColors.primaryTeal, width: 1.5)
                      : BorderSide.none),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris chain: A → (via B) → C
                    Row(children: [
                      _chainNode(from, isMyChain ? Colors.red.shade600 : AppColors.textDark),
                      const SizedBox(width: 6),
                      Column(children: [
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.textGrey),
                        Text('via $via',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textGrey)),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.textGrey),
                      ]),
                      const SizedBox(width: 6),
                      _chainNode(to, Colors.green.shade600),
                      const Spacer(),
                      Text(_fmtCurrency(chain.amount),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMyChain
                                  ? Colors.red.shade600
                                  : AppColors.textDark)),
                    ]),
                    if (isMyChain) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _showChainPaySheet(context, chain, to),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                              'Bayar langsung ke $to sebesar ${_fmtCurrency(chain.amount)}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showChainPaySheet(BuildContext context, DebtChain chain, String toName) {
    final descCtrl = TextEditingController(
        text: 'Pembayaran rantai hutang via ${controller.usernameOf(chain.middleId)}');
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bayar Langsung',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kepada: $toName',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    Text(
                        'Jumlah: ${_fmtCurrency(chain.amount)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryTeal)),
                  ]),
                  const Icon(Icons.link_rounded,
                      color: AppColors.primaryTeal, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Keterangan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide:
                        BorderSide(color: AppColors.primaryTeal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await controller.createTransaction(
                    toUsername: toName,
                    amount: chain.amount,
                    description: descCtrl.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Konfirmasi Pembayaran',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _chainNode(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(name,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark));
  }
}

// ─── Helpers ────────────────────────────────────────────
String _fmtCurrency(double amount) {
  final parts = amount.toStringAsFixed(0).split('');
  final buffer = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
    buffer.write(parts[i]);
  }
  return 'Rp ${buffer.toString()}';
}

String _fmtDate(DateTime dt) {
  final months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${months[dt.month]} ${dt.year}';
}
