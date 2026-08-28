import 'package:flutter/material.dart';

/// A circular progress ring with a percentage label centered inside —
/// used for goal completion, matching the ring-chart pattern common
/// across fitness app UI (vs. a flat linear bar).
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0, already clamped by the caller
  final Color color;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 64,
    this.strokeWidth = 7,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
