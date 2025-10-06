import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/features/authentication/presentation/widgets/password_suffix_icon_widget.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/services/account_storage_service.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/height_sized_box.dart';
import '../../../../core/widgets/my_text_field.dart';
import '../../manager/login_screen_cubit/login_screen_cubit.dart';
import '../../manager/login_screen_cubit/login_screen_state.dart';

class LoginTextFormAndButton extends StatelessWidget {
  const LoginTextFormAndButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.instance(context);
    return BlocListener<LoginCubit, LoginStates>(
      listener: (context, state) {
        if (state is LoginSuccessState ||
            state is GoogleSignInUsersAlreadyExists) {
          context.navigateAndRemoveUntil(pageName: AppRoutes.homeLayoutRoute);
        } else if (state is LoginErrorState) {
          myToast(
            msg: state.error,
            state: ToastStates.error,
            toastLength: Toast.LENGTH_LONG,
          );
        } else if (state is GoogleSignInSuccessState) {
          context.navigateTo(
            pageName: AppRoutes.registerRoute,
            arguments: [state.data],
          );
        } else if (state is GoogleSignInErrorState) {
          myToast(
            msg: state.error,
            state: ToastStates.error,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      },
      child: AutofillGroup(
        child: Form(
          key: cubit.formKey,
          child: Column(
            children: [
              MyTextField(
                autofocus: true,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username,
                ],
                onFieldSubmitted:
                    (_) => FocusScope.of(
                      context,
                    ).requestFocus(cubit.secondFocusNode),

                textInputAction: TextInputAction.next,
                validator:
                    (value) => AppValidator.emptyFiled(
                      value,
                      context,
                      AppStrings.email,
                    ),
                hint: AppStrings.email.tr(context),
                controller: cubit.emailController,
              ),
              const HeightSizedBox(height: 1.5),
              const PasswordFormField(),
              /*InkWell(
                onTap: () {
                  cubit.resetPassword(context);
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      AppStrings.forgetPassword.tr(context),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.myAppColor,
                      ),
                    ),
                  ),
                ),
              ),*/
              const HeightSizedBox(height: 1.5),
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<LoginCubit, LoginStates>(
                      builder: (context, state) {
                        return ButtonWidget(
                          isLoading: state is LoginWaitingState,
                          onPressed: () {
                            cubit.buttonFunction(context);
                          },
                          label: AppStrings.login.tr(context),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  FutureBuilder<Map<String, String>>(
                    future: AccountStorage.getAccounts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox.shrink(); // لسه بيجيب الداتا
                      }

                      final accounts = snapshot.data ?? {};
                      if (accounts.isEmpty) {
                        return const SizedBox.shrink(); // مفيش حسابات → متعرضش الزرار
                      }
                      return InkWell(
                        onTap: () {
                          cubit.loginWithBiometrics(context);
                        },
                        child: Container(
                          width: 13.wR,
                          height: 50,
                          padding: const EdgeInsets.all(7.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.myAppColor),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image(
                            image: AssetImage(
                              Platform.isIOS
                                  ? AppAssets.faceId
                                  : AppAssets.fingerPrint,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const HeightSizedBox(height: 1.5),
              MaterialButton(
                onPressed: () {
                  cubit.signInWithGoogle();
                },
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.googleLogo,
                      height: 25.sp,
                      width: 25.sp,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.signInWithGoogle.tr(context),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.doNotHaveAccount.tr(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.navigateTo(
                        pageName: AppRoutes.registerRoute,
                        arguments: [null],
                      );
                    },
                    child: Text(
                      AppStrings.register.tr(context),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.myAppColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
