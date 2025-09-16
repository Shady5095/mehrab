import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/dimens.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/circle_toggle_button.dart';
import '../../../../core/widgets/my_text_field.dart';
import '../manager/my_teacher_profile_cubit.dart';
import '../manager/my_teacher_profile_state.dart';
import 'my_teacher_profile_profile_photo_build.dart';

class MyTeacherProfileScreenBody extends StatelessWidget {
  const MyTeacherProfileScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: BlocConsumer<MyTeacherProfileCubit, MyTeacherProfileState>(
          listener: (context, state) {
            if (state is UpdateProfileSuccessState) {
              Navigator.pop(context,true);
              myToast(
                msg: AppStrings.yourProfileUpdated.tr(context),
                state: ToastStates.success,
                toastLength: Toast.LENGTH_LONG,
              );
            } if (state is UpdateProfileErrorState) {
              myToast(msg: state.errorMessage, state: ToastStates.error,toastLength: Toast.LENGTH_LONG);
            }
          },
          builder: (context, state) {
            final cubit = MyTeacherProfileCubit.instance(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                  slivers: [SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      spacing: 10,
                      children: [
                        MyAppBar(title: AppStrings.myProfile,),
                        MyTeacherProfileProfilePhotoBuild(),
                        MyTextField(
                          label: AppStrings.fullName.tr(context),
                          controller: cubit.nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
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
                          validator:
                              (String? value) => AppValidator.emptyFiled(
                            value,
                            context,
                            AppStrings.name,
                          ),
                        ),
                        MyTextField(
                          label: AppStrings.email.tr(context),
                          controller: cubit.emailController,
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                          validator:
                              (String? value) => AppValidator.emailValidator(
                            value,
                            context,
                          ),
                        ),
                        MyTextField(
                          label: AppStrings.phone.tr(context),
                          controller: cubit.phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
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
                          validator:
                              (String? value) => AppValidator.emptyFiled(
                            value,
                            context,
                            AppStrings.phone,
                          ),
                        ),
                        IgnorePointer(
                          child: CircleToggleButtonGridView(
                            height: 5.hR,
                            length: 2,
                            titles: const [AppStrings.male, AppStrings.female],
                            selectedColor: Colors.grey,
                            initialIndex: cubit.isMale ? 0 : 1,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 20,
                          ),
                        ),
                        ButtonWidget(
                          onPressed: () {
                            cubit.onClickUpdateProfile();
                          },
                          height: 40,
                          label:  AppStrings.updateMyProfile.tr(context),
                          isLoading: state is UpdateProfileLoadingState,
                        ),
                        ButtonWidget(
                          onPressed: () {
                            context.navigateTo(pageName: AppRoutes.changePasswordScreenTeacher,arguments: [context]);
                          },
                          height: 40,
                          color: Colors.grey,
                          label:  AppStrings.changePassword.tr(context),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  ]
              ),
            );
          },
        ),
      ),
    );
  }
}
