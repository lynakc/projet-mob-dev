class StatsModel {
  final String fullName;

  final int totalSeconds;
  final int monthlyGoal;

  final Map<String, int> daily;
  final Map<String, int> topSurahs;

  final int liveSessionSeconds;
  final String? liveSessionSurah;

  StatsModel({
    required this.fullName,
    required this.totalSeconds,
    required this.monthlyGoal,
    required this.daily,
    required this.topSurahs,
    required this.liveSessionSeconds,
    required this.liveSessionSurah,
  });

  factory StatsModel.fromFirestore(Map<String, dynamic> data) {
    final listening = Map<String, dynamic>.from(data['listeningStats'] ?? {});
    final live = Map<String, dynamic>.from(data['liveSession'] ?? {});

    return StatsModel(
      fullName: "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim(),

      totalSeconds: _toInt(listening['totalSeconds']),
      monthlyGoal: _toInt(listening['monthlyGoal'], fallback: 72000),

      daily: _convertMap(listening['daily']),
      topSurahs: _convertMap(listening['topSurahs']),

      liveSessionSeconds: _toInt(live['seconds']),
      liveSessionSurah: live['surah'],
    );
  }

  // ── SAFE INT PARSER ─────────────────────────────
  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  // ── SAFE MAP PARSER ─────────────────────────────
  static Map<String, int> _convertMap(dynamic data) {
    if (data == null || data is! Map) return {};

    final result = <String, int>{};

    data.forEach((key, value) {
      result[key.toString()] = _toInt(value);
    });

    return result;
  }

  // ── UI HELPERS ─────────────────────────────
  int get totalHours => totalSeconds ~/ 3600;

  int get remainingMinutes => (totalSeconds % 3600) ~/ 60;

  int get monthMinutes => totalSeconds ~/ 60;

  int get monthSeconds => totalSeconds;

  List<MapEntry<String, int>> get sortedTopSurahs {
    final list = topSurahs.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<DailyStat> get currentMonthDaily {
    return daily.entries.map((e) {
      final d = e.key.split('-');
      if (d.length != 3) {
        return DailyStat(date: DateTime.now(), seconds: e.value);
      }

      return DailyStat(
        date: DateTime(
          int.parse(d[0]),
          int.parse(d[1]),
          int.parse(d[2]),
        ),
        seconds: e.value,
      );
    }).toList();
  }
}

class DailyStat {
  final DateTime date;
  final int seconds;

  DailyStat({required this.date, required this.seconds});
}