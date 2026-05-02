import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  int get currentIndex => _currentIndex;

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  List<String> _playlist = [];
  int _currentIndex = 0;

  // ---------- LOAD PLAYLIST ----------
  Future<void> setPlaylist(List<String> urls, int startIndex) async {
    _playlist = urls;
    _currentIndex = startIndex;

    await _player.setUrl(_playlist[_currentIndex]);
  }

  // ---------- PLAY ----------
  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  // ---------- NEXT / PREV ----------
  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await _player.setUrl(_playlist[_currentIndex]);
      await play();
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _player.setUrl(_playlist[_currentIndex]);
      await play();
    }
  }

  // ---------- SEEK ----------
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // ---------- LOOP ----------
  void setLoop(bool loop) {
    _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  }

  // ---------- STREAMS ----------
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
}