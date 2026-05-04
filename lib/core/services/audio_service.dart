import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'stats_service.dart';
import '/../features/player/player_page.dart';
import 'last_played_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final StatsService _statsService = StatsService();

  String currentSurahName = "";
  String currentReciter = "";
  int currentSurahNumber = 0;

  List<String> _playlist = [];
  int _index = 0;

  // ================= INIT =================
  Future<void> initBackground() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.projetmobdev.channel.audio',
      androidNotificationChannelName: 'Quran Audio',
      notificationColor: const Color(0xFF1E8E3E),
    );
  }

  // ================= PLAYLIST =================
  void setPlaylist(List<String> urls, int startIndex) {
    _playlist = urls;
    _index = startIndex;

    _player.setUrl(_playlist[_index]); // load first track
  }

  int get currentIndex => _index;

  // ================= BASIC CONTROL =================
  bool get isPlaying => _player.playing;
  bool get isLoaded => _player.audioSource != null;

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
    await _statsService.stopTracking();

    await LastPlayedService.updatePosition(_player.position.inSeconds);
  }

  Future<void> stop() async {
    await _player.stop();
    await _statsService.stopTracking();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // ================= NEXT / PREV =================
  Future<void> next() async {
    if (_index < _playlist.length - 1) {
      _index++;
      await _player.setUrl(_playlist[_index]);
      await _player.play();
    }
  }

  Future<void> previous() async {
    if (_index > 0) {
      _index--;
      await _player.setUrl(_playlist[_index]);
      await _player.play();
    }
  }

  // ================= LOOP =================
  void setLoop(bool loop) {
    _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  }

  // ================= STREAMS =================
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}
