import 'package:flutter/material.dart';
import 'package:test_thy_self/core/constants/routes.dart';
import 'package:test_thy_self/core/widgets/arc_menu.dart'; // Import ArcMenu

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main content (screen)
        child,
        // ArcMenu overlay
        ArcMenu(
          arcColor: Theme.of(context).colorScheme.primary,
          arcIcons: [
            ArcMenuItem(Icons.home, 'Home', Colors.teal, AppRoutes.home),
            ArcMenuItem(Icons.timeline, 'Progress', Colors.orange, AppRoutes.progress),
            ArcMenuItem(Icons.settings, 'Settings', Colors.blue, AppRoutes.settings),
          ],
          onItemSelected: (routeName) {
            if (ModalRoute.of(context)?.settings.name != routeName) {
              Navigator.pushNamed(context, routeName);
            }
          },
        ),
      ],
    );
  }
}