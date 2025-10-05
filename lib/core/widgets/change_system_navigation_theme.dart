import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/main_app_cubit/main_app_cubit.dart';

class ChangeSystemNavigationBarTheme extends StatelessWidget {
  const ChangeSystemNavigationBarTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: MainAppCubit.instance(
          context,
        ).systemNavBarColor(context),
      ),
      child: child,
    );
  }
}
