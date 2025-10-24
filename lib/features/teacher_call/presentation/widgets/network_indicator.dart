import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import '../../../../../core/utilities/services/call_service.dart';

class NetworkQualityIndicator extends StatelessWidget {
  final CallQuality quality;
  final double size;
  final Color? color;

  const NetworkQualityIndicator({
    super.key,
    required this.quality,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? _getQualityColor();

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WifiSignalPainter(
          quality: quality,
          color: indicatorColor,
        ),
      ),
    );
  }

  Color _getQualityColor() {
    switch (quality) {
      case CallQuality.excellent:
        return AppColors.coolGreen;
      case CallQuality.good:
        return Colors.orange;
      case CallQuality.poor:
        return Colors.red;
    }
  }
}

class _WifiSignalPainter extends CustomPainter {
  final CallQuality quality;
  final Color color;

  _WifiSignalPainter({
    required this.quality,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height * 0.8);
    final maxRadius = size.width * 0.5;

    // النقطة في المنتصف (دايماً مرسومة)
    canvas.drawCircle(
      center,
      size.width * 0.08,
      paint,
    );

    // عدد الأقواس بناءً على الجودة
    final arcCount = quality == CallQuality.excellent
        ? 3
        : quality == CallQuality.good
        ? 2
        : 1;

    // رسم الأقواس
    for (int i = 0; i < arcCount; i++) {
      final arcPaint = Paint()
        ..color = color.withValues(alpha: 0.9 - (i * 0.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.12
        ..strokeCap = StrokeCap.round;

      final radius = maxRadius * (i + 1) / 3;
      final sweepAngle = 1.8; // زاوية القوس

      final rect = Rect.fromCircle(center: center, radius: radius);

      canvas.drawArc(
        rect,
        -2.5, // زاوية البداية
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WifiSignalPainter oldDelegate) {
    return oldDelegate.quality != quality || oldDelegate.color != color;
  }
}

// Widget مع Animation للتغييرات
class AnimatedNetworkQualityIndicator extends StatefulWidget {
  final CallQuality quality;
  final double size;
  final Color? color;

  const AnimatedNetworkQualityIndicator({
    super.key,
    required this.quality,
    this.size = 24,
    this.color,
  });

  @override
  State<AnimatedNetworkQualityIndicator> createState() =>
      _AnimatedNetworkQualityIndicatorState();
}

class _AnimatedNetworkQualityIndicatorState
    extends State<AnimatedNetworkQualityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedNetworkQualityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quality != widget.quality) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: NetworkQualityIndicator(
        quality: widget.quality,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}