import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuccessAnimation extends StatelessWidget {
  const SuccessAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(
          Icons.celebration,
          size: 100,
          color: Colors.amber,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shake(duration: 1000.ms)
            .scaleXY(begin: 1, end: 1.5, duration: 1000.ms),
        Positioned(
          bottom: 0,
          child: Text(
            'Success!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.5, end: 0),
        ),
      ],
    );
  }
}
