import 'package:get/get.dart';

import '../modules/debt/debt_binding.dart';
import '../modules/debt/debt_detail_view.dart';
import '../modules/debt/debt_view.dart';
import '../modules/group/group_binding.dart';
import '../modules/group/group_detail_view.dart';
import '../modules/group/group_view.dart';
import '../modules/home/home_binding.dart';
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
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.debt,
      page: () => const DebtView(),
      binding: DebtBinding(),
    ),
    GetPage(
      name: AppRoutes.debtDetail,
      page: () => const DebtDetailView(),
      binding: DebtDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.group,
      page: () => const GroupView(),
      binding: GroupBinding(),
    ),
    GetPage(
      name: AppRoutes.groupDetail,
      page: () => const GroupDetailView(),
      binding: GroupDetailBinding(),
    ),
  ];
}