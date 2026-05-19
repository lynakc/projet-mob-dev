import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/favorites_service.dart';
import '../../core/models/audio_model.dart';
import '../../core/services/biometric_service.dart';

import '../../core/widgets/app_list_tile.dart';
import '../../core/widgets/custom_search_bar.dart';
import '../player/player_page.dart';

// ✅ StatefulWidget pour pouvoir gérer le search
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService favService = FavoritesService();
  String search = ""; // ✅ état de recherche

  Future<bool> confirmDeletion() async {
    return await BiometricService().authenticate();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            _buildFavoritesHeader(context),

            // ✅ Barre de recherche ajoutée
            CustomSearchBar(
              hint: "Search favorites...",
              onChanged: (value) {
                setState(() => search = value.toLowerCase());
              },
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FavoritesService().getFavorites(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading favorites"));
                  }

                  final docs = snapshot.data!.docs;

                  // ✅ Filtre de recherche appliqué
                  final filtered = docs.where((fav) {
                    final titleEn = (fav['titleEn'] ?? '').toString().toLowerCase();
                    final titleAr = (fav['titleAr'] ?? '').toString().toLowerCase();
                    final reciter = (fav['reciter'] ?? '').toString().toLowerCase();
                    return titleEn.contains(search) ||
                        titleAr.contains(search) ||
                        reciter.contains(search);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        docs.isEmpty ? "No favorites yet" : "No results found",
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final fav = filtered[index];

                      final titleAr = fav['titleAr'];
                      final titleEn = fav['titleEn'];
                      final url = fav['url'];
                      final reciter = fav['reciter'];
                      final surahId =
                          int.tryParse(fav['surahId'].toString()) ?? 0;

                      return AppListTile(
                        leading: const Icon(Icons.favorite, color: Colors.redAccent),

                        title: titleEn,
                        subtitle: "$titleAr • $reciter",

                        onTap: () {
                          final playlist = filtered.map((doc) {
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
                              builder: (_) =>
                                  PlayerPage(playlist: playlist, index: index),
                            ),
                          );
                        },

                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.redAccent,

                          onPressed: () async {
                            final ok = await confirmDeletion();

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
                                const SnackBar(
                                  content: Text("Authentication required"),
                                ),
                              );
                            }
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
      ),
    );
  }

  Widget _buildFavoritesHeader(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: primary),
              ),
            ),
          ),
          // ✅ Titre visible + cohérent avec les autres pages
          Text(
            "FAVORITES",
            style: TextStyle(
              fontFamily: "PTSerif",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}