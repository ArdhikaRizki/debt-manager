import 'package:get_storage/get_storage.dart';

class AuthStorage {
  static final _box = GetStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ─── TOKEN ─────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
  }

  static String? getToken() {
    return _box.read<String>(_tokenKey);
  }

  static Future<void> removeToken() async {
    await _box.remove(_tokenKey);
  }

  static bool hasToken() {
    return _box.hasData(_tokenKey);
  }

  // ─── USER DATA ─────────────────────────────────────────

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write(_userKey, user);
  }

  static Map<String, dynamic>? getUser() {
    final data = _box.read(_userKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<void> removeUser() async {
    await _box.remove(_userKey);
  }

  // ─── CLEAR ALL ─────────────────────────────────────────

  static Future<void> clearAll() async {
    await _box.remove(_tokenKey);
    await _box.remove(_userKey);
  }
}
