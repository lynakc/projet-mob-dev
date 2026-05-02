import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/audio_model.dart';
import '../../core/services/biometric_service.dart';
import '../player/player_page.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoritesService favService = FavoritesService();

  Future<bool> confirmDeletion(BuildContext context) async {
    return await BiometricService().authenticate();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoritesService().getFavorites(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading favorites"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No favorites yet"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final fav = docs[index];

              final titleAr = fav['titleAr'];
              final titleEn = fav['titleEn'];
              final url = fav['url'];
              final reciter = fav['reciter'];
              final surahId = int.tryParse(fav['surahId'].toString()) ?? 0;

              return ListTile(
                title: Text(titleEn),
                subtitle: Text("$titleAr • $reciter"),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final ok = await confirmDeletion(context);

                    if (ok) {
                      await favService.removeFavorite(
                        AudioModel(
                          titleAr: titleAr,
                          titleEn: titleEn,
                          url: url,
                          reciter: reciter,
                          surahId: surahId,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Authentication required")),
                      );
                    }
                  },
                ),

                onTap: () {

                  final playlist = docs.map((doc) {
                    return AudioModel(
                      titleAr: doc['titleAr'],
                      titleEn: doc['titleEn'],
                      url: doc['url'],
                      reciter: doc['reciter'],
                      surahId: int.tryParse(doc['surahId'].toString()) ?? 0,
                    );
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerPage(
                        playlist: playlist,
                        index: index,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}