import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/favorites_service.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final FavoritesService favService = FavoritesService();

  @override
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
              final title = fav['title'];

              return ListTile(
                title: Text(title),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await favService.removeFavorite(title);
                  },
                ),

                onTap: () {
                  print("Play favorite: $title");
                  // plus tard → connecter au player
                },
              );
            },
          );
        },
      ),
    );
  }
}