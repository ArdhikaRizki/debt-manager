import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiReceiptService extends GetxService {
  late final String _apiKey;
  late final GenerativeModel _model;

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
      final imageBytes = await imageFile.readAsBytes();
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
}
