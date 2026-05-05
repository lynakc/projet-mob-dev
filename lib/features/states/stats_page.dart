import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/services/stats_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsService statsService = StatsService();

  int total = 0;
  int today = 0;
  int goal = 72000;
  Map<String, int> top = {};
  Map daily = {};
  String name = "User";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    total = await statsService.getTotalSeconds();
    today = await statsService.getTodaySeconds();
    top = await statsService.getTopSurahs();
    daily = await statsService.getDailyStats();
    name = await statsService.getUserName();
    goal = await loadGoal();

    setState(() {
      loading = false;
    });
  }

  // LOCAL GOAL
  Future<int> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('goal') ?? 72000;
  }

  Future<void> saveGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goal', value);
  }

  // ⏱ FORMAT
  String formatHM(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    return "$h h $m min";
  }

  // MONTH DATA
  List<double> getMonthlyData() {
    final now = DateTime.now();
    final days = DateTime(now.year, now.month + 1, 0).day;

    List<double> data = List.filled(days, 0);

    daily.forEach((date, value) {
      final d = DateTime.parse(date);
      if (d.month == now.month) {
        data[d.day - 1] = (value / 60); // sec → min
      }
    });

    return data;
  }

  // returns a clean max Y value with a little headroom
  double _getMaxY(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 10;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (max == 0) return 10;
    final step = _getYInterval(data);
    return ((max / step).ceil() * step) + step;
  }

  // picks a clean interval so you get ~4-5 labels max, no floats
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

  List<MapEntry<String, double>> getLast7Days() {
    final now = DateTime.now();
    List<MapEntry<String, double>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split("T")[0];
      final value = (daily[key] ?? 0) / 60; // seconds → minutes
      result.add(MapEntry(key, value.toDouble()));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A84C)),
        ),
      );
    }

    final last7 = getLast7Days();
    final sorted = top.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final progress = goal == 0 ? 0.0 : total / goal;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 HEADER
            Text(
              "Welcome, $name",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Here is your listening journey so far.",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 25),

            // ⏱ TIME CARDS
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Total Time",
                    formatHM(total),
                    Icons.headset_rounded,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    "Today",
                    formatHM(today),
                    Icons.today_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 🎯 GOAL CARD
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildGoalDropdown(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFC9A84C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatHM(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC9A84C),
                        ),
                      ),
                      Text(
                        formatHM(goal),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 📊 BAR CHART
            _buildContainerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Activity (Last 7 Days)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getYInterval(last7),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        maxY: _getMaxY(last7),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: _getYInterval(last7),
                              getTitlesWidget: (value, meta) {
                                if (value != value.roundToDouble() ||
                                    value == 0)
                                  return const SizedBox();
                                return Text(
                                  "${value.toInt()}m",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final now = DateTime.now();
                                final index = value.toInt();
                                if (index < 0 || index >= last7.length)
                                  return const SizedBox();
                                final date = now.subtract(
                                  Duration(days: 6 - index),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${date.day}/${date.month}",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.5),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: last7.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value,
                                width: 16,
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC9A84C),
                                    Color(0xFFE8C96A),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 🎵 TOP SURAHS
            if (sorted.isNotEmpty) ...[
              _buildContainerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Most Played Surahs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...sorted.take(5).map((e) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A84C).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: Color(0xFFC9A84C),
                          ),
                        ),
                        title: Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          "${e.value} plays",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // UI HELPER WIDGETS
  // ==========================================

  // Wrapper card for unified styling (Shadows + Rounded Corners)
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

  // Small Top Stat Cards
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
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Styled Dropdown for Goal selection
  Widget _buildGoalDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: goal,
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
            if (value != null) {
              goal = value;
              await saveGoal(value);
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
