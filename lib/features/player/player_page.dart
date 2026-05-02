import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '/core/services/audio_service.dart';
import '/core/models/audio_model.dart';
import '/core/services/listening_service.dart';
import '/core/services/favorites_service.dart';

class PlayerPage extends StatefulWidget {
  final List<AudioModel> playlist;
  final int index;

  const PlayerPage({
    super.key,
    required this.playlist,
    required this.index,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioService audioService = AudioService();
  final ListeningService listeningService = ListeningService();
  final FavoritesService favService = FavoritesService();

  Duration current = Duration.zero;
  Duration total = Duration.zero;

  bool isPlaying = false;
  bool isLooping = false;

  late AudioModel currentAudio;

  @override
  void initState() {
    super.initState();

    currentAudio = widget.playlist[widget.index];

    audioService.setPlaylist(
      widget.playlist.map((e) => e.url).toList(),
      widget.index,
    );

    audioService.play();

    listeningService.startTracking(
      currentAudio.titleEn,
      currentAudio.surahId,
    );

    audioService.positionStream.listen((pos) {
      setState(() => current = pos);
    });

    audioService.durationStream.listen((dur) {
      if (dur != null) setState(() => total = dur);
    });

    audioService.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });

      // AUTO NEXT
      if (state.processingState == ProcessingState.completed) {
        audioService.next();

        setState(() {
          currentAudio = widget.playlist[audioService.currentIndex];
        });

        listeningService.stopTracking();
        listeningService.startTracking(
          currentAudio.titleEn,
          currentAudio.surahId,
        );
      }
    });
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  void togglePlay() {
    if (isPlaying) {
      audioService.pause();
      listeningService.stopTracking();
    } else {
      audioService.play();
      listeningService.startTracking(
        currentAudio.titleEn,
        currentAudio.surahId,
      );
    }
  }

  void playNext() async {
    await audioService.next();

    setState(() {
      currentAudio = widget.playlist[audioService.currentIndex];
    });

    listeningService.stopTracking();
    listeningService.startTracking(
      currentAudio.titleEn,
      currentAudio.surahId,
    );
  }

  void playPrevious() async {
    await audioService.previous();

    setState(() {
      currentAudio = widget.playlist[audioService.currentIndex];
    });

    listeningService.stopTracking();
    listeningService.startTracking(
      currentAudio.titleEn,
      currentAudio.surahId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Now Playing")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            currentAudio.titleEn,
            style: const TextStyle(fontSize: 22),
          ),

          Text(currentAudio.titleAr),

          const SizedBox(height: 30),

          Slider(
            value: current.inSeconds.toDouble(),
            max: total.inSeconds > 0 ? total.inSeconds.toDouble() : 1,
            onChanged: (v) =>
                audioService.seek(Duration(seconds: v.toInt())),
          ),

          Text("${format(current)} / ${format(total)}"),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: playPrevious,
              ),

              IconButton(
                iconSize: 64,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: togglePlay,
              ),

              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: playNext,
              ),
            ],
          ),

          const SizedBox(height: 10),

          IconButton(
            icon: Icon(
              Icons.repeat,
              color: isLooping ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() => isLooping = !isLooping);
              audioService.setLoop(isLooping);
            },
          ),

          StreamBuilder<bool>(
            stream: favService.isFavorite(currentAudio),
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  if (isFav) {
                    await favService.removeFavorite(currentAudio);
                  } else {
                    await favService.addFavorite(currentAudio);
                  }
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    listeningService.stopTracking();
    super.dispose();
  }
}