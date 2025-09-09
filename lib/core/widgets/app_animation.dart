import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ColumnWithAnimation extends StatelessWidget {
  const ColumnWithAnimation({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          childAnimationBuilder:
              (widget) => SlideAnimation(
                duration: const Duration(milliseconds: 300),
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
          children: children,
        ),
      ),
    );
  }
}

class ListItemAnimation extends StatelessWidget {
  const ListItemAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: index,
      child: SlideAnimation(
        horizontalOffset: 50.0,
        duration: const Duration(milliseconds: 500),
        child: FadeInAnimation(child: child),
      ),
    );
  }
}

class TestAnimation extends StatefulWidget {
  const TestAnimation({super.key, required this.child});

  final Widget child;

  @override
  State<TestAnimation> createState() => _TestAnimationState();
}

class _TestAnimationState extends State<TestAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<Offset> slidingAnimation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    slidingAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(controller);
    controller.reset();
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: slidingAnimation, child: widget.child);
  }
}
