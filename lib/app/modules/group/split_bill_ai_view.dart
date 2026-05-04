import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/services/ai_receipt_service.dart';
import 'group_transaction_controller.dart';

class SplitBillAiView extends StatefulWidget {
  final XFile imageFile;
  final GroupTransactionController txController;
  final String payerUsername;

  const SplitBillAiView({
    super.key,
    required this.imageFile,
    required this.txController,
    required this.payerUsername,
  });

  @override
  State<SplitBillAiView> createState() => _SplitBillAiViewState();
}

class _SplitBillAiViewState extends State<SplitBillAiView> {
  final AiReceiptService _aiService = Get.find<AiReceiptService>();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _items = [];
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final results = await _aiService.analyzeReceipt(widget.imageFile);
      if (results != null && results.isNotEmpty) {
        setState(() {
          // Tambahkan field 'assigned' (List of usernames) untuk tiap item
          _items = results.map((e) {
            return {
              'name': e['name']?.toString() ?? 'Item Tanpa Nama',
              'price': double.tryParse(e['price']?.toString() ?? '0') ?? 0.0,
              'assigned': <String>[], // Kosong pada awalnya
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'AI tidak merespons dengan data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // Membersihkan awalan "Exception:" agar lebih rapi di UI
        _errorMsg = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _submitTransactions() async {
    // Kumpulkan total hutang untuk tiap user
    final Map<String, double> userDebts = {};
    
    for (var item in _items) {
      final assigned = item['assigned'] as List<String>;
      if (assigned.isEmpty) continue; // Skip kalau item tidak ada yang menanggung
      
      final price = item['price'] as double;
      final splitPrice = price / assigned.length; // Harga dibagi rata jumlah orang yang assign
      
      for (var username in assigned) {
        userDebts[username] = (userDebts[username] ?? 0) + splitPrice;
      }
    }

    if (userDebts.isEmpty) {
      Get.snackbar('Oops!', 'Pilih minimal satu orang untuk satu item.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Proses pembuatan transaksi satu per satu
    int successCount = 0;
    for (var entry in userDebts.entries) {
      final targetUser = entry.key; // Orang yang berhutang
      final amount = entry.value;

      // Jangan buat transaksi jika target adalah diri sendiri (Payer)
      if (targetUser == widget.payerUsername) continue;

      try {
        await widget.txController.createTransaction(
          fromUsername: targetUser,        // Yang berhutang
          toUsername: widget.payerUsername,// Yang nalangin / bayar duluan
          amount: amount,
          description: 'Split Bill Struk AI',
        );
        successCount++;
      } catch (e) {
        debugPrint('Gagal buat transaksi untuk $targetUser: $e');
      }
    }

    setState(() {
      _isSubmitting = false;
    });
    
    // Kembali ke halaman sebelumnya (tutup halaman split bill)
    Get.back();
    
    // Beri jeda sedikit agar halaman tertutup sebelum snackbar muncul
    await Future.delayed(const Duration(milliseconds: 300));
    Get.snackbar('Berhasil!', '$successCount Transaksi Split Bill otomatis tercatat.',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar member selain diri kita sendiri
    final members = widget.txController.group.value?.members
            ?.where((m) => m.userId != widget.txController.currentUserId)
            .map((m) => m.user?.username ?? '')
            .where((u) => u.isNotEmpty)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        title: const Text('AI Split Bill', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMsg.isNotEmpty
              ? _buildErrorState()
              : _buildItemList(members),
      bottomNavigationBar: _isLoading || _errorMsg.isNotEmpty ? null : _buildBottomBar(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(File(widget.imageFile.path), width: 120, height: 160, fit: BoxFit.cover),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: AppColors.primaryTeal),
          const SizedBox(height: 16),
          const Text('🤖 AI sedang membaca strukmu...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const Text('Harap tunggu beberapa detik',
              style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDark)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
              child: const Text('Kembali', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<String> members) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final assigned = item['assigned'] as List<String>;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    ),
                    Text('Rp ${item['price'].toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryTeal, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Siapa yang bayar ini?', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: members.map((member) {
                    final isSelected = assigned.contains(member);
                    return FilterChip(
                      label: Text(member),
                      selected: isSelected,
                      selectedColor: AppColors.primaryTeal.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryTeal,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryTeal : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            assigned.add(member);
                          } else {
                            assigned.remove(member);
                          }
                        });
                      },
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    double grandTotal = 0;
    for (var item in _items) {
      if ((item['assigned'] as List).isNotEmpty) {
        grandTotal += item['price'] as double;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total ditagihkan:', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                Text('Rp ${grandTotal.toInt()}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (grandTotal > 0 && !_isSubmitting) ? _submitTransactions : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text('Buat Transaksi Split Bill',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
