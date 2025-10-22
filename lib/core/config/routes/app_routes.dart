import 'package:flutter/material.dart';
import 'package:mehrab/core/widgets/pdf_network_viewer.dart';
import 'package:mehrab/features/authentication/presentation/views/login_screen.dart';
import 'package:mehrab/features/my_profile/presentation/screens/my_profile_screen.dart';
import 'package:mehrab/features/notifications/presentation/screens/notifications_screen.dart';
import '../../../features/authentication/presentation/views/register_screen.dart';
import '../../../features/favorite_students/presentation/screens/favorite_students_screen.dart';
import '../../../features/home/presentation/views/home_layout.dart';
import '../../../features/home/presentation/widgets/quran_web_view_screen.dart';
import '../../../features/my_profile/presentation/screens/change_password_screen.dart';
import '../../../features/my_profile/presentation/screens/change_password_screen_teacher.dart';
import '../../../features/my_profile/presentation/screens/my_profile_screen_teacher.dart';
import '../../../features/notifications/presentation/screens/add_notification_screen.dart';
import '../../../features/onboarding/screens/onboarding_screen.dart';
import '../../../features/onboarding/screens/start_screen.dart';
import '../../../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../../../features/students/presentation/screens/students_profile_screen.dart';
import '../../../features/students/presentation/screens/students_screen.dart';
import '../../../features/teaacher_reviews/presentation/screens/teacher_reviews_screen.dart';
import '../../../features/teacher_call/presentation/screens/rate_session_screen.dart';
import '../../../features/teacher_call/presentation/screens/student_call_screen.dart';
import '../../../features/teacher_call/presentation/screens/teacher_call_screen.dart';
import '../../../features/teachers/presentation/screens/add_teacher_screen.dart';
import '../../../features/teachers/presentation/screens/igaz_padf_screen.dart';
import '../../../features/teachers/presentation/screens/teacher_profile_screen.dart';
import '../../../features/teachers/presentation/screens/teachers_screen.dart';
import '../../utilities/resources/strings.dart';
import '../../widgets/gradient_scaffold.dart';
import 'adaptive_page_route.dart';

abstract class AppRoutes {
  static const String homeLayoutRoute = 'homeRoute';
  static const String loginRoute = 'loginRoute';
  static const String registerRoute = 'registerRoute';
  static const String myProfileRoute = 'myProfileRoute';
  static const String myProfileScreenTeacher = 'myProfileScreenTeacher';
  static const String changePasswordScreen = 'changePasswordScreen';
  static const String changePasswordScreenTeacher = 'changePasswordScreenTeacher';
  static const String addTeachersScreen = 'addTeachersScreen';
  static const String teacherProfileScreen = 'teacherProfileScreen';
  static const String teachersScreen = 'teachersScreen';
  static const String quranWebView = 'quranWebView';
  static const String prayerTimesScreen = 'prayerTimesScreen';
  static const String allStudentsScreen = 'allStudentsScreen';
  static const String studentsProfileScreen = 'studentsProfileScreen';
  static const String notificationsScreen = 'notificationsScreen';
  static const String addNotificationScreen = 'addNotificationScreen';
  static const String favoriteStudentsScreen = 'favoriteStudentsScreen';
  static const String teacherReviewsScreen = 'teacherReviewsScreen';
  static const String studentCallScreen = 'studentCallScreen';
  static const String teacherCallScreen = 'teacherCallScreen';
  static const String rateSessionScreen = 'rateSessionScreen';
  static const String startScreenRoute = 'startScreenRoute';
  static const String onboardingRoute = 'onboardingScreen';
  static const String igazPdfScreen = 'igazPdfScreen';
  static const String pdfNetworkViewer = 'pdfNetworkViewer';

}

abstract class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeLayoutRoute:
        return getPageRoute(
          builder: (BuildContext context) => const HomeLayout(),
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
        case AppRoutes.myProfileScreenTeacher:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const MyProfileScreenTeacher(),
        );
      case AppRoutes.changePasswordScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const ChangePasswordScreen(),
        );
        case AppRoutes.changePasswordScreenTeacher:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const ChangePasswordScreenTeacher(),
        );
      case AppRoutes.addTeachersScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const AddTeacherScreen(),
        );
      case AppRoutes.teacherProfileScreen:
        return PageRouteBuilder(
          settings: settings,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          pageBuilder:
              (context, animation, secondaryAnimation) =>
          const TeacherProfileScreen(),
        );
      case AppRoutes.teachersScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const TeachersScreen(),
        );
      case AppRoutes.quranWebView:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const QuranWebView(),
        );
      case AppRoutes.prayerTimesScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const PrayerTimesScreen(),
        );
      case AppRoutes.allStudentsScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const StudentsScreen(),
        );
        case AppRoutes.studentsProfileScreen:
          return PageRouteBuilder(
            settings: settings,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            pageBuilder:
                (context, animation, secondaryAnimation) =>
            const StudentsProfileScreen(),
          );
      case AppRoutes.notificationsScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const NotificationsScreen(),
        );
        case AppRoutes.addNotificationScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const AddNotificationScreen(),
        );
        case AppRoutes.favoriteStudentsScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const FavoriteStudentsScreen(),
        );
        case AppRoutes.teacherReviewsScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const TeacherReviewsScreen(),
        );
        case AppRoutes.studentCallScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const StudentCallScreen(),
        );
        case AppRoutes.teacherCallScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const TeacherCallScreen(),
        );
        case AppRoutes.rateSessionScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const RateSessionScreen(),
        );
        case AppRoutes.startScreenRoute:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const StartScreen(),
        );
        case AppRoutes.onboardingRoute:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const OnboardingScreen(),
        );
        case AppRoutes.igazPdfScreen:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => const IgazPdfScreen(),
        );
        case AppRoutes.pdfNetworkViewer:
        return getPageRoute(
          settings: settings,
          builder: (BuildContext context) => PdfNetworkViewer(pdfUrl: settings.arguments as String),
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
