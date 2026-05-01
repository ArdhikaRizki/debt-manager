import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
