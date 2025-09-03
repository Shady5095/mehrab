import 'package:flutter/material.dart';
import 'package:mehrab/features/authentication/presentation/views/login_screen.dart';
import 'package:mehrab/features/my_profile/presentation/screens/my_profile_screen.dart';
import '../../../features/authentication/presentation/views/register_screen.dart';
import '../../../features/home/presentation/views/home_layout.dart';
import '../../../features/my_profile/presentation/screens/change_password_screen.dart';
import '../../utilities/resources/strings.dart';
import '../../widgets/gradient_scaffold.dart';
import 'adaptive_page_route.dart';

abstract class AppRoutes {
  static const String studentHomeLayoutRoute = 'homeRoute';
  static const String loginRoute = 'loginRoute';
  static const String registerRoute = 'registerRoute';
  static const String myProfileRoute = 'myProfileRoute';
  static const String changePasswordScreen = 'changePasswordScreen';
}

abstract class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.studentHomeLayoutRoute:
        return getPageRoute(
          builder: (BuildContext context) => const StudentHomeLayout(),
        );
      case AppRoutes.loginRoute:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const LoginScreen(),
        );
      case AppRoutes.registerRoute:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const RegisterScreen(),
        );
      case AppRoutes.myProfileRoute:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const MyProfileScreen(),
        );
      case AppRoutes.changePasswordScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const ChangePasswordScreen(),
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
