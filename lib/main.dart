import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_colors.dart';

void main() async {
  await GetStorage.init();

  runApp(
    GetMaterialApp(
      title: "My Project Mobile",
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgWhite,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
        fontFamily: 'Sans-Serif', // Pastikan font terdaftar di pubspec.yaml
      ),
    ),
  );
}