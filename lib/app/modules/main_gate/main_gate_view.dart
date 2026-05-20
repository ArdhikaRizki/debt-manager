import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../home/home_view.dart';
import '../debt/debt_view.dart';
import '../group/group_view.dart';
import '../timezone/timezone_view.dart';
import '../currency/currency_view.dart';
import '../feedback/feedback_view.dart';
import '../profile/profile_view.dart';
import 'main_gate_controller.dart';
// import view lainnya (group, timezone, currency, profile)

class MainGateView extends GetView<MainGateController> {
  const MainGateView({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Daftarkan semua halaman di sini sesuai urutan tab
    final List<Widget> pages = [
      const HomeView(),
      const DebtView(),
      const GroupView(), 
      const TimezoneView(), // Placeholder, ganti dengan view sebenarnya
      const CurrencyView(), // Placeholder, ganti dengan view sebenarnya
      const ProfileView(), // Placeholder, ganti dengan view sebenarnya
      const FeedbackView(), // Saran dan Kesan TPM
    ];

    return Scaffold(
      // 2. IndexedStack membungkus halaman agar tumpukannya tetap tersimpan
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: pages,
      )),
      
      // 3. Bottom Nav pindah ke sini secara utuh
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.textGrey,
        backgroundColor: Colors.white,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        currentIndex: controller.selectedIndex.value,
        onTap: controller.changePage, // Panggil fungsi ubah tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Hutang'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Grup'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_rounded), label: 'Waktu'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange_rounded), label: 'Kurs'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback_outlined), label: 'Saran TPM'),
        ],
      )),
    );
  }
}