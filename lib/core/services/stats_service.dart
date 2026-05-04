import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DateTime? _startTime;
  String? _currentSurah;

  // ==================== UID SAFE ACCESS ====================

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // ==================== TRACKING ====================

  void startTracking(String surahName) {
    _startTime = DateTime.now();
    _currentSurah = surahName;
  }

  Future<void> stopTracking() async {
    final userId = uid;

    if (_startTime == null || userId == null || _currentSurah == null) return;

    final seconds = DateTime.now().difference(_startTime!).inSeconds;
    if (seconds < 10) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      await _db.collection('users').doc(userId).set({
        'listeningStats': {
          'totalSeconds': FieldValue.increment(seconds),
          'daily': {
            today: FieldValue.increment(seconds),
          },
          'topSurahs': {
            _currentSurah!: FieldValue.increment(1),
          },
          'lastUpdated': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print("Stats error: $e");
    }

    _startTime = null;
    _currentSurah = null;
  }

  // ==================== GET USER ====================

  Future<String> getUserName() async {
    final userId = uid;
    if (userId == null) return "User";

    final doc = await _db.collection('users').doc(userId).get();
    final data = doc.data();

    final first = data?['firstName'] ?? '';
    final last = data?['lastName'] ?? '';

    final full = "$first $last".trim();

    return full.isEmpty ? "User" : full;
  }

  // ==================== STATS ====================

  Future<int> getTotalSeconds() async {
    final userId = uid;
    if (userId == null) return 0;

    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['listeningStats']?['totalSeconds'] ?? 0;
  }

  Future<int> getTodaySeconds() async {
    final userId = uid;
    if (userId == null) return 0;

    final today = DateTime.now().toIso8601String().split('T')[0];

    final doc = await _db.collection('users').doc(userId).get();
    return doc.data()?['listeningStats']?['daily']?[today] ?? 0;
  }

  Future<Map<String, int>> getTopSurahs() async {
    final userId = uid;
    if (userId == null) return {};

    final doc = await _db.collection('users').doc(userId).get();
    final map = doc.data()?['listeningStats']?['topSurahs'] ?? {};

    return Map<String, int>.from(map);
  }

  Future<Map<String, int>> getDailyStats() async {
    final userId = uid;
    if (userId == null) return {};

    final doc = await _db.collection('users').doc(userId).get();
    final map = doc.data()?['listeningStats']?['daily'] ?? {};

    return Map<String, int>.from(map);
  }
}