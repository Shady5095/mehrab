import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/widgets/build_upgrader_dialog.dart';
import '../../../../core/widgets/github_update_helper.dart';
import '../../manager/login_screen_cubit/login_screen_cubit.dart';
import '../widgets/change_language_widget.dart';
import '../widgets/login_view_body.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    if(Platform.isAndroid){
      UpdateHelper.checkForUpdate(context);
    }
    super.initState();
  }

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
