/*import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/models/audio_model.dart';
import '../../core/services/favorites_service.dart';

class AudioListPage extends StatelessWidget {
  final ApiService api = ApiService();

  AudioListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audios")),
      body: FutureBuilder<List<AudioModel>>(
        future: api.fetchAudios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
            //return Center(child: Text(snapshot.error.toString()));
          }

          final audios = snapshot.data!;

          return ListView.builder(
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];

              return ListTile(
                title: Text(audio.title),
                trailing: StreamBuilder<bool>(
                  stream: FavoritesService().isFavorite(audio.title),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data ?? false;

                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : null,
                      ),
                      onPressed: () async {
                        if (isFav) {
                          await FavoritesService().removeFavorite(audio.title);
                        } else {
                          await FavoritesService().addFavorite(audio.title);
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
    );
  }
}*/