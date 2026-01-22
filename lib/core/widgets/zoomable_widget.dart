import 'package:flutter/material.dart';

class ZoomableWidget extends StatefulWidget {
  const ZoomableWidget({super.key, required this.child});

  final Widget child;

  @override
  State<ZoomableWidget> createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformationController;
  late final AnimationController _animationController;
  TapDownDetails? _doubleTapDetails;
  Animation<Matrix4>? _animation;

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    Matrix4 targetMatrix;

    if (scale > 1.1) {
      // Reset zoom with animation
      targetMatrix = Matrix4.identity();
    } else {
      // Zoom in around tapped point with animation
      final position = _doubleTapDetails!.localPosition;
      targetMatrix = Matrix4.identity()
        // ignore: deprecated_member_use
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        // ignore: deprecated_member_use
        ..scale(2.5);
    }

    // Create animation from current matrix to target matrix
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.forward(from: 0);
  }

  void _onAnimationUpdate() {
    if (_animation != null) {
      _transformationController.value = _animation!.value;
    }
  }

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Animation duration
      vsync: this,
    )..addListener(_onAnimationUpdate);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: widget.child,
      ),
    );
  }
}
