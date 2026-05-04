import 'package:flutter/material.dart';

import '../../core/services/api_services.dart';
import '../../core/models/reciter_model.dart';

import '../../core/widgets/custom_search_bar.dart';
import '../../core/widgets/app_list_tile.dart';

import '../surahs/surahs_page.dart';

class RecitersPage extends StatefulWidget {
  final int? surahId;
  final String? surahName;

  const RecitersPage({super.key, this.surahId, this.surahName});

  @override
  State<RecitersPage> createState() => _RecitersPageState();
}

class _RecitersPageState extends State<RecitersPage> {
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
            /// ─────────────────────────
            /// TITLE CENTER
            /// ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "RECITERS",
                style: TextStyle(
                  fontFamily: "PTSerif",
                  fontSize: 18,
                  color: primary,
                ),
              ),
            ),

            /// ─────────────────────────
            /// SEARCH
            /// ─────────────────────────
            CustomSearchBar(
              hint: "Search reciter...",
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 10),

            /// ─────────────────────────
            /// LIST
            /// ─────────────────────────
            Expanded(
              child: FutureBuilder<List<Reciter>>(
                future: api.fetchReciters(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reciters = snapshot.data!
                      .where(
                        (r) =>
                            r.nameAr.toLowerCase().contains(search) ||
                            r.nameEn.toLowerCase().contains(search),
                      )
                      .toList();

                  if (reciters.isEmpty) {
                    return const Center(child: Text("No results found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: reciters.length,
                    itemBuilder: (context, index) {
                      final reciter = reciters[index];

                      return AppListTile(
                        leading: Icon(Icons.mic, color: accent),

                        title: reciter.nameEn,
                        subtitle: reciter.nameAr,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahsPage(
                                reciter: reciter,
                                surahId: widget.surahId,
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
