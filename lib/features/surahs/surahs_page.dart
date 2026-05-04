import 'package:flutter/material.dart';

import '../../core/services/api_services.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/audio_service.dart';

import '../../core/models/audio_model.dart';
import '../../core/models/reciter_model.dart';

import '../../core/widgets/custom_search_bar.dart';
import '../../core/widgets/app_list_tile.dart';

import '../player/player_page.dart';

class SurahsPage extends StatefulWidget {
  final Reciter reciter;
  final int? surahId;

  const SurahsPage({super.key, required this.reciter, this.surahId});

  @override
  State<SurahsPage> createState() => SurahsPageState();
}

class SurahsPageState extends State<SurahsPage> {
  final ApiService api = ApiService();
  final FavoritesService favService = FavoritesService();
  final AudioService audioService = AudioService();

  String search = "";

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// ─────────────────────────────
            /// HEADER (CENTERED)
            /// ─────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                children: [
                  Text(
                    "RECITER",
                    style: TextStyle(
                      fontFamily: "PTSerif",
                      fontSize: 16,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reciter.nameEn,
                    style: const TextStyle(fontFamily: "PTSerif", fontSize: 14),
                  ),
                ],
              ),
            ),

            /// ─────────────────────────────
            /// SEARCH (custom color)
            /// ─────────────────────────────
            CustomSearchBar(
              hint: "Search surah...",
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 10),

            /// ─────────────────────────────
            /// LIST
            /// ─────────────────────────────
            Expanded(
              child: FutureBuilder<List<AudioModel>>(
                future: api.fetchAudioByReciter(widget.reciter.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }

                  final audios = snapshot.data!
                      .where(
                        (a) =>
                            (widget.surahId == null ||
                                a.surahId == widget.surahId) &&
                            (a.titleEn.toLowerCase().contains(search) ||
                                a.titleAr.toLowerCase().contains(search)),
                      )
                      .toList();

                  if (audios.isEmpty) {
                    return const Center(child: Text("No results found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: audios.length,
                    itemBuilder: (context, index) {
                      final audio = audios[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4), // soft grey
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppListTile(
                          title: audio.titleEn,
                          subtitle: "${audio.titleAr} • ${audio.reciter}",

                          /// ▶ PLAY
                          onTap: () async {
                            audioService.setPlaylist(
                              audios.map((e) => e.url).toList(),
                              index,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlayerPage(playlist: audios, index: index),
                              ),
                            );
                          },

                          /// ❤️ FAVORITE ICON
                          trailing: StreamBuilder<bool>(
                            stream: favService.isFavorite(audio),
                            builder: (context, snapshot) {
                              final isFav = snapshot.data ?? false;

                              return IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () async {
                                  if (isFav) {
                                    await favService.removeFavorite(audio);
                                  } else {
                                    await favService.addFavorite(audio);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
