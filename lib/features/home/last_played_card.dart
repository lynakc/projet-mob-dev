import 'package:flutter/material.dart';

class LastPlayedCard extends StatelessWidget {
  final String? surah;
  final String? reciter;
  final VoidCallback onResume;

  const LastPlayedCard({
    super.key,
    this.surah,
    this.reciter,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.history, size: 16, color: Colors.green),
              SizedBox(width: 6),
              Text(
                "Last Played",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            surah ?? "No surah played yet",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            reciter ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 14),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onResume,
            child: const Text("Resume"),
          ),
        ],
      ),
    );
  }
}
