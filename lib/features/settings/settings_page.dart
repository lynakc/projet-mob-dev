import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_page.dart';
import '../../core/theme/theme_state.dart';

void changeTheme(String theme) {
  ThemeState.currentTheme.value = theme;
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final service = AuthService();

    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white,

      body: FutureBuilder(
        future: service.getProfile(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TITLE =================
                Center(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      color: accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= PROFILE CARD =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primary,
                        child: Icon(Icons.person, color: accent),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data['firstName']} ${data['lastName']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['email'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ================= INFORMATION LABEL =================
                Text(
                  "information",
                  style: TextStyle(color: accent, fontSize: 16),
                ),

                const SizedBox(height: 10),

                // ================= FIELDS =================
                _field(Icons.person, "First Name", data['firstName']),
                _field(Icons.person_outline, "Last Name", data['lastName']),
                _field(Icons.email, "Email", data['email']),
                _field(Icons.cake, "Date of Birth", data['dob']),

                const SizedBox(height: 25),

                // ================= GENERAL LABEL =================
                Text("general", style: TextStyle(color: accent, fontSize: 16)),

                const SizedBox(height: 10),

                // ================= THEME =================
                GestureDetector(
                  onTap: () => _showThemeDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.color_lens, color: primary),
                        const SizedBox(width: 10),
                        const Expanded(child: Text("Theme")),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ================= LOGOUT =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await service.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= FIELD UI =================
  Widget _field(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CENTER THEME DIALOG =================
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Material(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Theme",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  _themeOption(context, "blue", Colors.blue),
                  _themeOption(context, "green", Colors.green),
                  _themeOption(context, "purple", Colors.purple),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= THEME OPTION =================
  Widget _themeOption(BuildContext context, String name, Color color) {
    return GestureDetector(
      onTap: () {
        changeTheme(name);
        Navigator.pop(context); //  clean fix
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "($name)",
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
