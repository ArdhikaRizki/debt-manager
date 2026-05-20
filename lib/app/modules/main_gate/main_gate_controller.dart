import 'package:get/get.dart';

class MainGateController extends GetxController {
  // Selalu mulai dari tab index 0 (Home)
  final selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }
}