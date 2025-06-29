import 'package:flutter/cupertino.dart';

import '../utilities/functions/is_dark_mode.dart';
import '../utilities/resources/colors.dart';

Gradient backgroundGradient(BuildContext context) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors:
        isDarkMode(context)
            ? AppColors.backgroundGradientDark
            : [AppColors.white, AppColors.white],
  );
}
