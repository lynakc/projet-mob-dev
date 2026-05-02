import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getUserName() async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['firstName'] ?? "User";
  }

  Future<Map<String, dynamic>> getStats() async {
    final doc =
    await _db.collection('users').doc(uid).get();

    return doc.data()?['listeningStats'] ?? {};
  }

  // 🎯 TOTAL TIME
  Future<int> getTotalSeconds() async {
    final stats = await getStats();
    return stats['totalSeconds'] ?? 0;
  }

  // TODAY TIME
  Future<int> getTodaySeconds() async {
    final stats = await getStats();
    final today = DateTime.now().toString().split(' ')[0];

    return stats['daily']?[today] ?? 0;
  }

  // TOP SURAHS
  Future<Map<String, int>> getTopSurahs() async {
    final stats = await getStats();
    return Map<String, int>.from(
        stats['topSurahs'] ?? {});
  }

  // GOAL
  Future<int> getMonthlyGoal() async {
    final stats = await getStats();
    return stats['monthlyGoal'] ?? 0;
  }

  String formatHM(int sec) {
    final hours = sec ~/ 3600;
    final minutes = (sec % 3600) ~/ 60;
    return "$hours h $minutes min";
  }

  Future<Map<String, int>> getDailyStats() async {
    final doc = await usersCollection.doc(userId).get();

    if (!doc.exists) return {};

    final data = doc.data() as Map<String, dynamic>;

    final daily = data['listeningStats']?['daily'] ?? {};

    return Map<String, int>.from(daily);
  }
}