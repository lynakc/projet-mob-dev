import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/services/audio_service.dart';
import '../../core/models/audio_model.dart';
import '../../core/services/listening_service.dart';
import '../../core/services/favorites_service.dart';

class PlayerPage extends StatefulWidget {
  final List<AudioModel> playlist;
  final int index;

  const PlayerPage({super.key, required this.playlist, required this.index});

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

    _setupListeners();
  }

  void _setupListeners() {
    listeningService.startTracking(currentAudio.titleEn, currentAudio.surahId);

    audioService.positionStream.listen((pos) {
      if (mounted) setState(() => current = pos);
    });

    audioService.durationStream.listen((dur) {
      if (dur != null && mounted) setState(() => total = dur);
    });

    audioService.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
    }
    return "${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  void next() async {
    await audioService.next();
    _updateTrack();
  }

  void previous() async {
    await audioService.previous();
    _updateTrack();
  }

  void _updateTrack() {
    setState(() {
      currentAudio = widget.playlist[audioService.currentIndex];
    });
    listeningService.stopTracking();
    listeningService.startTracking(currentAudio.titleEn, currentAudio.surahId);
  }

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.black54, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const bgColor = Color(0xFFFAF9F6);
    const goldAccent = Color(0xFFC59D5F);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _headerButton(
                    Icons.keyboard_arrow_down,
                    () => Navigator.pop(context),
                  ),
                  Column(
                    children: [
                      const Text(
                        "NOW PLAYING",
                        style: TextStyle(
                          color: goldAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Text(
                        "Quran Audio ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<bool>(
                    stream: favService.isFavorite(currentAudio),
                    builder: (context, snapshot) {
                      final isFav = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isFav ? Colors.red : goldAccent,
                        ),
                        onPressed: () async {
                          if (isFav) {
                            await favService.removeFavorite(currentAudio);
                          } else {
                            await favService.addFavorite(currentAudio);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // CENTER CARD
              Container(
                height: MediaQuery.of(context).size.width * 0.7,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: 0.40,
                        child: Image.asset(
                          "assets/images/small_logo.png",
                          height: 140,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Text(
                        currentAudio.titleAr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: goldAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // TITLES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currentAudio.titleEn,
                          style: const TextStyle(
                            fontFamily: "PTSerif",
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          currentAudio.reciter,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // WAVEFORM VISUALIZER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(15, (index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 3,
                    height: (index % 3 == 0) ? 25 : 15,
                    decoration: BoxDecoration(
                      color: goldAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // SLIDER
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: goldAccent,
                  inactiveTrackColor: goldAccent.withOpacity(0.2),
                  thumbColor: bgColor,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                    elevation: 2,
                  ),
                ),
                child: Slider(
                  value: current.inSeconds.toDouble(),
                  max: total.inSeconds > 0 ? total.inSeconds.toDouble() : 1,
                  onChanged: (v) =>
                      audioService.seek(Duration(seconds: v.toInt())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(current),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "-${_formatDuration(total - current)}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 🛠️ MOVED UP: Swapped Spacer() for a fixed height to bring controls closer to the slider
              const SizedBox(height: 30),

              // CONTROLS
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 60,
                ), // Increased bottom padding to lift the row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔁 LOOP BUTTON (With dynamic color)
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        // ✅ Changes to primary theme color when active
                        color: isLooping ? colorScheme.primary : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => isLooping = !isLooping);
                        audioService.setLoop(isLooping);
                      },
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        size: 40,
                        color: Color(0xFFD1D1D1),
                      ),
                      onPressed: previous,
                    ),

                    // 🎨 PLAY/PAUSE BUTTON
                    GestureDetector(
                      onTap: () {
                        isPlaying ? audioService.pause() : audioService.play();
                        setState(() => isPlaying = !isPlaying);
                      },
                      child: Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: colorScheme.onPrimary,
                          size: 40,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        size: 40,
                        color: Color(0xFFD1D1D1),
                      ),
                      onPressed: next,
                    ),

                    // 🔀 SHUFFLE ICON (To keep the symmetry of the row)
                    IconButton(
                      icon: const Icon(Icons.shuffle, color: Colors.grey),
                      onPressed: () {
                        // Shuffle logic
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
