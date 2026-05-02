import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeningService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _startTime;
  String? _currentSurah;
  int? _currentSurahId;

  /// call when audio starts
  void startTracking(String surahName, int surahId) {
    _startTime = DateTime.now();
    _currentSurah = surahName;
    _currentSurahId = surahId;
  }

  /// call when audio pauses/stops
  Future<void> stopTracking() async {
    if (_startTime == null) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final endTime = DateTime.now();
    final seconds = endTime.difference(_startTime!).inSeconds;

    if (seconds <= 0) return;

    final today = DateTime.now().toIso8601String().split("T")[0];

    final ref = _db.collection("users").doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      final data = snapshot.data() ?? {};
      final stats = data["listeningStats"] ?? {};

      final total = (stats["totalSeconds"] ?? 0) + seconds;

      final daily = Map<String, dynamic>.from(stats["daily"] ?? {});
      daily[today] = (daily[today] ?? 0) + seconds;

      final top = Map<String, dynamic>.from(stats["topSurahs"] ?? {});
      if (_currentSurah != null) {
        top[_currentSurah!] = (top[_currentSurah!] ?? 0) + 1;
      }

      transaction.set(ref, {
        "listeningStats": {
          "totalSeconds": total,
          "daily": daily,
          "topSurahs": top,
          "monthlyGoal": stats["monthlyGoal"] ?? 7200,
        }
      }, SetOptions(merge: true));
    });

    _startTime = null;
    _currentSurah = null;
    _currentSurahId = null;
  }
}