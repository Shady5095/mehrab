import 'package:flutter/material.dart';

import '../utilities/resources/colors.dart';
import '../utilities/resources/styles.dart';

class AppShapeNumber extends StatelessWidget {
  const AppShapeNumber({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 23,
      height: 28,
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsetsDirectional.only(end: 3, bottom: 3),
      decoration: const BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(60),
          topStart: Radius.circular(10),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          (index + 1).toString(),
          style: AppStyle.textStyle10White.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
