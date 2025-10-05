import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/dimens.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/validator.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/core/widgets/my_text_field.dart';
import 'package:mehrab/features/teachers/presentation/manager/add_teacher_cubit/add_teacher_cubit.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/circle_toggle_button.dart';
import 'add_teacher_profile_photo_build.dart';

class AddTeacherScreenBody extends StatelessWidget {
  const AddTeacherScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: BlocConsumer<AddTeacherCubit, AddTeacherState>(
          listener: (context, state) {
            if (state is RegisterSuccessState) {
              Navigator.pop(context,true);
              myToast(msg: "تم اضافة المعلم بنجاح", state: ToastStates.success);
            } if (state is RegisterErrorState) {
              myToast(msg: state.errorMessage, state: ToastStates.error,toastLength: Toast.LENGTH_LONG);
            }
            if (state is UpdateTeacherSuccessState) {
              Navigator.pop(context,true);
              myToast(msg: "تم تعديل المعلم بنجاح", state: ToastStates.success);
            } if (state is UpdateTeacherErrorState) {
              myToast(msg: state.errorMessage, state: ToastStates.error,toastLength: Toast.LENGTH_LONG);
            }
          },
          builder: (context, state) {
            final cubit = AddTeacherCubit.get(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      spacing: 10,
                      children: [
                        MyAppBar(title:cubit.teacherModel ==null ? AppStrings.addTeacher : AppStrings.editTeacher,),
                        AddTeacherProfilePhotoBuild(),
                        MyTextField(
                          label: AppStrings.fullName.tr(context),
                          controller: cubit.nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
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
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),

                          validator:
                              (String? value) =>
                                  AppValidator.emailValidator(value, context),
                        ),
                        MyTextField(
                          enabled: cubit.teacherModel == null ,
                          label: AppStrings.password.tr(context),
                          controller: cubit.passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          obsceure:cubit.teacherModel == null ? cubit.isPasswordObscured : false,
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
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
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
                          label: AppStrings.phone.tr(context),
                          controller: cubit.phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),

                          validator:
                              (String? value) =>
                                  AppValidator.emptyFiled(value, context,
                                      AppStrings.phone),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextField(
                                label: AppStrings.experience.tr(context),
                                controller: cubit.experienceController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.invertedColor,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.invertedColor,
                                  ),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: context.invertedColor,
                                  ),
                                ),
                                validator:
                                    (String? value) =>
                                        AppValidator.emptyFiled(
                                          value,
                                          context,
                                          AppStrings.experience,
                                        ),
                              ),
                            ),
                            SizedBox(width: 30),
                            Text(AppStrings.yearExperience.tr(context)),
                          ],
                        ),
                        MyTextField(
                          label: "${AppStrings.specialization.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.specializationController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.foundationalTexts.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.foundationalTextsController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.categories.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.categoriesController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.tracks.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.tracksController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.compositions.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.compositionsController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.curriculum.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.curriculumController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.compatibility.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.compatibilityController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.universityDegree.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.schoolController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        MyTextField(
                          label: "${AppStrings.igaz.tr(context)} ${AppStrings.optional.tr(context)}",
                          controller: cubit.igazahController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                        CircleToggleButtonGridView(
                          height: 5.hR,
                          length: 2,
                          titles: const [AppStrings.male, AppStrings.female],
                          selectedColor: AppColors.myAppColor,
                          onChangeIndex: (int index) {
                            if (index == 0) {
                              cubit.isMale = true;
                            } else {
                              cubit.isMale = false;
                            }
                          },
                          initialIndex: cubit.isMale ? 0 : 1,
                        ),
                        Expanded(child: SizedBox(height: 20)),
                        ButtonWidget(
                          onPressed: () {
                            if(cubit.teacherModel == null){
                              cubit.onTabAddTeacher(context);
                            }else{
                              cubit.updateTeacher();
                            }
                          },
                          height: 40,
                          label:cubit.teacherModel == null ? AppStrings.add.tr(context) : AppStrings.edit.tr(context),
                          isLoading: state is RegisterLoadingState || state is UpdateTeacherLoadingState,
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
