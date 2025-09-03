import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utilities/functions/exit_app_dialog.dart';
import '../manager/home_cubit/home_cubit.dart';
import 'home_layout_body.dart';

class StudentHomeLayout extends StatelessWidget {
  const StudentHomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  HomeCubit()..getUserData()..setupFirebase(context)
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => checkToExit(didPop, context),

        child: const HomeLayoutBody(),
      ),
    );
  }
}
