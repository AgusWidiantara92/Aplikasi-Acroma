import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/router_metric.dart';
import '../utils/theme.dart';

enum ChartType { cpu, ram, traffic }

class MetricChart extends StatelessWidget {
  final List<RouterMetric> history;
  final ChartType type;

  const MetricChart({
    Key? key,
    required this.history,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final chartColor = _getChartColor();
    final gradientColors = [
      chartColor,
      chartColor.withOpacity(0.1),
    ];

    return Container(
      height: 185,
      padding: const EdgeInsets.only(right: 18, left: 10, top: 15, bottom: 5),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: type == ChartType.traffic ? 20000 : 25,
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.04),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.04),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: type == ChartType.traffic ? 50000 : 25,
                getTitlesWidget: (value, meta) {
                  String label = '';
                  if (type == ChartType.traffic) {
                    label = '${(value / 1024).toStringAsFixed(0)}M';
                  } else {
                    label = '${value.toInt()}%';
                  }
                  return Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 35,
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (history.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              isCurved: true,
              gradient: LinearGradient(colors: [chartColor, chartColor.withOpacity(0.7)]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChartColor() {
    switch (type) {
      case ChartType.cpu:
        return AppTheme.primary;
      case ChartType.ram:
        return AppTheme.accent;
      case ChartType.traffic:
        return AppTheme.success;
    }
  }

  double _getMaxY() {
    if (type == ChartType.traffic) {
      double maxVal = 10000.0; // 10 Mbps floor
      for (var m in history) {
        if (m.downloadSpeed > maxVal) maxVal = m.downloadSpeed;
      }
      return maxVal * 1.15; // 15% headroom
    }
    return 100.0; // cpu and ram scale percentage
  }

  List<FlSpot> _getSpots() {
    List<FlSpot> list = [];
    for (int i = 0; i < history.length; i++) {
      double val = 0.0;
      switch (type) {
        case ChartType.cpu:
          val = history[i].cpuUsage;
          break;
        case ChartType.ram:
          val = history[i].ramUsage;
          break;
        case ChartType.traffic:
          val = history[i].downloadSpeed;
          break;
      }
      list.add(FlSpot(i.toDouble(), val));
    }
    return list;
  }
}
