import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrencyController extends GetxController {
  // ─── API Endpoints ────────────────────────────────────────────────────────
  static const _primaryBase =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies';
  static const _fallbackBase =
      'https://latest.currency-api.pages.dev/v1/currencies';

  // Flag emoji map — fiat pakai bendera negara, kripto pakai simbol
  static const _flags = {
    // Asia Tenggara
    'idr': '🇮🇩', 'sgd': '🇸🇬', 'myr': '🇲🇾', 'thb': '🇹🇭',
    'php': '🇵🇭', 'vnd': '🇻🇳', 'mmk': '🇲🇲', 'khr': '🇰🇭',
    'lak': '🇱🇦', 'bnd': '🇧🇳',
    // Asia Timur
    'jpy': '🇯🇵', 'cny': '🇨🇳', 'cnh': '🇨🇳', 'hkd': '🇭🇰',
    'krw': '🇰🇷', 'kpw': '🇰🇵', 'twd': '🇹🇼', 'mop': '🇲🇴',
    // Asia Selatan
    'inr': '🇮🇳', 'pkr': '🇵🇰', 'bdt': '🇧🇩', 'lkr': '🇱🇰',
    'npr': '🇳🇵', 'btn': '🇧🇹', 'mvr': '🇲🇻',
    // Asia Tengah
    'kzt': '🇰🇿', 'uzs': '🇺🇿', 'kgs': '🇰🇬', 'tjs': '🇹🇯',
    'tmt': '🇹🇲', 'azn': '🇦🇿', 'amd': '🇦🇲', 'gel': '🇬🇪',
    // Timur Tengah
    'sar': '🇸🇦', 'aed': '🇦🇪', 'kwd': '🇰🇼', 'qar': '🇶🇦',
    'bhd': '🇧🇭', 'omr': '🇴🇲', 'jod': '🇯🇴', 'iqd': '🇮🇶',
    'irr': '🇮🇷', 'yer': '🇾🇪', 'ils': '🇮🇱', 'syp': '🇸🇾',
    'lbp': '🇱🇧',
    // Eropa
    'eur': '🇪🇺', 'gbp': '🇬🇧', 'chf': '🇨🇭', 'sek': '🇸🇪',
    'nok': '🇳🇴', 'dkk': '🇩🇰', 'pln': '🇵🇱', 'czk': '🇨🇿',
    'huf': '🇭🇺', 'ron': '🇷🇴', 'bgn': '🇧🇬', 'hrk': '🇭🇷',
    'rsd': '🇷🇸', 'mkd': '🇲🇰', 'bam': '🇧🇦', 'all': '🇦🇱',
    'rub': '🇷🇺', 'uah': '🇺🇦', 'byn': '🇧🇾', 'mdl': '🇲🇩',
    'isk': '🇮🇸', 'gip': '🇬🇮', 'fkp': '🇫🇰', 'try': '🇹🇷',
    // Amerika Utara & Karibia
    'usd': '🇺🇸', 'cad': '🇨🇦', 'mxn': '🇲🇽', 'jmd': '🇯🇲',
    'bbd': '🇧🇧', 'bsd': '🇧🇸', 'bmd': '🇧🇲', 'bzd': '🇧🇿',
    'ttd': '🇹🇹', 'htg': '🇭🇹', 'dop': '🇩🇴', 'cup': '🇨🇺',
    'cuc': '🇨🇺', 'kyd': '🇰🇾', 'ang': '🇨🇼', 'awg': '🇦🇼',
    'xcd': '🏝️',
    // Amerika Selatan
    'brl': '🇧🇷', 'ars': '🇦🇷', 'cop': '🇨🇴', 'clp': '🇨🇱',
    'pen': '🇵🇪', 'uyu': '🇺🇾', 'bob': '🇧🇴', 'pyg': '🇵🇾',
    'gyd': '🇬🇾', 'srd': '🇸🇷', 'pab': '🇵🇦', 'crc': '🇨🇷',
    'nio': '🇳🇮', 'hnl': '🇭🇳', 'gtq': '🇬🇹', 'svc': '🇸🇻',
    'ves': '🇻🇪',
    // Oseania
    'aud': '🇦🇺', 'nzd': '🇳🇿', 'fjd': '🇫🇯', 'pgk': '🇵🇬',
    'wst': '🇼🇸', 'top': '🇹🇴', 'vuv': '🇻🇺', 'sbд': '🇸🇧',
    'sbd': '🇸🇧',
    // Afrika
    'zar': '🇿🇦', 'ngn': '🇳🇬', 'kes': '🇰🇪', 'ghs': '🇬🇭',
    'tzs': '🇹🇿', 'ugx': '🇺🇬', 'rwf': '🇷🇼', 'etb': '🇪🇹',
    'dzd': '🇩🇿', 'mad': '🇲🇦', 'tnd': '🇹🇳', 'lyd': '🇱🇾',
    'egp': '🇪🇬', 'sdg': '🇸🇩', 'aoa': '🇦🇴', 'zmw': '🇿🇲',
    'bwp': '🇧🇼', 'zwl': '🇿🇼', 'mwk': '🇲🇼', 'mzn': '🇲🇿',
    'nad': '🇳🇦', 'szl': '🇸🇿', 'lsl': '🇱🇸', 'mga': '🇲🇬',
    'mur': '🇲🇺', 'scr': '🇸🇨', 'kmf': '🇰🇲', 'djf': '🇩🇯',
    'ern': '🇪🇷', 'stn': '🇸🇹', 'cve': '🇨🇻', 'gmd': '🇬🇲',
    'gnf': '🇬🇳', 'sle': '🇸🇱', 'lrd': '🇱🇷', 'sll': '🇸🇱',
    'sos': '🇸🇴', 'bif': '🇧🇮', 'xaf': '🌍', 'xof': '🌍',
    'cdf': '🇨🇩', 'mru': '🇲🇷',
    // Pasifik & Lainnya
    'xpf': '🏝️', 'xdr': '🌐',
    // Logam mulia
    'xau': '🥇', 'xag': '🥈',
    // Kripto
    'btc': '₿',  'eth': 'Ξ',  'usdt': '💵', 'usdc': '💵',
    'bnb': '💎', 'sol': '☀️', 'xrp': '💧', 'ada': '💠',
    'doge': '🐕', 'shib': '🐕', 'trx': '⚡', 'dot': '⚪',
    'link': '🔗', 'ltc': 'Ł',  'bch': '💚', 'xlm': '⭐',
    'xmr': '🕵️', 'etc': '💎', 'fil': '📁', 'atom': '⚛️',
  };


  // ─── State ────────────────────────────────────────────────────────────────
  // Semua currency dari API: { "idr": "Indonesian Rupiah", ... }
  final allCurrencies   = <String, String>{}.obs;
  // Currency yang ditampilkan di hasil setelah filter search
  final filteredResultCurrencies = <String>[].obs;

  final selectedBase    = 'idr'.obs;
  final rates           = <String, double>{}.obs;
  final lastUpdated     = ''.obs;
  final isLoadingList   = false.obs;
  final isLoadingRates  = false.obs;
  final errorMsg        = ''.obs;

  // Search untuk selector base currency
  final searchBase      = ''.obs;
  // Search untuk hasil konversi
  final searchResult    = ''.obs;

  final amountController      = TextEditingController(text: '1');
  final searchBaseController  = TextEditingController();
  final searchResultController = TextEditingController();

  // Currencies populer yang muncul di atas
  static const popularCodes = [
    'idr','usd','eur','gbp','jpy','sgd','myr','sar','aud','cny',
    'hkd','krw','thb','inr','aed','chf','cad','vnd','php','brl',
  ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();

    // Listener search hasil konversi
    searchResultController.addListener(() {
      searchResult.value = searchResultController.text.toLowerCase();
      _applyResultFilter();
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    searchBaseController.dispose();
    searchResultController.dispose();
    super.onClose();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> _init() async {
    await fetchCurrencyList();
    await fetchRates();
  }

  // ─── Fetch daftar semua mata uang ─────────────────────────────────────────
  Future<void> fetchCurrencyList() async {
    isLoadingList.value = true;
    Map<String, dynamic>? data =
        await _get('$_primaryBase.json') ?? await _get('$_fallbackBase.json');

    if (data != null) {
      final map = <String, String>{};
      data.forEach((k, v) {
        if (v is String && v.isNotEmpty) map[k] = v;
      });
      allCurrencies.value = map;
      _applyResultFilter();
    }
    isLoadingList.value = false;
  }

  // ─── Fetch kurs berdasarkan base ──────────────────────────────────────────
  Future<void> fetchRates() async {
    isLoadingRates.value = true;
    errorMsg.value = '';

    final base = selectedBase.value;
    final data = await _get('$_primaryBase/$base.json') ??
                 await _get('$_fallbackBase/$base.json');

    if (data != null) {
      lastUpdated.value = data['date'] as String? ?? '';
      final raw = data[base] as Map<String, dynamic>?;
      if (raw != null) {
        final newRates = <String, double>{};
        raw.forEach((k, v) {
          if (v is num) newRates[k] = v.toDouble();
        });
        rates.value = newRates;
      }
      _applyResultFilter();
    } else {
      errorMsg.value = 'Gagal memuat kurs. Periksa koneksi internet.';
    }

    isLoadingRates.value = false;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _get(String url) async {
    try {
      final c = GetConnect()..timeout = const Duration(seconds: 10);
      final r = await c.get(url);
      if (r.statusCode == 200 && r.body is Map) {
        return r.body as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  void changeBase(String code) {
    if (selectedBase.value == code) return;
    selectedBase.value = code;
    searchBaseController.clear();
    searchBase.value = '';
    fetchRates();
  }

  void refresh() => fetchRates();

  double get inputAmount =>
      double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.0;

  void onAmountChanged(String _) => rates.refresh();

  // Filter hasil konversi: populer dulu, lalu sisanya berdasarkan search
  void _applyResultFilter() {
    final query = searchResult.value.trim();
    final base  = selectedBase.value;
    final availableKeys = rates.keys.toSet();

    List<String> result;
    if (query.isEmpty) {
      // Tampilkan currency populer dulu (yang ada di rates)
      final popular = popularCodes
          .where((c) => c != base && availableKeys.contains(c))
          .toList();
      // Tambahkan sisanya
      final others = availableKeys
          .where((c) => c != base && !popularCodes.contains(c))
          .toList()
        ..sort();
      result = [...popular, ...others];
    } else {
      // Filter berdasarkan code atau name
      result = availableKeys.where((code) {
        if (code == base) return false;
        if (code.contains(query)) return true;
        final name = allCurrencies[code]?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList()..sort();
    }

    filteredResultCurrencies.value = result;
  }

  // ─── Formatting ───────────────────────────────────────────────────────────
  String flagOf(String code) => _flags[code] ?? '💱';

  String nameOf(String code) =>
      allCurrencies[code] ?? code.toUpperCase();

  double convertTo(String targetCode) {
    if (targetCode == selectedBase.value) return inputAmount;
    final rate = rates[targetCode];
    return rate != null ? inputAmount * rate : 0.0;
  }

  String formatAmount(double amount) {
    if (amount == 0) return '-';
    if (amount >= 1000) {
      final s = amount.toStringAsFixed(2);
      final parts = s.split('.');
      final intPart = parts[0].replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
      return parts[1] == '00' ? intPart : '$intPart.${parts[1]}';
    } else if (amount >= 1) {
      return amount.toStringAsFixed(4)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    } else {
      return amount.toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
}
