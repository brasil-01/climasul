import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache simples em SharedPreferences para respostas offline-friendly.
class CacheStore {
  CacheStore._(this._prefs);

  final SharedPreferences _prefs;

  static Future<CacheStore> load() async =>
      CacheStore._(await SharedPreferences.getInstance());

  static const ttl = Duration(minutes: 30);

  Future<void> write(String key, Map<String, dynamic> json) async {
    final payload = jsonEncode({
      'savedAt': DateTime.now().toIso8601String(),
      'body': json,
    });
    await _prefs.setString(key, payload);
  }

  /// Retorna o corpo decodificado e quando foi salvo, ou null se inexistente/expirado.
  Future<CachedEntry?> read(String key, {Duration maxAge = ttl}) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.parse(decoded['savedAt'] as String);
      if (DateTime.now().difference(savedAt) > maxAge) return null;
      return CachedEntry(
        savedAt: savedAt,
        body: decoded['body'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

class CachedEntry {
  const CachedEntry({required this.savedAt, required this.body});
  final DateTime savedAt;
  final Map<String, dynamic> body;
}
