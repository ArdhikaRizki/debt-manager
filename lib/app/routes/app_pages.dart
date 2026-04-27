// lib/app/routes/app_pages.dart
import 'package:get/get.dart';

import '../modules/home/home_view.dart';
import '../modules/login/login_view.dart';
import '../modules/singup/signup_view.dart';
import '../modules/welcome/welcome_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.welcome,
      page: () => WelcomeView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => SignupView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
  ];
}