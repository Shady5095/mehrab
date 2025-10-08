import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/authentication/manager/login_screen_cubit/login_screen_cubit.dart';
import 'package:mehrab/features/authentication/manager/login_screen_cubit/login_screen_state.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/widgets/height_sized_box.dart';
import 'login_text_form_and_button.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeightSizedBox(height: 2),
                  Center(
                    child: Image(
                      image: AssetImage(AppAssets.appLogo),
                      width: 40.wR,
                      height: 40.wR,
                    ),
                  ),
                  HeightSizedBox(height: 2),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppStrings.welcomeText.tr(context),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      AppStrings.welcomeTextDescription.tr(context),
                      style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                    ),
                  ),
                  HeightSizedBox(height: 2),
                  LoginTextFormAndButton(),
                  if(Platform.isIOS)
                  ...[
                    HeightSizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              context.navigateTo(pageName: AppRoutes.prayerTimesScreen);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // Glass effect with main color
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 7.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.prayerTimes.tr(context),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(width: 7),
                                    Image.asset(
                                      'assets/images/pray.png',
                                      width: 25.sp,
                                      height:25.sp,
                                      color: AppColors.coolGreen,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback if asset image fails to load
                                        return Icon(
                                          Icons.error,
                                          size: 30.sp,
                                          color: AppColors.coolGreen,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              context.navigateTo(pageName: AppRoutes.quranWebView);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // Glass effect with main color
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 7.0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.quran.tr(context),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(width: 7),
                                    Image.asset(
                                      'assets/images/book.png',
                                      width: 25.sp,
                                      height: 25.sp,
                                      color: AppColors.purple,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback if asset image fails to load
                                        return Icon(
                                          Icons.error,
                                          size: 30.sp,
                                          color: AppColors.coolGreen,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            BlocBuilder<LoginCubit, LoginStates>(
              builder: (context, state) {
                if (state is! BiometricsLoginLoadingState) {
                  return SizedBox.shrink();
                }
                return Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
