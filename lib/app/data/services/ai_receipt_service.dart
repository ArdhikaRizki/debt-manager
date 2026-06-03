import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;

class AiReceiptService extends GetxService {
  late final String _apiKey;
  late final GenerativeModel _model;

  static const double _minBlurScore = 25.0;
  static const int _maxGeminiImageSize = 1600;
  static const List<String> _receiptKeywords = [
    'total',
    'subtotal',
    'ppn',
    'pajak',
    'kasir',
    'cashier',
    'tunai',
    'debit',
    'kredit',
    'qris',
    'kembalian',
    'diskon',
    'promo',
    'struk',
    'receipt',
    'belanja',
    'invoice',
    'qty',
    'item',
  ];

  @override
  void onInit() {
    super.onInit();
    
    // Ambil API Key dari file .env
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    if (_apiKey.isEmpty) {
      debugPrint('WARNING: GEMINI_API_KEY tidak ditemukan di .env!');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Fungsi untuk membaca foto struk dan mengubahnya menjadi List of Maps (JSON)
  Future<List<Map<String, dynamic>>?> analyzeReceipt(XFile imageFile) async {
    try {
      final imageBytes = await _preprocessReceiptImage(imageFile);
      final imagePart = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Anda adalah AI asisten pembaca struk belanja yang sangat akurat.
Tugas Anda adalah membaca gambar struk yang diberikan dan mengekstrak daftar barang beserta harganya.
Anda HARUS membalas HANYA dengan array JSON mentah, tanpa tag markdown, tanpa backticks ```json, dan tanpa teks basa-basi.
Struktur JSON yang diinginkan:
[
  {"name": "Nama Makanan 1", "price": 25000},
  {"name": "Nama Makanan 2", "price": 15000},
  {"name": "Pajak PPN", "price": 4000}
]
Pastikan "price" berupa angka integer (hilangkan titik atau koma, hilangkan 'Rp').
Jika ada diskon atau pajak, masukkan juga sebagai item terpisah.
''';

      final content = [
        Content.multi([TextPart(prompt), imagePart])
      ];

      final response = await _model.generateContent(content);
      
      final text = response.text;
      debugPrint('RAW GEMINI RESPONSE: $text');

      if (text != null && text.isNotEmpty) {
        int startIndex = text.indexOf('[');
        int endIndex = text.lastIndexOf(']');
        
        if (startIndex != -1 && endIndex != -1) {
          String jsonStr = text.substring(startIndex, endIndex + 1);
          final List<dynamic> decoded = jsonDecode(jsonStr);
          return decoded.map((e) => e as Map<String, dynamic>).toList();
        } else {
          throw Exception('AI merespons dengan format yang salah:\n$text');
        }
      }
      throw Exception('Response AI kosong.');
    } catch (e) {
      debugPrint('AI Receipt Error: $e');
      throw Exception('Gagal terhubung ke Gemini: $e');
    }
  }

  Future<Uint8List> _preprocessReceiptImage(XFile imageFile) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await recognizer.processImage(inputImage);

      if (!_looksLikeReceipt(recognizedText)) {
        throw Exception(
          'Gambar ini belum terdeteksi sebagai struk. Pastikan yang difoto adalah struk, bukan foto lain.',
        );
      }

      final originalBytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        throw Exception('Gagal membaca gambar dari kamera. Coba ambil ulang foto struk.');
      }

      final cropRect = _extractTextBounds(recognizedText, decoded.width, decoded.height);
      if (cropRect == null) {
        throw Exception('Area struk tidak ditemukan. Pastikan struk terlihat penuh dan tidak terlalu gelap.');
      }

      final cropped = img.copyCrop(
        decoded,
        x: cropRect.left.round(),
        y: cropRect.top.round(),
        width: cropRect.width.round(),
        height: cropRect.height.round(),
      );

      final normalized = _resizeForGemini(cropped);
      final blurScore = _estimateBlurScore(normalized);

      if (blurScore < _minBlurScore) {
        throw Exception(
          'Foto struk terlalu buram untuk diproses. Coba foto ulang dengan fokus yang lebih tajam.',
        );
      }

      return Uint8List.fromList(img.encodeJpg(normalized, quality: 92));
    } finally {
      await recognizer.close();
    }
  }

  bool _looksLikeReceipt(RecognizedText recognizedText) {
    final text = recognizedText.text.toLowerCase();
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length < 2) {
      return false;
    }

    final keywordHits = _receiptKeywords.where(text.contains).length;
    final numericLines = lines.where((line) => RegExp(r'\d').hasMatch(line)).length;
    final currencyHits = RegExp(r'(rp\.?\s?\d+)|(\b\d{3,}\b)').allMatches(text).length;

    return (keywordHits >= 2 && numericLines >= 2) ||
        (currencyHits >= 3 && numericLines >= 3) ||
        (keywordHits >= 1 && currencyHits >= 2 && recognizedText.blocks.length >= 3);
  }

  ui.Rect? _extractTextBounds(RecognizedText recognizedText, int imageWidth, int imageHeight) {
    ui.Rect? bounds;

    for (final block in recognizedText.blocks) {
      final box = block.boundingBox;
      bounds = bounds == null ? box : bounds.expandToInclude(box);
    }

    if (bounds == null) {
      return null;
    }

    final padX = math.max(24, (bounds.width * 0.08).round());
    final padY = math.max(24, (bounds.height * 0.10).round());

    final left = math.max(0, bounds.left.floor() - padX);
    final top = math.max(0, bounds.top.floor() - padY);
    final right = math.min(imageWidth, bounds.right.ceil() + padX);
    final bottom = math.min(imageHeight, bounds.bottom.ceil() + padY);

    final width = math.max(1, right - left);
    final height = math.max(1, bottom - top);

    if (width < 80 || height < 80) {
      return null;
    }

    return ui.Rect.fromLTWH(left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble());
  }

  img.Image _resizeForGemini(img.Image image) {
    final longestSide = math.max(image.width, image.height);
    if (longestSide <= _maxGeminiImageSize) {
      return image;
    }

    if (image.width >= image.height) {
      return img.copyResize(image, width: _maxGeminiImageSize);
    }

    return img.copyResize(image, height: _maxGeminiImageSize);
  }

  double _estimateBlurScore(img.Image image) {
    final gray = img.grayscale(image);
    if (gray.width < 3 || gray.height < 3) {
      return 0;
    }

    double sum = 0;
    double sumSquares = 0;
    int sampleCount = 0;

    for (var y = 1; y < gray.height - 1; y++) {
      for (var x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r.toDouble();
        final laplacian =
            gray.getPixel(x - 1, y).r +
            gray.getPixel(x + 1, y).r +
            gray.getPixel(x, y - 1).r +
            gray.getPixel(x, y + 1).r -
            (4 * center);

        sum += laplacian;
        sumSquares += laplacian * laplacian;
        sampleCount++;
      }
    }

    if (sampleCount == 0) {
      return 0;
    }

    final mean = sum / sampleCount;
    return (sumSquares / sampleCount) - (mean * mean);
  }
}
