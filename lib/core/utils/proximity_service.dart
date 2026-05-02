import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

/// Service global yang mendeteksi proximity sensor.
/// Saat HP dimasukkan kantong (sensor dekat > 1.5 detik),
/// layar akan mati dan app keluar (minimize).
class ProximityService extends GetxService with WidgetsBindingObserver {
  StreamSubscription<dynamic>? _subscription;
  Timer? _pocketTimer;

  /// Durasi sensor harus "near" sebelum aksi dijalankan.
  /// Ini mencegah trigger tidak sengaja (misal tangan lewat).
  static const _pocketDelay = Duration(milliseconds: 1500);

  final isNear = false.obs;
  final isActive = false.obs;

   @override
  void onInit() {
    super.onInit();
    // Mendaftarkan deteksi background/foreground
    WidgetsBinding.instance.addObserver(this); 
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Aplikasi dibuka kembali -> Nyalakan sensor
      if (!isActive.value) startListening();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // Aplikasi di-minimize/background -> Matikan sensor sementara
      stopListening();
    }
  }

  /// Mulai mendengarkan proximity sensor.
  void startListening() {
    if (_subscription != null) return; // sudah aktif
    isActive.value = true;

    _subscription = ProximitySensor.events.listen((int event) {
      final near = event > 0;
      isNear.value = near;

      if (near) {
        // Mulai timer — jika tetap "near" selama _pocketDelay, trigger aksi
        _pocketTimer?.cancel();
        _pocketTimer = Timer(_pocketDelay, () {
          _onPocketDetected();
        });
      } else {
        // Sensor kembali "far" → batalkan timer
        _pocketTimer?.cancel();
      }
    });

    if (kDebugMode) {
      debugPrint('[ProximityService] Listening started');
    }
  }

  /// Berhenti mendengarkan proximity sensor.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _pocketTimer?.cancel();
    isActive.value = false;
    isNear.value = false;

    if (kDebugMode) {
      debugPrint('[ProximityService] Listening stopped');
    }
  }

  /// Dipanggil saat HP terdeteksi masuk kantong.
  void _onPocketDetected() {
    if (kDebugMode) {
      debugPrint('[ProximityService] Pocket detected! Minimizing app...');
    }

    // Minimize / keluar dari app (kembali ke home screen Android)
    SystemNavigator.pop();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopListening();
    super.onClose();
  }
}
