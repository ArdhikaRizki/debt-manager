import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder home page — ganti dengan halaman utama yang sebenarnya nanti.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Selamat datang! 🎉\nKamu berhasil login.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: AppColors.textDark),
        ),
      ),
    );
  }
}
