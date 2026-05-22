import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Stream<DocumentSnapshot> getStatsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  String formatHM(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    return "$h h $m min";
  }

  List<MapEntry<String, double>> getLast7Days(Map<String, dynamic> daily) {
    final now = DateTime.now();
    List<MapEntry<String, double>> result = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split("T")[0];
      final value = (daily[key] ?? 0) / 60;
      result.add(MapEntry(key, value.toDouble()));
    }
    return result;
  }

  double _getMaxY(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 10;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (max == 0) return 10;
    final step = _getYInterval(data);
    return ((max / step).ceil() * step) + step;
  }

  double _getYInterval(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 5;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    if (max <= 20) return 5;
    if (max <= 60) return 10;
    if (max <= 120) return 20;
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getStatsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final stats = data['listeningStats'] ?? {};
          final userData = data;


          final firstName = (userData['firstName'] ?? '').toString().trim();
          final lastName = (userData['lastName'] ?? '').toString().trim();
          final fullName = '$firstName $lastName'.trim();

          final total = (stats['totalSeconds'] ?? 0).toDouble();
          final daily = Map<String, dynamic>.from(stats['daily'] ?? {});
          final top = Map<String, dynamic>.from(stats['topSurahs'] ?? {});

          final todayKey = DateTime.now().toIso8601String().split('T')[0];
          final today = (daily[todayKey] ?? 0).toDouble();

          final sorted = top.entries.toList()
            ..sort((a, b) => (b.value as num).compareTo(a.value as num));

          final last7 = getLast7Days(daily);
          final goal = (stats['goalSeconds'] ?? 72000) as num;
          final progress = goal == 0 ? 0.0 : (total / goal).clamp(0.0, 1.0);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome ──────
                if (fullName.isNotEmpty) ...[
                  Text(
                    "Welcome back,",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Stat Cards ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Total listened",
                        formatHM(total.toInt()),
                        Icons.headphones_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        "Today",
                        formatHM(today.toInt()),
                        Icons.today_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Monthly Goal ──────
                _buildContainerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Monthly Goal",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildGoalDropdown(goal.toInt()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFC9A84C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${(progress * 100).toStringAsFixed(1)}%  ·  ${formatHM(total.toInt())} of ${goal.toInt() ~/ 3600} h",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Chart ────────────────────────────────────────────
                _buildContainerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Last 7 days (min)",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            maxY: _getMaxY(last7),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: Colors.grey.withOpacity(0.12),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  interval: _getYInterval(last7),
                                  getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= last7.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final date =
                                    DateTime.parse(last7[i].key);
                                    return Text(
                                      "${date.day}/${date.month}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withOpacity(0.5),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: last7.asMap().entries.map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.value,
                                    color: const Color(0xFFC9A84C),
                                    width: 14,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _getMaxY(last7),
                                      color: Colors.grey.withOpacity(0.07),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, _, rod, __) =>
                                    BarTooltipItem(
                                      "${rod.toY.toStringAsFixed(1)} min",
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Top Surahs ──────────
                if (sorted.isNotEmpty)
                  _buildContainerCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Most Listened",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...sorted.take(5).toList().asMap().entries.map((e) {
                          final i = e.key;
                          final surah = e.value;
                          final count = (surah.value as num).toInt();
                          final maxCount =
                          (sorted.first.value as num).toInt();
                          final fraction =
                          maxCount > 0 ? count / maxCount : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text(
                                    "${i + 1}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    surah.key,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      minHeight: 6,
                                      backgroundColor:
                                      Colors.grey.withOpacity(0.12),
                                      valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFC9A84C),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${count}x",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC9A84C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────

  Widget _buildContainerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC9A84C), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDropdown(int goal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: [36000, 72000, 108000].contains(goal) ? goal : 72000,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          isDense: true,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          items: [36000, 72000, 108000].map((g) {
            return DropdownMenuItem(
              value: g,
              child: Text("${g ~/ 3600} hours"),
            );
          }).toList(),
          onChanged: (value) async {
            if (value == null) return;

            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;

            // Fix: Use goalSeconds consistently and merge properly
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'listeningStats': {
                'goalSeconds': value, // Use goalSeconds
                'totalSeconds': FieldValue.increment(0), // Preserve existing values
              }
            }, SetOptions(merge: true));
          },
        ),
      ),
    );
  }
}