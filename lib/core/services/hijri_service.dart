import 'dart:convert';
import 'package:http/http.dart' as http;

class HijriService {
  final String url;

  HijriService(this.url);

  Map<String, dynamic>? _cache;
  List<String>? _dhikrCache;

  // ================= FETCH MAIN API =================
  Future<Map<String, dynamic>> _fetch() async {
    if (_cache != null) return _cache!;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("API failed");
    }

    _cache = jsonDecode(response.body);
    return _cache!;
  }

  // ================= HIJRI DATE =================
  Future<String> getHijriDate() async {
    final data = await _fetch();

    final hijri = data["date"]["date_hijri"];

    return "${hijri["day"]} ${hijri["month"]["en"]} ${hijri["year"]}";
  }

  // ================= PRAYER TIMES =================
  Future<Map<String, String>> getPrayerTimes() async {
    final data = await _fetch();

    final prayers = data["prayer_times"];

    return {
      "Fajr": prayers["Fajr"],
      "Dhuhr": prayers["Dhuhr"],
      "Asr": prayers["Asr"],
      "Maghrib": prayers["Maghrib"],
      "Isha": prayers["Isha"],
    };
  }

  // ================= DHIKR (FIXED) =================
  Future<String> getRandomDhikr() async {
    if (_dhikrCache != null) {
      _dhikrCache!.shuffle();
      return _dhikrCache!.first;
    }

    final response = await http.get(
      Uri.parse("https://quran.yousefheiba.com/api/duas"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load dhikr");
    }

    final data = jsonDecode(response.body);

    _dhikrCache = [
      ...List<String>.from(
        data["prophetic_duas"].map((e) => e["text"]),
      ),
      ...List<String>.from(
        data["quran_duas"].map((e) => e["text"]),
      ),
      ...List<String>.from(
        data["prophets_duas"].map((e) => e["text"]),
      ),
    ];

    _dhikrCache!.shuffle();
    return _dhikrCache!.first;
  }
}