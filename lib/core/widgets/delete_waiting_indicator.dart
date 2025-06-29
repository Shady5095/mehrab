import 'package:flutter/material.dart';

import '../utilities/resources/colors.dart';

class LinearWaitingIndicator extends StatelessWidget {
  const LinearWaitingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 5,
      child: LinearProgressIndicator(
        backgroundColor: AppColors.accentColor.withValues(alpha: 0.4),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentColor),
      ),
    );
  }
}
