import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_entry.dart';

class AnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSentimentSummary(),
            const SizedBox(height: 20),
            Expanded(child: _buildSentimentChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentSummary() {
    return GetBuilder<DiaryController>(
      builder: (controller) {
        if (controller.entries.isEmpty) {
          return const Text('No entries to analyze');
        }

        final positive = controller.entries.where((e) => e.sentimentScore > 0).length;
        final neutral = controller.entries.where((e) => e.sentimentScore == 0).length;
        final negative = controller.entries.where((e) => e.sentimentScore < 0).length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('😊', positive.toString(), Colors.green),
            _buildSummaryItem('😐', neutral.toString(), Colors.grey),
            _buildSummaryItem('😢', negative.toString(), Colors.red),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(String emoji, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(count, style: TextStyle(fontSize: 18, color: color)),
      ],
    );
  }

  Widget _buildSentimentChart() {
    return GetBuilder<DiaryController>(
      builder: (controller) {
        final entries = List<DiaryEntry>.from(controller.entries)
          ..sort((a, b) => a.date.compareTo(b.date));

        if (entries.isEmpty) {
          return const Center(child: Text('No data to display'));
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() % 7 == 0 && value.toInt() < entries.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM dd').format(entries[value.toInt()].date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString());
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: entries.length > 0 ? (entries.length - 1).toDouble() : 0,
            minY: -5,
            maxY: 5,
            lineBarsData: [
              LineChartBarData(
                spots: entries.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.sentimentScore.toDouble(),
                  );
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        );
      },
    );
  }
}