import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: FutureBuilder(
        future: service.getProfile(user.uid),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("First name: ${data['firstName']}"),
                Text("Last name: ${data['lastName']}"),
                Text("Email: ${data['email']}"),
                Text("Date of birth: ${data['dob']}"),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => service.logout(),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}