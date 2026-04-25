import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "My Project Mobile",
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Sans-Serif', // Pastikan font terdaftar di pubspec.yaml
      ),
    ),
  );
}