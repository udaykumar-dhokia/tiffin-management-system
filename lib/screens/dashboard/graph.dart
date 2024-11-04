import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiffin/constants/color.dart';

class MonthlyIncomeBarChart extends StatelessWidget {
  final String providerId;
  final Map<String, dynamic> provider;

  MonthlyIncomeBarChart({required this.providerId, required this.provider});

  Future<Map<String, double>> getMonthlyIncome(String providerId) async {
    final firestore = FirebaseFirestore.instance;
    final customerCollection = firestore
        .collection('providers')
        .doc(providerId)
        .collection('Customers');

    final customerDocs = await customerCollection.get();
    Map<String, double> monthlyIncome = {};

    for (var customerDoc in customerDocs.docs) {
      final timePeriodCollection =
      customerDoc.reference.collection('TimePeriod');
      final timePeriodDocs = await timePeriodCollection.get();

      for (var timePeriodDoc in timePeriodDocs.docs) {
        final data = timePeriodDoc.data();
        final date = DateTime.parse(timePeriodDoc.id);
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';

        if (data.containsKey('Lunch')) {
          monthlyIncome[monthKey] =
              (monthlyIncome[monthKey] ?? 0) + data['Lunch'];
        }
        if (data.containsKey('Dinner')) {
          monthlyIncome[monthKey] =
              (monthlyIncome[monthKey] ?? 0) + data['Dinner'];
        }
      }
    }

    return monthlyIncome;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String getMonthName(int month) {
      return monthNames[month - 1];
    }

    return FutureBuilder<Map<String, double>>(
      future: getMonthlyIncome(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: provider["isDarkMode"] ? primaryColor : primaryDark,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final monthlyIncome = snapshot.data!;
        final sortedKeys = monthlyIncome.keys.toList()..sort();
        final List<BarChartGroupData> barGroups = sortedKeys.map((key) {
          final income = monthlyIncome[key]!;
          return BarChartGroupData(
            x: sortedKeys.indexOf(key),
            barRods: [
              BarChartRodData(
                toY: income,
                color: provider["isDarkMode"] ? primaryColor : primaryDark,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: barGroups,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 50,
                          showTitles: true,
                          interval: 500,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: provider["isDarkMode"]
                                    ? white
                                    : darkPrimary,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                        // axisNameWidget: Text(
                        //   'Income',
                        //   style: TextStyle(
                        //     color: provider["isDarkMode"]
                        //         ? white
                        //         : darkPrimary,
                        //     fontSize: 14,
                        //   ),
                        // ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value < 0 || value >= sortedKeys.length) {
                              return Container();
                            }
                            final month = sortedKeys[value.toInt()];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 6,
                              child: Text(
                                month,
                                style: TextStyle(
                                  color: provider["isDarkMode"]
                                      ? white
                                      : darkPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
