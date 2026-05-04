import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LastPlayedService {
  static const String surahKey = "last_surah";
  static const String reciterKey = "last_reciter";
  static const String indexKey = "last_index";
  static const String positionKey = "last_position";
  static const String urlsKey = "last_urls";

  // ================= SAVE =================
  static Future<void> save({
    required String surah,
    required String reciter,
    required int index,
    required List<String> urls,
    required int position, // in seconds
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(surahKey, surah);
    await prefs.setString(reciterKey, reciter);
    await prefs.setInt(indexKey, index);
    await prefs.setInt(positionKey, position);
    await prefs.setStringList(urlsKey, urls);
  }

  // ================= GET =================
  static Future<Map<String, dynamic>?> get() async {
    final prefs = await SharedPreferences.getInstance();

    final urls = prefs.getStringList(urlsKey);

    if (urls == null) return null;

    return {
      "surah": prefs.getString(surahKey),
      "reciter": prefs.getString(reciterKey),
      "index": prefs.getInt(indexKey) ?? 0,
      "position": prefs.getInt(positionKey) ?? 0,
      "urls": urls,
    };
  }

  // ================= CLEAR =================
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  // In LastPlayedService
  static Future<void> updatePosition(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(positionKey, seconds);
    final raw = prefs.getString('last_played');
    if (raw == null) return;

    final data = Map<String, dynamic>.from(jsonDecode(raw));
    data['position'] = seconds;
    await prefs.setString('last_played', jsonEncode(data));
  }
}
