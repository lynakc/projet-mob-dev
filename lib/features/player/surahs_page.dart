import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/models/audio_model.dart';
import '../../core/models/reciter_model.dart';
import 'player_page.dart';

class SurahsPage extends StatefulWidget {
  final Reciter reciter;
  final int? surahId;

  const SurahsPage({
    super.key,
    required this.reciter,
    this.surahId,
  });

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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.reciter.nameEn),
            Text(
              widget.reciter.nameAr,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search surah...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          // 📄 LIST
          Expanded(
            child: FutureBuilder<List<AudioModel>>(
              future: api.fetchAudioByReciter(widget.reciter.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final audios = snapshot.data!
                    .where((a) =>
                (widget.surahId == null ||
                    a.surahId == widget.surahId) &&
                    (a.titleEn.toLowerCase().contains(search) ||
                        a.titleAr.contains(search)))
                    .toList();

                if (audios.isEmpty) {
                  return const Center(
                    child: Text("No results found"),
                  );
                }

                return ListView.builder(
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    final audio = audios[index];

                    return ListTile(
                      title: Text(audio.titleEn),
                      subtitle:
                      Text("${audio.titleAr} • ${audio.reciter}"),

                      // ▶ PLAY AUDIO
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerPage(
                              playlist: audios,
                              index: index,
                            )
                          ),
                        );
                      },

                      // ❤️ FAVORITES
                      trailing: StreamBuilder<bool>(
                        stream: favService.isFavorite(audio),
                        builder: (context, snapshot) {
                          final isFav = snapshot.data ?? false;

                          return IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFav ? Colors.red : null,
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}