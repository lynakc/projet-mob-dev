import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/models/reciter_model.dart';
import 'surahs_page.dart';

class RecitersPage extends StatefulWidget {
  final int? surahId;
  final String? surahName;

  const RecitersPage({
    super.key,
    this.surahId,
    this.surahName,
  });

  @override
  State<RecitersPage> createState() => _RecitersPageState();
}

class _RecitersPageState extends State<RecitersPage> {
  final ApiService api = ApiService();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reciters")),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search reciter...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => search = value.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Reciter>>(
              future: api.fetchReciters(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reciters = snapshot.data!
                    .where((r) =>
                      r.nameAr.toLowerCase().contains(search) ||
                      r.nameEn.toLowerCase().contains(search)
                    )
                    .toList();

                return ListView.builder(
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];

                    return ListTile(
                      title: Text(reciter.nameEn),
                      subtitle: Text(reciter.nameAr),
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
    );
  }
}