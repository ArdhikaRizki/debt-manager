import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import 'timezone_controller.dart';

class TimezoneView extends StatelessWidget {
  const TimezoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimezoneController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: _buildLiveClocks(controller)),
            SliverToBoxAdapter(child: _buildConverterCard(controller, context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF2EC4B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🕐 Konversi Waktu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
              'Hari ini · ${DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now())}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            )),
          ],
        ),
      ),
    );
  }

  // ─── LIVE CLOCKS ───────────────────────────────────────────────────────────
  Widget _buildLiveClocks(TimezoneController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Waktu Sekarang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: Obx(() => _ClockCard(
                label: 'WIB',
                sublabel: 'UTC+7',
                time: c.wibTime.value,
                emoji: '🏙️',
                color: const Color(0xFF2EC4B6),
              ))),
              const SizedBox(width: 10),
              Expanded(child: Obx(() => _ClockCard(
                label: 'WITA',
                sublabel: 'UTC+8',
                time: c.witaTime.value,
                emoji: '🌴',
                color: const Color(0xFF6C63FF),
              ))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Obx(() => _ClockCard(
                label: 'WIT',
                sublabel: 'UTC+9',
                time: c.witTime.value,
                emoji: '🦜',
                color: const Color(0xFFF7931A),
              ))),
              const SizedBox(width: 10),
              Expanded(child: Obx(() => _ClockCard(
                label: c.londonLabel.value,
                sublabel: 'UTC+0/+1',
                time: c.londonTime.value,
                emoji: '🎡',
                color: const Color(0xFFE53935),
              ))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CONVERTER CARD ────────────────────────────────────────────────────────
  Widget _buildConverterCard(TimezoneController c, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Konversi Manual',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Zona sumber
            const Text('Dari zona waktu:', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: c.zones.map((zone) {
                  final selected = c.selectedSourceZone.value == zone;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        c.selectedSourceZone.value = zone;
                        c.convertTime();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          zone,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )),

            const SizedBox(height: 16),

            // Input waktu
            const Text('Pilih waktu:', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => c.pickTime(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFF6C63FF), size: 20),
                    const SizedBox(width: 10),
                    Obx(() => Text(
                      '${c.inputHour.value.toString().padLeft(2, '0')}:${c.inputMinute.value.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    )),
                    const Spacer(),
                    const Text(
                      'Tap untuk ganti',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Hasil konversi
            const Text(
              'Hasil Konversi:',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() => Column(
              children: [
                _ResultRow(zone: 'WIB',    sublabel: 'UTC+7', time: c.convertedWib.value,    color: const Color(0xFF2EC4B6), emoji: '🏙️'),
                _ResultRow(zone: 'WITA',   sublabel: 'UTC+8', time: c.convertedWita.value,   color: const Color(0xFF6C63FF), emoji: '🌴'),
                _ResultRow(zone: 'WIT',    sublabel: 'UTC+9', time: c.convertedWit.value,    color: const Color(0xFFF7931A), emoji: '🦜'),
                _ResultRow(zone: c.londonLabel.value, sublabel: 'UK', time: c.convertedLondon.value, color: const Color(0xFFE53935), emoji: '🎡'),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// ─── CLOCK CARD ──────────────────────────────────────────────────────────────
class _ClockCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String time;
  final String emoji;
  final Color color;

  const _ClockCard({
    required this.label,
    required this.sublabel,
    required this.time,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(sublabel, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RESULT ROW ──────────────────────────────────────────────────────────────
class _ResultRow extends StatelessWidget {
  final String zone;
  final String sublabel;
  final String time;
  final Color color;
  final String emoji;

  const _ResultRow({
    required this.zone,
    required this.sublabel,
    required this.time,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                Text(sublabel, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
