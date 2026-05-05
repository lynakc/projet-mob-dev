import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/models/audio_model.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/listening_service.dart';
import '../../core/services/favorites_service.dart';

class PlayerController extends ChangeNotifier {
  final AudioService audioService = AudioService();
  final ListeningService listeningService = ListeningService();
  final FavoritesService favService = FavoritesService();

  late List<AudioModel> playlist;
  late AudioModel current;

  Duration currentPos = Duration.zero;
  Duration total = Duration.zero;

  bool isPlaying = false;
  bool isLooping = false;

  int currentIndex = 0;

  void init(List<AudioModel> list, int index) {
    playlist = list;
    currentIndex = index;
    current = playlist[index];

    audioService.setPlaylist(playlist.map((e) => e.url).toList(), index);

    audioService.play();

    listeningService.startTracking(current.titleEn, current.surahId);

    _bindStreams();
  }

  void _bindStreams() {
    audioService.positionStream.listen((pos) {
      currentPos = pos;
      notifyListeners();
    });

    audioService.durationStream.listen((dur) {
      if (dur != null) {
        total = dur;
        notifyListeners();
      }
    });

    audioService.playerStateStream.listen((state) {
      isPlaying = state.playing;

      if (state.processingState == ProcessingState.completed) {
        next();
      }

      notifyListeners();
    });
  }

  void togglePlay() {
    if (isPlaying) {
      audioService.pause();
      listeningService.stopTracking();
    } else {
      audioService.play();
      listeningService.startTracking(current.titleEn, current.surahId);
    }
  }

  void next() {
    audioService.next();
    _updateTrack();
  }

  void previous() {
    audioService.previous();
    _updateTrack();
  }

  void _updateTrack() {
    currentIndex = audioService.currentIndex;
    current = playlist[currentIndex];

    listeningService.stopTracking();
    listeningService.startTracking(current.titleEn, current.surahId);

    notifyListeners();
  }

  void seek(Duration d) {
    audioService.seek(d);
  }

  void toggleLoop() {
    isLooping = !isLooping;
    audioService.setLoop(isLooping);
    notifyListeners();
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');

    if (d.inHours > 0) {
      return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
    }
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }
}
