import 'dart:math';
import 'package:flutter/material.dart';

class DonutChart extends StatefulWidget {
  final double protein;
  final double carbs;
  final double fat;

  const DonutChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.protein != widget.protein ||
        oldWidget.carbs != widget.carbs ||
        oldWidget.fat != widget.fat) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _DonutChartPainter(
            protein: widget.protein,
            carbs: widget.carbs,
            fat: widget.fat,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double protein;
  final double carbs;
  final double fat;
  final double progress;

  _DonutChartPainter({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final total = protein + carbs + fat;
    if (total == 0) {
      // Draw background ring only if data is empty
      final emptyPaint = Paint()
        ..color = const Color(0xffe2e8f0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, emptyPaint);
      return;
    }

    final proteinAngle = (protein / total) * 2 * pi * progress;
    final carbsAngle = (carbs / total) * 2 * pi * progress;
    final fatAngle = (fat / total) * 2 * pi * progress;

    // Define premium palette matching visual designs
    final proteinPaint = Paint()
      ..color = const Color(0xff2ecc71) // Emerald green (#2ECC71)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final carbsPaint = Paint()
      ..color = const Color(0xff3498db) // Vibrant blue (#3498DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final fatPaint = Paint()
      ..color = const Color(0xfff1c40f) // Golden yellow (#F1C40F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = const Color(0xfff1f5f9) // Sleek slate grey track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    // 1. Draw background track
    canvas.drawCircle(center, radius, backgroundPaint);

    // 2. Draw arcs with distinct premium spacing gaps (0.08 radians ~ 4.5 degrees)
    const gap = 0.08;
    double startAngle = -pi / 2; // Start top center (12 o'clock)

    if (proteinAngle > gap) {
      canvas.drawArc(rect, startAngle + gap / 2, proteinAngle - gap, false,
          proteinPaint);
    }
    startAngle += proteinAngle;

    if (carbsAngle > gap) {
      canvas.drawArc(rect, startAngle + gap / 2, carbsAngle - gap, false,
          carbsPaint);
    }
    startAngle += carbsAngle;

    if (fatAngle > gap) {
      canvas.drawArc(rect, startAngle + gap / 2, fatAngle - gap, false,
          fatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.protein != protein ||
        oldDelegate.carbs != carbs ||
        oldDelegate.fat != fat ||
        oldDelegate.progress != progress;
  }
}
