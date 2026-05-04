import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  List<MediaItem> _queue = [];

  MyAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);

    /// ✅ Track current playing item (for notification)
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _queue.length) {
        mediaItem.add(_queue[index]);
      }
    });
  }

  /// 🔁 LOOP CONTROL
  Future<void> setLoop(bool loop) async {
    await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
  }

  /// 🎧 PLAYLIST SETUP (FIXED)
  Future<void> setPlaylist(
    List<String> urls, {
    List<String>? titles,
    List<String>? reciters,
  }) async {
    _queue = List.generate(urls.length, (i) {
      return MediaItem(
        id: urls[i],
        title: titles?[i] ?? "Audio",
        artist: reciters?[i] ?? "",
      );
    });

    queue.add(_queue);

    final playlist = ConcatenatingAudioSource(
      children: urls.map((e) => AudioSource.uri(Uri.parse(e))).toList(),
    );

    await _player.setAudioSource(playlist);

    /// ✅ Set first media item for notification
    if (_queue.isNotEmpty) {
      mediaItem.add(_queue[0]);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// 📡 BROADCAST STATE (for notification controls)
  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
      ),
    );
  }
}
