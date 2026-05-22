import 'package:flutter/material.dart';
import '../favorites/favorites_page.dart';
import '../reciters/reciters_page.dart';
import '../surahs/surahs_global_page.dart';
import 'home_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/hijri_service.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final HomeController controller = HomeController();
  late AudioService audioService;
  late HijriService hijriService; // declared as field
  String hijriDate = "Loading..."; //  declared as field

  String todayDhikr = "Loading...";
  Map<String, String> prayerTimes = {};

  Duration current = Duration.zero;
  Duration total = Duration.zero;
  bool isPlaying = false;


  @override
  void initState() {
    super.initState();

    hijriService = HijriService(
      "https://quran.yousefheiba.com/api/getPrayerTimes",
    );

    _init();

    loadHijri();
    loadDhikr();
    loadPrayerTimes();

    audioService = AudioService();

    audioService.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => current = pos);
    });

    audioService.durationStream.listen((dur) {
      if (!mounted) return;
      if (dur != null) setState(() => total = dur);
    });

    audioService.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => isPlaying = state.playing);
    });
  }

  // defined as class method not inside initState
  void loadHijri() async {
    try {
      final result = await hijriService.getHijriDate();
      if (!mounted) return;
      setState(() => hijriDate = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => hijriDate = "Error");
    }
  }

  Future<void> _init() async {
    await controller.loadLastPlayed();
    if (mounted) setState(() {});
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "${two(h)}:${two(m)}:${two(s)}";
    return "${two(m)}:${two(s)}";
  }

  void loadDhikr() async {
    try {
      final result = await hijriService.getRandomDhikr();
      if (!mounted) return;
      setState(() => todayDhikr = result);
    } catch (e) {
      setState(() => todayDhikr = "Error loading dhikr");
    }
  }

  void loadPrayerTimes() async {
    try {
      final result = await hijriService.getPrayerTimes();
      if (!mounted) return;
      setState(() => prayerTimes = result);
    } catch (e) {
      print(e);
    }
  }

  void showPrayerTimes() {
    const rowColor = Color(0xFFF4EBE0);
    const textColor = Color(0xFF5C3D1E);
    const timeColor = Color(0xFF8B5E3C);
    final ordered = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Prayer Times",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              ...ordered.map((name) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: rowColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, color: textColor)),
                    Text(
                      prayerTimes[name] ?? "--",
                      style: const TextStyle(fontSize: 14, color: timeColor),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: rowColor,
                  foregroundColor: timeColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              //  HEADER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hijriDate,
                    style: TextStyle(
                      fontFamily: "PTSerif",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),

                ],
              ),

              const SizedBox(height: 20),

              //  LAST PLAYED CARD (CORRECTED - NO DUPLICATES)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // subtle logo top-right
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Opacity(
                        opacity: 0.60,
                        child: Image.asset(
                          "assets/images/small_logo.png",
                          height: 110,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // label
                          Row(
                            children: [
                              Icon(Icons.play_circle, color: accent, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "LAST PLAYED",
                                style: TextStyle(
                                  fontFamily: "PTSerif",
                                  fontSize: 11,
                                  color: accent,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // surah name
                          Text(
                            controller.surah ?? "No Surah",
                            style: const TextStyle(
                              fontFamily: "PTSerif",
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // reciter
                          Text(
                            controller.reciter ?? "",
                            style: const TextStyle(
                              fontFamily: "PTSerif",
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // PLAYER ROW (CLEAN - ONE SLIDER, TWO BUTTONS)
                          Row(
                            children: [
                              // RESUME BUTTON (opens full player)
                              GestureDetector(
                                onTap: () async {
                                  await controller.resumeLastPlayed();
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // SLIDER + TIME
                              Expanded(
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2.5,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 5,
                                        ),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                              overlayRadius: 12,
                                            ),
                                        activeTrackColor: accent,
                                        inactiveTrackColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        thumbColor: Colors.white,
                                        overlayColor: accent.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                      child: Slider(
                                        value: current.inSeconds.toDouble(),
                                        max: total.inSeconds > 0
                                            ? total.inSeconds.toDouble()
                                            : 1,
                                        onChanged: (value) async {
                                          await AudioService().seek(
                                            Duration(seconds: value.toInt()),
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _format(current),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white54,
                                          ),
                                        ),
                                        Text(
                                          _format(total),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //dhikr card
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBE0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quranic Duas",
                      style: TextStyle(
                        fontFamily: "Amiri",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      todayDhikr,
                      style: TextStyle(
                        fontFamily: "Amiri",
                        fontSize: 20,
                        height: 1.9,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              //  EXPLORE TITLE
              const SizedBox(height: 10),
              Text(
                "Explore",
                style: TextStyle(
                  fontFamily: "PTSerif",
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: primary,
                ),
              ),

              const SizedBox(height: 25),

              //  GRID
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.35,
                  children: [
                    _tile(context, "Surahs", Icons.menu_book, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SurahsGlobalPage()));
                    }),

                    _tile(context, "Reciters", Icons.mic, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => RecitersPage()));
                    }),

                    _tile(context, "Favorites", Icons.favorite, () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FavoritesPage()));
                    }),

                    _tile(
                      context,
                      "Prayer Times",
                      Icons.access_time,
                      showPrayerTimes,
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

  //  helpers
  String _formatTime(double seconds) {
    final s = seconds.toInt();
    final m = s ~/ 60;
    final sec = s % 60;
    return "$m:${sec.toString().padLeft(2, '0')}";
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    final accent = Theme.of(context).colorScheme.secondary;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBE0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontFamily: "PTSerif", color: primary),
            ),
          ],
        ),
      ),
    );
  }
}
