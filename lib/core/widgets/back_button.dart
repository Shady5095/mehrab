import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../app/main_app_cubit/main_app_cubit.dart';
import '../../app/main_app_cubit/main_app_state.dart';
import '../utilities/functions/is_dark_mode.dart';
import '../utilities/resources/colors.dart';

class MyBackButton extends StatelessWidget {
  final bool isExitButton;

  final VoidCallback? onTap;

  final double? height;
  final double? width;

  const MyBackButton({
    super.key,
    this.isExitButton = false,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isDarkMode(context)) {
      return MyBackButtonDarkMode(
        onTap: onTap,
        height: height,
        width: width,
        isExitButton: isExitButton,
      );
    }
    return MyBackButtonLightMode(
      onTap: onTap,
      height: height,
      width: width,
      isExitButton: isExitButton,
    );
  }
}

class MyBackButtonLightMode extends StatelessWidget {
  const MyBackButtonLightMode({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.isExitButton,
  });

  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool? isExitButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const CircleBorder(),
      elevation: 3,
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              Feedback.forTap(context);
              context.pop();
            },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: height ?? 38.sp,
              height: width ?? 38.sp,
              decoration: BoxDecoration(
                color: AppColors.duckEggBlue.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: BlocBuilder<MainAppCubit, MainAppStates>(
                builder: (context, state) {
                  return Icon(
                    isExitButton == true
                        ? Icons.close
                        : MainAppCubit.instance(context).changeArrow(),
                    size: 25.sp,
                    color: Colors.black,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyBackButtonDarkMode extends StatelessWidget {
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool isExitButton;

  const MyBackButtonDarkMode({
    super.key,
    this.onTap,
    this.height,
    this.width,
    this.isExitButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(50),
      onTap:
          onTap ??
          () {
            context.pop();
          },
      child: Container(
        padding: const EdgeInsets.all(7),
        margin: const EdgeInsetsDirectional.symmetric(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.withValues(alpha: 0.8),
              Colors.blueGrey.withValues(alpha: 0.5),
              Colors.blueGrey.withValues(alpha: 0.3),
              Colors.blueGrey.withValues(alpha: 0.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isExitButton ? Icons.close : Icons.arrow_back_ios_sharp,
          size: 22.sp,
          color: Colors.white60,
        ),
      ),
    );
  }
}
