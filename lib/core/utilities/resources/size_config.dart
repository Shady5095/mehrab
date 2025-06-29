import 'package:flutter/cupertino.dart';

abstract class SizeConfig {
  static double width = 600, height = 600;
  static const maxMobileWidth = 600;

  static void init(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      height = MediaQuery.sizeOf(context).width;
      width = MediaQuery.sizeOf(context).height;
    } else {
      height = MediaQuery.sizeOf(context).height;
      width = MediaQuery.sizeOf(context).width;
    }
  }
}
