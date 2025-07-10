import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class ArcMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String routeName;

  ArcMenuItem(this.icon, this.label, this.color, this.routeName);
}

class ArcMenu extends StatefulWidget {
  final List<ArcMenuItem> arcIcons;
  final Color arcColor;
  final Function(String)? onItemSelected;

  const ArcMenu({
    super.key,
    required this.arcIcons,
    required this.arcColor,
    this.onItemSelected,
  });

  @override
  State<ArcMenu> createState() => _ArcMenuState();
}

class _ArcMenuState extends State<ArcMenu> with TickerProviderStateMixin {
  bool _showArc = false;
  bool _gestureAllowed = false;
  final double arcSize = 320;
  double angleOffset = 0.0;

  late AnimationController _controller;
  late AnimationController _blinkController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _sweepController;
  late Animation<double> _sweepAnimation;
  late Animation<double> _indicatorScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _sweepController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _sweepAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.easeInOut),
    );

    _indicatorScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _showArc = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _blinkController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  void _toggleArc(bool show) {
    if (show) {
      setState(() => _showArc = true);
      _sweepController.forward(from: 0);
      _controller.forward(from: 0);
    } else {
      _sweepController.reverse();
      _controller.reverse();
    }
  }

  void _onPanStart(DragStartDetails details) {
    final Offset position = details.globalPosition;
    // Define a smaller gesture area around the slide indicator (e.g., 100x100 box)
    const gestureAreaSize = 100.0;
    final gestureArea = Rect.fromLTWH(
      MediaQuery.of(context).size.width - gestureAreaSize,
      0,
      gestureAreaSize,
      gestureAreaSize,
    );

    _gestureAllowed = gestureArea.contains(position);
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = details.velocity.pixelsPerSecond.dx;

    if (_gestureAllowed && dx < -100 && !_showArc) {
      _toggleArc(true);
    } else if (dx > 100 && _showArc) {
      _toggleArc(false);
    }

    _gestureAllowed = false;
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_showArc) return;

    final Offset tap = details.globalPosition;
    final Offset arcPosition = Offset(
      MediaQuery.of(context).size.width - arcSize / 2,
      arcSize / 2,
    );

    final double distance = (tap - arcPosition).distance;
    if (distance > arcSize / 2) {
      _toggleArc(false);
    }
  }

  List<Widget> _buildArcIcons() {
    final double radius = arcSize / 2 - 40;
    final int visibleCount = max(3, (arcSize ~/ 60));
    final int itemCount = widget.arcIcons.length;
    const double arcVisualRotation = pi / 22;
    const double minAllowedAngle = -pi / 12;
    const double maxAllowedAngle = pi + pi / 12;

    final double totalAngleRange = maxAllowedAngle - minAllowedAngle;
    final int spacingFactor =
        itemCount < visibleCount ? itemCount : visibleCount;

    return List.generate(itemCount, (index) {
      double angle;
      if (itemCount < visibleCount) {
        final double angleStep = totalAngleRange / (itemCount + 1);
        angle = minAllowedAngle + (index + 1) * angleStep - arcVisualRotation;
      } else {
        angle = pi * (index - angleOffset) / spacingFactor + arcVisualRotation;
      }

      if (angle < minAllowedAngle || angle > maxAllowedAngle) {
        return const SizedBox.shrink();
      }

      final double x = radius * cos(angle);
      final double y = radius * sin(angle);

      return Positioned(
        left: arcSize / 2 + x - 20,
        top: arcSize / 2 + y - 20,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () {
                widget.onItemSelected?.call(widget.arcIcons[index].routeName);
                _toggleArc(false);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: widget.arcIcons[index].color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  widget.arcIcons[index].icon,
                  size: 28,
                  color: widget.arcIcons[index].color,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const gestureAreaSize = 100.0; // Size of the gesture area around the indicator
    return Stack(
      children: [
        // Gesture area for swipe-to-open (only when arc is closed)
        if (!_showArc)
          Positioned(
            top: 0,
            right: 0,
            width: gestureAreaSize,
            height: gestureAreaSize,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanEnd: _onPanEnd,
              // Allow touches to pass through to underlying widgets
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        // Full-screen gesture detector when arc is open
        if (_showArc)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanEnd: _onPanEnd,
              onTapUp: _handleTapUp,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        // Arc menu
        if (_showArc)
          Positioned(
            top: -50,
            right: -50,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(arcSize / 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: arcSize,
                      height: arcSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(arcSize / 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: 45 * pi / 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(arcSize, arcSize),
                              painter: GlassmorphicArcPainter(
                                sweepAngle: _sweepAnimation.value,
                                arcColor: widget.arcColor,
                                arcIcons: widget.arcIcons,
                                angleOffset: angleOffset,
                              ),
                            ),
                            ..._buildArcIcons(),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: arcSize,
                                height: arcSize,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    setState(() {
                                      angleOffset += details.delta.dx * 0.02;
                                      final int visibleCount =
                                          max(3, (arcSize ~/ 60));
                                      final double maxOffset = max(
                                              0.0,
                                              widget.arcIcons.length -
                                                  visibleCount)
                                          .toDouble();
                                      angleOffset =
                                          angleOffset.clamp(0.0, maxOffset);
                                    });
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              right: 130,
                              child: GestureDetector(
                                onTap: () => _toggleArc(false),
                                child: Transform.rotate(
                                  angle: -45 * pi / 180,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          widget.arcColor.withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(Icons.close,
                                        color: Colors.red, size: 30),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Slide indicator
        if (!_showArc)
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _blinkController,
              builder: (context, child) {
                final double dx = sin(_blinkController.value * 2 * pi) * 10;
                final double opacity =
                    0.5 + 0.5 * sin(_blinkController.value * 2 * pi);
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(dx, 0),
                    child: ScaleTransition(
                      scale: _indicatorScaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.arcColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.swipe_left,
                            size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
class GlassmorphicArcPainter extends CustomPainter {
  final double sweepAngle;
  final Color arcColor;
  final List<ArcMenuItem> arcIcons;
  final double angleOffset;

  GlassmorphicArcPainter({
    required this.sweepAngle,
    required this.arcColor,
    required this.arcIcons,
    required this.angleOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final int visibleCount = max(3, (size.width ~/ 60));
    const double arcVisualRotation = pi / 22;
    const double minAllowedAngle = -pi / 12;
    const double maxAllowedAngle = pi + pi / 12;
    final int spacingFactor =
        arcIcons.length < visibleCount ? arcIcons.length : visibleCount;

    List<Color> visibleColors = [];
    for (int index = 0; index < arcIcons.length; index++) {
      double angle;
      if (arcIcons.length < visibleCount) {
        final double totalAngleRange = maxAllowedAngle - minAllowedAngle;
        final double angleStep = totalAngleRange / (arcIcons.length + 1);
        angle = minAllowedAngle + (index + 1) * angleStep - arcVisualRotation;
      } else {
        angle = pi * (index - angleOffset) / spacingFactor + arcVisualRotation;
      }

      if (angle >= minAllowedAngle && angle <= maxAllowedAngle) {
        visibleColors.add(arcIcons[index].color.withOpacity(0.2));
      }
    }

    final gradientColors = visibleColors.isNotEmpty
        ? [arcColor.withOpacity(0.4), ...visibleColors.take(2)]
        : [arcColor.withOpacity(0.4), Colors.white.withOpacity(0.2)];

    final paint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    canvas.drawArc(rect, 0, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant GlassmorphicArcPainter oldDelegate) {
    return sweepAngle != oldDelegate.sweepAngle ||
        arcColor != oldDelegate.arcColor ||
        angleOffset != oldDelegate.angleOffset;
  }
}
