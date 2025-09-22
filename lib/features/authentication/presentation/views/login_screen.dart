import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/widgets/build_upgrader_dialog.dart';
import '../../manager/login_screen_cubit/login_screen_cubit.dart';
import '../widgets/change_language_widget.dart';
import '../widgets/login_view_body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BuildUpgradeAlert(
      child: BlocProvider(
        create: (context) => LoginCubit(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: LoginViewBody(),
          bottomNavigationBar: ChangeLanguageWidget(),
        ),
      ),
    );
  }
}
