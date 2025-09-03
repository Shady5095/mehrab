import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/features/authentication/manager/register_screen_cubit/register_cubit.dart';

import '../widgets/register_screen_body.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> args =
    ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    return BlocProvider(
      create: (context) => RegisterCubit(googleSignInModel: args[0])..fillGoogleSignInData(),
      child: Scaffold(
        body: RegisterScreenBody(),
      ),
    );
  }
}
