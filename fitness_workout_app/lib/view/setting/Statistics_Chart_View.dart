import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsChartView extends StatefulWidget {
  const StatisticsChartView({super.key});

  @override
  State<StatisticsChartView> createState() => _StatisticsChartViewState();
}

class _StatisticsChartViewState extends State<StatisticsChartView> {
  String _selectedView = "Month"; // Chế độ mặc định: Xem theo tháng

  Future<Map<String, double>> fetchCaloriesData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('WorkoutHistory')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    final Map<String, double> caloriesData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.fromMillisecondsSinceEpoch(
        data['completedAt'].seconds * 1000,
      );
      final calories = data['caloriesBurned'] as int;

      if (_selectedView == "Month") {
        final monthKey = DateFormat('yyyy-MM').format(date);
        caloriesData[monthKey] = (caloriesData[monthKey] ?? 0) + calories.toDouble();
      } else {
        final yearKey = DateFormat('yyyy').format(date);
        caloriesData[yearKey] = (caloriesData[yearKey] ?? 0) + calories.toDouble();
      }
    }

    return caloriesData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calories Burned Chart",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Dropdown chọn chế độ xem
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "View by:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedView,
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(value: "Month", child: Text("Month")),
                      DropdownMenuItem(value: "Year", child: Text("Year")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedView = value!;
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: fetchCaloriesData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text("Error loading data"));
                  }

                  final caloriesData = snapshot.data!;
                  final barGroups = caloriesData.entries.map((entry) {
                    final key = entry.key;
                    final calories = entry.value;
                    return BarChartGroupData(
                      x: int.parse(key.split('-').last),
                      barRods: [
                        BarChartRodData(
                          toY: calories,
                          color: Colors.orange,
                          width: 15,
                        ),
                      ],
                    );
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 200,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()} KCal',
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      _selectedView == "Month"
                                          ? 'Tháng ${value.toInt()}'
                                          : '${value.toInt()}',
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              border: Border.all(color: Colors.grey),
                            ),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 200,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
