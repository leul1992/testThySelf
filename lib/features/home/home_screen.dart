import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:test_thy_self/core/constants/routes.dart';
import 'package:test_thy_self/core/services/streak_service.dart';
import 'package:test_thy_self/core/widgets/arc_menu.dart';
import 'package:test_thy_self/core/widgets/success_animation.dart';
import 'package:test_thy_self/data/repositories/service_locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StreakService _streakService;
  int _currentStreak = 0;
  DateTime _startDate = DateTime.now();
  bool _isLoading = true;
  final GlobalKey _refreshIndicatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _streakService = ServiceLocator.instance.streakService;
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    setState(() => _isLoading = true);
    _currentStreak = await _streakService.getCurrentStreakDays();
    _startDate = await _streakService.getCurrentStreakStartDate();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadStreakData,
        displacement: 80,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Background elements
                  _buildBackgroundElements(context),

                  // Main content
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          _buildStreakDisplay(context),
                          const SizedBox(height: 40),
                          _buildMotivationalMessage(context),
                          const SizedBox(height: 60),
                          _buildActionSelector(context),
                          const SizedBox(height: 40),
                          _buildStreakDetails(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'STREAK',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDisplay(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 8,
                ),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  width: 8,
                ),
              ),
            ),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  '$_currentStreak',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2000.ms)
                    .scaleXY(begin: 1, end: 1.05, duration: 1000.ms),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'day${_currentStreak == 1 ? '' : 's'} streak',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w300,
              ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(BuildContext context) {
    final messages = [
      if (_currentStreak == 0) 'Every journey begins with a single step!',
      if (_currentStreak > 0 && _currentStreak < 3)
        'Great start! Keep it going!',
      if (_currentStreak >= 3 && _currentStreak < 7)
        'You\'re building momentum!',
      if (_currentStreak >= 7 && _currentStreak < 14)
        'One week strong! Impressive!',
      if (_currentStreak >= 14 && _currentStreak < 30)
        'Two weeks! You\'re crushing it!',
      if (_currentStreak >= 30) 'Amazing discipline! Keep the streak alive!',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        messages.first,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildActionSelector(BuildContext context) {
    return Column(
      children: [
        Text(
          'How did you do today?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success option
            GestureDetector(
              onTap: _logSuccess,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.green.withOpacity(0.3),
                      Colors.green.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 40,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Success',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.green[700],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 40),
            // Failure option
            GestureDetector(
              onTap: _logFailure,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel,
                      size: 40,
                      color: Colors.red[700],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failure',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.red[700],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Streak Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.calendar_today,
            label: 'Started on',
            value: _formatDate(_startDate),
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            icon: Icons.timeline,
            label: 'Best streak',
            value:
                '$_currentStreak days', // Replace with actual best streak if available
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Future<void> _logSuccess() async {
    await _streakService.logSuccess();
    await _loadStreakData();
    _showSuccessAnimation();
  }

  Future<void> _logFailure() async {
    await _streakService.logFailure();
    await _loadStreakData();
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: SuccessAnimation(),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    ).then((_) => Navigator.of(context).pop());
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCurvedMenuItem(
      BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
