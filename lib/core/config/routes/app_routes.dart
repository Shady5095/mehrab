import 'package:flutter/material.dart';
import '../../../features/home/presentation/views/home_layout.dart';
import '../../utilities/resources/strings.dart';
import '../../widgets/gradient_scaffold.dart';
import 'adaptive_page_route.dart';

abstract class AppRoutes {
  static const String homeRoute = 'homeRoute';
}

abstract class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeRoute:
        return getPageRoute(
          builder: (BuildContext context) => const HomeLayout(),
        );

        default:
        return noRoute();
    }
  }

  static Route<dynamic> noRoute() {
    return getPageRoute(
      builder:
          (BuildContext context) => const GradientScaffold(
            body: Center(child: Text(AppStrings.noRoute)),
          ),
    );
  }
}

// class MyCustomRoute<T> extends MaterialPageRoute<T> {
//   MyCustomRoute({required super.builder, super.settings});
//
//   @override
//   Widget buildTransitions(BuildContext context,
//       Animation<double> animation,
//       Animation<double> secondaryAnimation,
//       Widget child) {
//
//     const Offset begin = Offset(1.0, 0.0);
//     const Offset end = Offset.zero;
//     const Curve curve = Curves.ease;
//
//     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//
//     return SlideTransition(
//       position: animation.drive(tween),
//       child: child,
//     );
//   }
// }
