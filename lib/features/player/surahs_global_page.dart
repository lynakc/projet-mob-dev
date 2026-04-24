import 'package:flutter/material.dart';
import '../../core/services/api_services.dart';
import '../../core/models/surah_model.dart';

class SurahsGlobalPage extends StatefulWidget {
  const SurahsGlobalPage({super.key});

  @override
  State<SurahsGlobalPage> createState() => _SurahsGlobalPageState();
}

class _SurahsGlobalPageState extends State<SurahsGlobalPage> {
  final ApiService api = ApiService();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Surahs")),

      body: Column(
        children: [

          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search surah...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          // 📜 LIST
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
                    .where((s) =>
                    s.nameEn.toLowerCase().contains(search) ||
                    s.nameAr.toLowerCase().contains(search))
                    .toList();

                return ListView.builder(
                  itemCount: surahs.length,
                  itemBuilder: (context, index) {
                    final surah = surahs[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(surah.id.toString()),
                      ),
                      title: Text(surah.nameEn),
                      subtitle: Text(surah.nameAr),

                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Choose a reciter to play"),
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