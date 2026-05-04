import 'package:flutter/material.dart';

import '../../core/services/api_services.dart';
import '../../core/models/surah_model.dart';
import '../../core/widgets/custom_search_bar.dart';
import '../../core/widgets/app_list_tile.dart';

import '../reciters/reciters_page.dart';

class SurahsGlobalPage extends StatefulWidget {
  const SurahsGlobalPage({super.key});

  @override
  State<SurahsGlobalPage> createState() => SurahsGlobalPageState();
}

class SurahsGlobalPageState extends State<SurahsGlobalPage> {
  final ApiService api = ApiService();
  String search = "";

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "SURAH LIST",
                style: TextStyle(
                  fontFamily: "PTSerif",
                  fontSize: 18,
                  color: primary,
                ),
              ),
            ),

            /// SEARCH
            CustomSearchBar(
              hint: "Search surah...",
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: FutureBuilder<List<Surah>>(
                future: api.fetchSurahs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading surahs"));
                  }

                  final surahs = snapshot.data!
                      .where(
                        (s) =>
                            s.nameEn.toLowerCase().contains(search) ||
                            s.nameAr.toLowerCase().contains(search),
                      )
                      .toList();

                  if (surahs.isEmpty) {
                    return const Center(child: Text("No results found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      final surah = surahs[index];

                      return AppListTile(
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            surah.id.toString(),
                            style: TextStyle(
                              fontFamily: "PTSerif",
                              fontSize: 12,
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        title: surah.nameEn,
                        subtitle: surah.nameAr,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecitersPage(
                                surahId: surah.id,
                                surahName: surah.nameEn,
                              ),
                            ),
                          );
                        },
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
}
