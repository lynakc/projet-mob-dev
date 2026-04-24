import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/favorites_service.dart';
import '../../core/models/audio_model.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoritesService favService = FavoritesService();

  @override
  Future<bool> confirmDeletion(BuildContext context) async {
    // 🔴 TEMPORAIRE (en attendant Personne A)
    return true;

    // 🟢 FUTUR (Personne A)
    // return await BiometricService().authenticate();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FavoritesService().getFavorites(),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading favorites"));
          }

          final docs = snapshot.data!.docs;

          // empty
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

              return ListTile(
                title: Text(titleEn),
                subtitle: Text(titleAr),

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
                  print("Play: $url"); // 🔥 prêt pour player
                },
              );
            },
          );
        },
      ),
    );
  }
}