import 'dart:convert';
import 'package:http/http.dart' as http;

class HijriService {
  final String url;

  HijriService(this.url);

  Future<String> getHijriDate() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final hijri = data["date"]["date_hijri"];

      final day = hijri["day"];
      final month = hijri["month"]["en"];
      final year = hijri["year"];

      return "$day $month $year";
    } else {
      throw Exception("Failed to load Hijri date");
    }
  }
}
