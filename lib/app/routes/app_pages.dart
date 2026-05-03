import 'package:get/get.dart';

import '../modules/debt/debt_binding.dart';
import '../modules/debt/debt_detail_view.dart';
import '../modules/debt/debt_view.dart';
import '../modules/group/group_binding.dart';
import '../modules/group/group_detail_view.dart';
import '../modules/group/group_transaction_view.dart';
import '../modules/group/group_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/singup/signup_view.dart';
import '../modules/currency/currency_binding.dart';
import '../modules/currency/currency_view.dart';
import '../modules/timezone/timezone_binding.dart';
import '../modules/timezone/timezone_view.dart';
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
    GetPage(
      name: AppRoutes.groupTransaction,
      page: () => const GroupTransactionView(),
      binding: GroupTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: AppRoutes.timezone,
      page: () => const TimezoneView(),
      binding: TimezoneBinding(),
    ),
    GetPage(
      name: AppRoutes.currency,
      page: () => const CurrencyView(),
      binding: CurrencyBinding(),
    ),
  ];
}