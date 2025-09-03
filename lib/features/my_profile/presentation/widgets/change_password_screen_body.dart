import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/dimens.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/my_profile/presentation/manager/my_profile_cubit.dart';

import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/my_text_field.dart';

class ChangePasswordScreenBody extends StatelessWidget {
  const ChangePasswordScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyProfileCubit>();
    return Form(
      key: cubit.passwordFormKey,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: BlocConsumer<MyProfileCubit, MyProfileState>(
            listener: (context, state) {
              if (state is UpdatePasswordSuccessState) {
                myToast(
                  msg: AppStrings.passwordChangedSuccessfully.tr(context),
                  state: ToastStates.success,
                );
                cubit.passwordController.clear();
                cubit.confirmPasswordController.clear();
                cubit.oldPasswordController.clear();
                Navigator.pop(context);
                Navigator.pop(context);
              } else if (state is UpdatePasswordErrorState) {
                myToast(msg: state.errorMessage, state: ToastStates.error);
              }
            },
            builder: (context, state) {
              return Column(
                spacing: 20,
                children: [
                  MyAppBar(title: AppStrings.changePassword),
                  MyTextField(
                    label: AppStrings.currentPassword.tr(context),
                    controller: cubit.oldPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obsceure: cubit.isOldPasswordObscured,
                    suffixIcon: IconButton(
                      icon: Icon(
                        cubit.isOldPasswordObscured
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: Colors.grey,
                      ),
                      onPressed: () => cubit.toggleOldPasswordVisibility(),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.passRequired.tr(context);
                      } else if (value.length < 6) {
                        return AppStrings.passwordShort.tr(context);
                      }
                      return null;
                    },
                  ),
                  MyTextField(
                    label: AppStrings.newPassword.tr(context),
                    controller: cubit.passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obsceure: cubit.isPasswordObscured,
                    suffixIcon: IconButton(
                      icon: Icon(
                        cubit.isPasswordObscured
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: Colors.grey,
                      ),
                      onPressed: () => cubit.togglePasswordVisibility(),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.passRequired.tr(context);
                      } else if (value.length < 6) {
                        return AppStrings.passwordShort.tr(context);
                      }
                      return null;
                    },
                  ),
                  MyTextField(
                    label: AppStrings.confirmNewPassword.tr(context),
                    controller: cubit.confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obsceure: cubit.isConfirmPasswordObscured,
                    suffixIcon: IconButton(
                      icon: Icon(
                        cubit.isConfirmPasswordObscured
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        color: Colors.grey,
                      ),
                      onPressed: () => cubit.toggleConfirmPasswordVisibility(),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: context.invertedColor),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.passRequired.tr(context);
                      } else if (value != cubit.passwordController.text) {
                        return AppStrings.passNotMatch.tr(context);
                      }
                      return null;
                    },
                  ),
                  Spacer(),
                  ButtonWidget(
                    onPressed: () {
                      if (cubit.passwordFormKey.currentState!.validate()) {
                        cubit.changePassword(context);
                      }
                    },
                    height: 40,
                    label: AppStrings.changePassword.tr(context),
                    isLoading: state is UpdatePasswordLoadingState,
                  ),
                  SizedBox(height: 5),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
