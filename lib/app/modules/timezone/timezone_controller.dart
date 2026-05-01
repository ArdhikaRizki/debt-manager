import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneController extends GetxController {
  Timer? _timer;

  final wibTime    = ''.obs;
  final witaTime   = ''.obs;
  final witTime    = ''.obs;
  final londonTime = ''.obs;
  final londonLabel = 'London'.obs;

  final selectedSourceZone = 'WIB'.obs;
  final inputHour   = 0.obs;
  final inputMinute = 0.obs;

  final convertedWib    = ''.obs;
  final convertedWita   = ''.obs;
  final convertedWit    = ''.obs;
  final convertedLondon = ''.obs;

  final zones = ['WIB', 'WITA', 'WIT', 'London'];

  // Timezone locations dari library timezone
  late final tz.Location _wib;
  late final tz.Location _wita;
  late final tz.Location _wit;
  late final tz.Location _london;

  @override
  void onInit() {
    super.onInit();

    // Inisialisasi database timezone
    tz.initializeTimeZones();

    _wib    = tz.getLocation('Asia/Jakarta');     // WIB  UTC+7
    _wita   = tz.getLocation('Asia/Makassar');    // WITA UTC+8
    _wit    = tz.getLocation('Asia/Jayapura');    // WIT  UTC+9
    _london = tz.getLocation('Europe/London');    // GMT/BST auto

    _updateClocks();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClocks());

    // Init input ke waktu WIB sekarang
    final now = tz.TZDateTime.now(_wib);
    inputHour.value = now.hour;
    inputMinute.value = now.minute;
    convertTime();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  tz.Location _locationFor(String zone) {
    switch (zone) {
      case 'WIB':    return _wib;
      case 'WITA':   return _wita;
      case 'WIT':    return _wit;
      case 'London': return _london;
      default:       return _wib;
    }
  }

  void _updateClocks() {
    final fmt = DateFormat('HH:mm:ss');

    wibTime.value    = fmt.format(tz.TZDateTime.now(_wib));
    witaTime.value   = fmt.format(tz.TZDateTime.now(_wita));
    witTime.value    = fmt.format(tz.TZDateTime.now(_wit));

    final londonNow  = tz.TZDateTime.now(_london);
    londonTime.value = fmt.format(londonNow);

    // Deteksi apakah sedang BST atau GMT dari offset-nya
    final offsetHours = londonNow.timeZoneOffset.inHours;
    londonLabel.value = offsetHours == 1 ? 'London (BST)' : 'London (GMT)';
  }

  void convertTime() {
    final srcLocation = _locationFor(selectedSourceZone.value);
    final now = tz.TZDateTime.now(srcLocation);

    // Bangun waktu sumber berdasarkan input user
    final srcDt = tz.TZDateTime(
      srcLocation,
      now.year, now.month, now.day,
      inputHour.value, inputMinute.value,
    );

    // Konversi ke masing-masing zona
    final fmt = DateFormat('HH:mm');
    convertedWib.value    = fmt.format(tz.TZDateTime.from(srcDt, _wib));
    convertedWita.value   = fmt.format(tz.TZDateTime.from(srcDt, _wita));
    convertedWit.value    = fmt.format(tz.TZDateTime.from(srcDt, _wit));
    convertedLondon.value = fmt.format(tz.TZDateTime.from(srcDt, _london));
  }

  void pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: inputHour.value, minute: inputMinute.value),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      inputHour.value = picked.hour;
      inputMinute.value = picked.minute;
      convertTime();
    }
  }
}
