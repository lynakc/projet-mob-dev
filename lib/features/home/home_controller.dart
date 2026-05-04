import '../../core/services/last_played_service.dart';
import '../../core/services/audio_service.dart';

class HomeController {
  String? surah;
  String? reciter;

  Future<void> loadLastPlayed() async {
    final data = await LastPlayedService.get();
    surah = data?["surah"];
    reciter = data?["reciter"];
  }

  Future<void> resumeLastPlayed() async {
    final audio = AudioService();

    // If already playing → just pause
    if (audio.isPlaying) {
      await audio.pause();
      return;
    }

    final data = await LastPlayedService.get();
    if (data == null) return;

    final urls = List<String>.from(data["urls"] ?? []);
    if (urls.isEmpty) return;

    final index = (data["index"] ?? 0) as int;
    final position = (data["position"] ?? 0) as int;
    final safeIndex = index.clamp(0, urls.length - 1);

    // Only reload playlist if it's a different track
    if (!audio.isLoaded) {
      audio.setPlaylist(urls, safeIndex);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await audio.seek(Duration(seconds: position));
    await audio.play();
  }
}
