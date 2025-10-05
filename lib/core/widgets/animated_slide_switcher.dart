import 'package:flutter/material.dart';

class AnimatedSlideSwitcher extends StatelessWidget {
  final bool isShowFirstChild;
  final Widget firstChild;
  final Widget? secondChild;
  final Duration duration;

  /// A reusable widget that switches between children with an animated transition.
  const AnimatedSlideSwitcher({
    super.key,
    required this.isShowFirstChild,
    required this.firstChild,
    this.secondChild,
    this.duration = const Duration(milliseconds: 250),
    // Slide from top to bottom
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: _buildTransition,
      child: _getCurrentChild(),
    );
  }

  /// Returns the currently visible child with a unique key.
  Widget _getCurrentChild() {
    return KeyedSubtree(
      key: ValueKey(isShowFirstChild),
      child:
          isShowFirstChild
              ? firstChild
              : (secondChild ?? const SizedBox.shrink()),
    );
  }

  /// Builds the transition effect for incoming and outgoing widgets.
  Widget _buildTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(sizeFactor: animation, child: child),
    );
  }
}
