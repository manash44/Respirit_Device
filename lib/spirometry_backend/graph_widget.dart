import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class GraphWidget extends StatelessWidget {
  final String title;
  final String xLabel;
  final String yLabel;
  final List<FlSpot> dataPoints;

  GraphWidget({
    required this.title,
    required this.xLabel,
    required this.yLabel,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    double minX = 0, maxX = 1, minY = -1, maxY = 1;
    if (dataPoints.isNotEmpty) {
      minX = dataPoints.map((e) => e.x).reduce(min);
      maxX = dataPoints.map((e) => e.x).reduce(max);
      // For Y axis, always include 0 and make symmetric
      double actualMinY = dataPoints.map((e) => e.y).reduce(min);
      double actualMaxY = dataPoints.map((e) => e.y).reduce(max);
      double absMaxY = max(actualMaxY.abs(), actualMinY.abs());
      minY = -absMaxY;
      maxY = absMaxY;
      // Expand to include zero for axes
      minX = min(minX, 0);
      maxX = max(maxX, 0);
    }

    // Split expiration (y >= 0) and inspiration (y < 0)
    final expiration = dataPoints.where((e) => e.y >= 0).toList();
    final inspiration = dataPoints.where((e) => e.y < 0).toList();

    // Find PEF (max y) and PIF (min y)
    FlSpot? pefSpot;
    FlSpot? pifSpot;
    if (dataPoints.isNotEmpty) {
      pefSpot = dataPoints.reduce((a, b) => a.y > b.y ? a : b);
      pifSpot = dataPoints.reduce((a, b) => a.y < b.y ? a : b);
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 300, // Fixed height for the graph
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      if (expiration.isNotEmpty)
                        LineChartBarData(
                          spots: expiration,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      if (inspiration.isNotEmpty)
                        LineChartBarData(
                          spots: inspiration,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                    ],
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        if (value == 0) {
                          return FlLine(
                            color: Colors.black,
                            strokeWidth: 1,
                          );
                        }
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        if (value == 0) {
                          return FlLine(
                            color: Colors.black,
                            strokeWidth: 1,
                          );
                        }
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    showingTooltipIndicators: [],
                  ),
                ),
              ),
              if (pefSpot != null)
                Text(
                    'PEF: (${pefSpot.x.toStringAsFixed(2)}, ${pefSpot.y.toStringAsFixed(2)})',
                    style: TextStyle(fontSize: 12, color: Colors.blue)),
              if (pifSpot != null)
                Text(
                    'PIF: (${pifSpot.x.toStringAsFixed(2)}, ${pifSpot.y.toStringAsFixed(2)})',
                    style: TextStyle(fontSize: 12, color: Colors.green)),
              Text('$xLabel vs $yLabel'),
            ],
          ),
        ),
      ),
    );
  }
}
 