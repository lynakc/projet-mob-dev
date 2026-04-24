import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audio_model.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';

class ApiService {

  Future<List<Surah>> fetchSurahs() async {
    final response = await http.get(
      Uri.parse("https://quran.yousefheiba.com/api/surahs"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return List<Surah>.from(
        data.map((e) => Surah.fromJson(e)),
      );
    } else {
      throw Exception("Failed to load surahs");
    }
  }

  Future<List<Reciter>> fetchReciters() async {
    final response = await http.get(
      Uri.parse("https://quran.yousefheiba.com/api/reciters"),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['reciters'];

      return data.map<Reciter>((e) => Reciter.fromJson(e)).toList();
    } else {
      throw Exception("Error loading reciters");
    }
  }

  Future<List<AudioModel>> fetchAudioByReciter(int reciterId) async {

    final surahResponse = await http.get(
      Uri.parse("https://quran.yousefheiba.com/api/surahs"),
    );

    final audioResponse = await http.get(
      Uri.parse("https://quran.yousefheiba.com/api/reciterAudio?reciter_id=$reciterId"),
    );

    if (surahResponse.statusCode == 200 && audioResponse.statusCode == 200) {

      final surahs = jsonDecode(surahResponse.body);
      final audioJson = jsonDecode(audioResponse.body);
      final audioList = audioJson['audio_urls'];

      return audioList.map<AudioModel>((audio) {

        final surah = surahs.firstWhere(
          (s) => s['id'] == audio['surah_id'],
          orElse: () => null,
        );

        return AudioModel(
          titleAr: audio['surah_name_ar'],
          titleEn: surah != null ? surah['name_en'] : audio['surah_name_ar'],
          url: audio['audio_url'],
          reciter: audioJson['reciter_name'],
        );

      }).toList();

    } else {
      throw Exception("Error loading audio");
    }
  }
}