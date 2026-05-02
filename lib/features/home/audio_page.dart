// features/home/audio_page.dart
import 'package:flutter/material.dart';
import '../favorites/favorites_page.dart';
import '../player/reciters_page.dart';
import '../player/surahs_global_page.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecitersPage()),
              ),
              label: const Text("Browse by Reciter"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.menu_book),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SurahsGlobalPage()),
              ),
              label: const Text("Browse by Surah"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavoritesPage()),
              ),
              label: const Text("Favorites"),
            ),
          ],
        ),
      ),
    );
  }
}
