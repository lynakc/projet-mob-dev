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

  //  LOCAL GOAL
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
    // round up to next multiple of a clean step
    final step = _getYInterval(data);
    return ((max / step).ceil() * step) + step;
  }

// picks a clean interval so you get ~4-5 labels max, no floats
  double _getYInterval(List<MapEntry<String, double>> data) {
    if (data.isEmpty) return 5;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (max <= 5)  return 1;
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    //final monthlyData = getMonthlyData();
    final last7 = getLast7Days();

    final sorted = top.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final progress = goal == 0 ? 0.0 : total / goal;


    return Scaffold(
      appBar: AppBar(title: const Text("Your Stats")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Text(
              " Welcome $name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ⏱ TIME
            Text("Total Listening: ${formatHM(total)}"),
            Text("Today: ${formatHM(today)}"),

            const SizedBox(height: 25),

            //  GOAL (ABOVE GRAPH)
            const Text(
              "Monthly Goal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            LinearProgressIndicator(value: progress.clamp(0, 1)),

            const SizedBox(height: 5),

            Text("${formatHM(total)} / ${formatHM(goal)}"),

            DropdownButton<int>(
              value: goal,
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

            const SizedBox(height: 25),

            //  BAR CHART (LAST 7 DAYS)
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),

                  //  FIX: set max to nearest clean number + small padding
                  maxY: _getMaxY(last7),

                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    //  FIX: Y axis — only show whole numbers, skip floats
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        //  interval based on actual data range — no more 4.9999
                        interval: _getYInterval(last7),
                        getTitlesWidget: (value, meta) {
                          // only show if it's a clean whole number
                          if (value != value.roundToDouble()) return const SizedBox();
                          if (value == 0) return const SizedBox(); // hide zero label
                          return Text(
                            "${value.toInt()}m",
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),

                    // bottom dates
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final now = DateTime.now();
                          final index = value.toInt();
                          if (index < 0 || index >= last7.length) return const SizedBox();
                          final date = now.subtract(Duration(days: 6 - index));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${date.month}/${date.day}",
                              style: const TextStyle(fontSize: 10),
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
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                          // nice gradient on bars
                          gradient: LinearGradient(
                            colors: [Color(0xFFC9A84C), Color(0xFFE8C96A)],
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
            const SizedBox(height: 30),

            // 🎵 TOP SURAHS
            const Text(
              "Top Surahs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...sorted.take(5).map((e) => ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(e.key),
              trailing: Text("${e.value} plays"),
            )),
          ],
        ),
      ),
    );
  }
}