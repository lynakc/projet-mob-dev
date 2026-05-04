/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetmobdev/features/player/reciters_page.dart';
import '../../core/services/auth_service.dart';
import '../favorites/favorites_page.dart';
import '../player/surahs_global_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: service.getProfile(user.uid),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("First name: ${data['firstName']}"),
                Text("Last name: ${data['lastName']}"),
                Text("Mail address: ${data['email']}"),
                Text("Date of birth: ${data['dob']}"),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () => service.logout(),
                  child: const Text("Logout"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                    );
                  },
                  child: const Text("My Favorites"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecitersPage()),
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
              ],
            ),
          );
        },
      ),
    );
  }
}*/