import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:test_thy_self/core/services/streak_service.dart';
import 'package:test_thy_self/core/widgets/app_scaffold.dart';
import 'package:test_thy_self/data/models/streak_model.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final StreakService _streakService;
  List<StreakHistory> _streakHistory = [];
  bool _isLoading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _streakService = ServiceLocator.instance.streakService;
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    setState(() => _isLoading = true);
    _streakHistory = await _streakService.getStreakHistory();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Progress History',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildStreakChart(),
                  const SizedBox(height: 24),
                  _buildCalendar(),
                  const SizedBox(height: 24),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStreakChart() {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxY(),
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
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(
      _streakHistory.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _streakHistory[index].days.toDouble(),
            color: Theme.of(context).colorScheme.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    if (_streakHistory.isEmpty) return 10;
    final maxDays = _streakHistory
        .map((streak) => streak.days)
        .reduce((a, b) => a > b ? a : b);
    return (maxDays * 1.2).ceilToDouble();
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now(),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final streak = _streakHistory.firstWhere(
                (s) => date.isAfter(s.startDate.subtract(const Duration(days: 1))) &&
                    date.isBefore(s.endDate.add(const Duration(days: 1))),
                orElse: () => StreakHistory(
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  days: 0,
                ),
              );
              if (streak.days > 0) {
                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Text(
                      streak.days.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_streakHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No streak history yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _streakHistory.length,
      itemBuilder: (context, index) {
        final streak = _streakHistory[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                streak.days.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text('${_formatDate(streak.startDate)} - ${_formatDate(streak.endDate)}'),
            subtitle: Text('${streak.days} day${streak.days == 1 ? '' : 's'}'),
            trailing: const Icon(Icons.timeline),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
