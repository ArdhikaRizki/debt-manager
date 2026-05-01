import 'package:get/get.dart';
import 'timezone_controller.dart';

class TimezoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimezoneController>(() => TimezoneController());
  }
}
