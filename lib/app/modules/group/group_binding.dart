import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import 'group_controller.dart';
import 'group_detail_controller.dart';
import 'group_transaction_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<GroupController>(() => GroupController());
  }
}

class GroupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<GroupDetailController>(() => GroupDetailController());
  }
}

class GroupTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<GroupTransactionController>(() => GroupTransactionController());
  }
}
