import 'package:flutter/material.dart';
//import '../player/audio_list_page.dart';
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
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecitersPage()),
                );
              },
              child: const Text("Reciters"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SurahsGlobalPage()),
                );
              },
              child: const Text("Surahs"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FavoritesPage()),
                );
              },
              child: const Text("Favorites"),
            ),

          ],
        ),
      ),
    );
  }
}