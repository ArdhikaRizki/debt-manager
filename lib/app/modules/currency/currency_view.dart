import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import 'currency_controller.dart';

class CurrencyView extends GetView<CurrencyController> {
  const CurrencyView({super.key});

  static const _grad = [Color(0xFFFF6B6B), Color(0xFFFF8E53)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: _grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + Title + Refresh
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  ' Konversi Mata Uang',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: controller.refresh,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.lastUpdated.value.isNotEmpty
                ? 'Kurs: ${controller.lastUpdated.value}'
                : 'Memuat data kurs...',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          )),
          const SizedBox(height: 16),

          // Amount input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Obx(() {
                  final code = controller.selectedBase.value;
                  return Text(
                    '${controller.flagOf(code)}  ${code.toUpperCase()}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  );
                }),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.amountController,
                    onChanged: controller.onAmountChanged,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BODY ────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingList.value && controller.allCurrencies.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
      }
      if (controller.errorMsg.value.isNotEmpty &&
          controller.filteredResultCurrencies.isEmpty) {
        return _buildError();
      }
      return Column(
        children: [
          _buildBaseSelector(),
          Expanded(child: _buildResults()),
        ],
      );
    });
  }

  // ─── BASE SELECTOR ───────────────────────────────────────────────────────
  Widget _buildBaseSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dari mata uang:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey)),
          const SizedBox(height: 8),
          // Search base
          TextField(
            controller: controller.searchBaseController,
            onChanged: (v) => controller.searchBase.value = v.toLowerCase(),
            decoration: InputDecoration(
              hintText: 'Cari mata uang...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textGrey),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF0F4F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Chip list
          SizedBox(
            height: 38,
            child: Obx(() {
              final query = controller.searchBase.value;
              final all   = controller.allCurrencies;
              final List<String> codes;
              if (query.isEmpty) {
                // Buat copy dari const list agar bisa di-iterate (tidak perlu sort)
                codes = List<String>.from(CurrencyController.popularCodes);
              } else {
                final filtered = all.keys.where((c) {
                  return c.contains(query) ||
                      (all[c]?.toLowerCase().contains(query) ?? false);
                }).take(30).toList();
                filtered.sort();
                codes = filtered;
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: codes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final code     = codes[i];
                  final selected = controller.selectedBase.value == code;
                  return GestureDetector(
                    onTap: () => controller.changeBase(code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(colors: _grad)
                            : null,
                        color: selected ? null : const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: const Color(0xFFFF6B6B).withOpacity(0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ]
                            : null,
                      ),
                      child: Text(
                        '${controller.flagOf(code)} ${code.toUpperCase()}',
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // ─── RESULTS ─────────────────────────────────────────────────────────────
  Widget _buildResults() {
    return Column(
      children: [
        // Search bar hasil
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.searchResultController,
                  decoration: InputDecoration(
                    hintText: 'Filter hasil konversi...',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: AppColors.textGrey),
                    prefixIcon:
                        const Icon(Icons.filter_list, size: 18, color: AppColors.textGrey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => controller.isLoadingRates.value
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFFF6B6B)))
                  : const SizedBox.shrink()),
            ],
          ),
        ),

        // List hasil
        Expanded(
          child: Obx(() {
            final list = controller.filteredResultCurrencies;
            if (list.isEmpty && !controller.isLoadingRates.value) {
              return const Center(
                child: Text('Tidak ada mata uang ditemukan',
                    style: TextStyle(color: AppColors.textGrey)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: list.length,
              itemBuilder: (_, i) => _buildResultCard(list[i]),
            );
          }),
        ),
      ],
    );
  }

  // ─── RESULT CARD ─────────────────────────────────────────────────────────
  Widget _buildResultCard(String code) {
    final result = controller.convertTo(code);
    final fmt    = controller.formatAmount(result);
    final name   = controller.nameOf(code);
    final flag   = controller.flagOf(code);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0EE),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textDark)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Obx(() {
            final res = controller.convertTo(code);
            return Text(
              controller.formatAmount(res),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── ERROR ───────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Obx(() => Text(controller.errorMsg.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
