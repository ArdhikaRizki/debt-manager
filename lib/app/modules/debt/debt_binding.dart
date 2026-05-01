import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import 'debt_controller.dart';
import 'debt_detail_controller.dart';

class DebtBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<DebtController>(() => DebtController());
  }
}

class DebtDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<DebtDetailController>(() => DebtDetailController());
  }
}
