import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/models/audio_model.dart';
import '../../core/models/reciter_model.dart';

class SurahsPage extends StatelessWidget {
  final Reciter reciter;

  const SurahsPage({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

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

          final audios = snapshot.data!;

          return ListView.builder(
            itemCount: audios.length,
            itemBuilder: (context, index) {
              final audio = audios[index];

              return ListTile(
                title: Text(audio.titleEn),
                subtitle: Text(audio.titleAr),

                trailing: const Icon(Icons.favorite_border),

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