import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';
import '../utilities/resources/styles.dart';

class AppFilterIcon extends StatelessWidget {
  const AppFilterIcon({super.key, required this.onTap, this.iconColor, this.icon = Icons.notifications_active_outlined});
final Color ? iconColor;
  final VoidCallback? onTap;
  final IconData icon ;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon:  Icon(icon,color:iconColor ,),
      iconSize: 31.sp,
      color: context.invertedColor,
    );
  }
}

class StackCircularDot extends StatelessWidget {
  const StackCircularDot({super.key, required this.counter, this.dotColor});

  final int counter;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      bottom: 1,
      start: 1,
      child: CircleAvatar(
        radius: 10,
        backgroundColor: dotColor ?? AppColors.redColor,
        child: FittedBox(
          child: Text(
            counter.toString(),
            style: AppStyle.textStyle10White.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp
            ),
          ),
        ),
      ),
    );
  }
}

class AppFilterIconWithCounter extends StatelessWidget {
  const AppFilterIconWithCounter({
    super.key,
    required this.filterCounter,
     this.onTap, this.iconColor,
    this.icon = Icons.notifications_active_outlined
  });
  final Color ? iconColor;
  final int filterCounter;
  final VoidCallback? onTap;
  final IconData icon ;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppFilterIcon(onTap: onTap,iconColor: iconColor,icon : icon),
        if (filterCounter > 0) StackCircularDot(counter: filterCounter),
      ],
    );
  }
}

