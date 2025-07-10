import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

BarChartData barChartTheme(
  BuildContext context,
  List<BarChartGroupData> barGroups,
  double maxY,
) {
  return BarChartData(
    alignment: BarChartAlignment.spaceAround,
    maxY: maxY,
    barTouchData: BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Theme.of(context).colorScheme.surfaceVariant,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${rod.toY.toInt()} days',
            TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Streak ${value.toInt() + 1}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            );
          },
          reservedSize: 40,
        ),
      ),
      rightTitles: AxisTitles(),
      topTitles: AxisTitles(),
    ),
    gridData: FlGridData(show: false),
    borderData: FlBorderData(show: false),
    barGroups: barGroups,
  );
}
