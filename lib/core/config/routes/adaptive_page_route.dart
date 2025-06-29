import 'dart:io'; // Import dart:io to check the platform
import 'package:flutter/cupertino.dart';

import '../../../app/app_locale/app_locale.dart'; // Import Cupertino widgets
// Import Material widgets

class AdaptivePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  final RouteSettings? routeSetting;

  AdaptivePageRoute({required this.builder, this.routeSetting})
    : super(
        settings: routeSetting,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final bool value = isArabic(context);
          // Define the begin and end offsets based on the value
          Offset begin, end;
          if (value) {
            begin = const Offset(-1.0, 0.0); // Slide from right to left
            end = Offset.zero;
          } else {
            begin = const Offset(1.0, 0.0); // Slide from left to right
            end = Offset.zero;
          }
          const curve = Curves.fastEaseInToSlowEaseOut;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(
            context,
          ); // Use the builder function to build the widget
        },
      );
}

PageRoute<dynamic> getPageRoute({
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute(builder: builder, settings: settings);
  } else {
    return AdaptivePageRoute(builder: builder, routeSetting: settings);
  }
}
