import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../utilities/resources/dimens.dart';
import 'app_animation.dart';

class WaitingList extends StatelessWidget {
  const WaitingList({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding:
            padding ??
            const EdgeInsets.only(
              bottom: AppDimens.screenPadding,
              right: AppDimens.screenPadding / 2,
              left: AppDimens.screenPadding / 2,
            ),
        itemBuilder:
            (BuildContext context, int index) =>
                ListItemAnimation(index: index, child: child),
        itemCount: 10,
      ),
    );
  }
}
