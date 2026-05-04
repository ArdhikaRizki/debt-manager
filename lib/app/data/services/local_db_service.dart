import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDbService extends GetxService {
  late Database _db;

  Future<LocalDbService> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'debt_manager_cache.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Kita membuat tabel sederhana khusus untuk Caching Response API
        await db.execute('''
          CREATE TABLE api_cache (
            endpoint TEXT PRIMARY KEY,
            response_data TEXT,
            updated_at INTEGER
          )
        ''');
      },
    );
    return this;
  }

  // Menyimpan response API mentah (JSON string) ke SQLite
  Future<void> saveCache(String endpoint, dynamic data) async {
    try {
      final jsonString = jsonEncode(data);
      await _db.insert(
        'api_cache',
        {
          'endpoint': endpoint,
          'response_data': jsonString,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  // Mengambil response API yang pernah di-cache
  Future<dynamic> getCache(String endpoint) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'api_cache',
        where: 'endpoint = ?',
        whereArgs: [endpoint],
      );

      if (maps.isNotEmpty) {
        final jsonString = maps.first['response_data'] as String;
        return jsonDecode(jsonString);
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }

  // Membersihkan semua cache (misal saat logout)
  Future<void> clearAllCache() async {
    await _db.delete('api_cache');
  }
}
