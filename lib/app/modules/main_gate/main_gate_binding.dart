import 'package:get/get.dart';

// Import binding dari modul lain yang ada di bottom nav
import '../home/home_binding.dart';
import '../debt/debt_binding.dart';
import '../group/group_binding.dart';
import 'main_gate_controller.dart';

class MainGateBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Init controller untuk gate-nya sendiri
    Get.lazyPut<MainGateController>(() => MainGateController());

    // 2. Jalankan semua binding dari tab yang ada di dalam IndexedStack
    HomeBinding().dependencies();
    DebtBinding().dependencies();
    GroupBinding().dependencies();
    
    // (Jika ProfileView punya controller/binding, tambahkan juga di sini)
  }
}