import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/audio_model.dart';
import '../../core/models/reciter_model.dart';

class SurahsPage extends StatelessWidget {
  final Reciter reciter;
  final int? surahId;

  const SurahsPage({
    super.key,
    required this.reciter,
    this.surahId,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    final favService = FavoritesService();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reciter.nameEn),
            Text(
              reciter.nameAr,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<AudioModel>>(
        future: api.fetchAudioByReciter(reciter.id),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final audios = snapshot.data!
            .where((a) =>
              surahId == null || a.surahId == surahId)
            .toList();

          if (audios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "This reciter does not have this surah",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];

              return ListTile(
                title: Text(audio.titleEn),
                subtitle: Text(audio.titleAr),

                trailing: StreamBuilder<bool>(
                  stream: favService.isFavorite(audio),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data ?? false;

                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : null,
                      ),
                      onPressed: () async {
                        if (isFav) {
                          await FavoritesService().removeFavorite(audio);
                        } else {
                          await favService.addFavorite(audio);
                        }
                      },
                    );
                  },
                ),

                onTap: () {
                  print(audio.url); // 🔥 DOIT afficher URL
                },
              );
            },
          );
        },
      ),
    );
  }
}