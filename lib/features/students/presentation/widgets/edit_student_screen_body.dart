import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/students/presentation/manager/edit_student_cubit/edit_student_cubit.dart';

import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/app_cusstom_drop_down_menu.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/circle_toggle_button.dart';
import '../../../../core/widgets/my_text_field.dart';
import 'edit_student_profile_photo_build.dart';


class EditStudentScreenBody extends StatelessWidget {
  const EditStudentScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<EditStudentCubit, EditStudentState>(
          listener: (context, state) {
            if (state is EditStudentSuccessState) {
              context.pop();
              myToast(
                msg: "تم تعديل بيانات الطالب بنجاح",
                state: ToastStates.success,
              );
            }
            if (state is EditStudentErrorState) {
              myToast(
                msg: state.error,
                state: ToastStates.error,
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
          builder: (context, state) {
            final cubit = EditStudentCubit.get(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      spacing: 10,
                      children: [
                        MyAppBar(title: 'تعديل بيانات الطالب'),
                        EditStudentProfilePhotoBuild(),
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
                            enabled: false,
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

                        if (cubit.userModel.signInMethod == 'email')
                          MyTextField(
                            label: AppStrings.password.tr(context),
                            controller: cubit.passwordController,
                            enabled: false,
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
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.passRequired.tr(context);
                              } else if (value.length < 6) {
                                return AppStrings.passwordShort.tr(context);
                              }
                              return null;
                            },
                          ),
                        IntlPhoneField(
                          validator: (value) {
                            if (value == null || value.number.isEmpty) {
                              return null;
                            }
                            try {
                              if (!value.isValidNumber()) {
                                return 'رقم الهاتف غير صالح';
                              }
                            } on NumberTooShortException {
                              return 'رقم الهاتف قصير جدا';
                            } catch (e) {
                              return 'رقم الهاتف غير صالح';
                            }
                            return null; // Valid input
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: cubit.phoneController,
                          //initialValue: "us",
                          languageCode: isArabic(context) ? "ar" : "en",
                          decoration: InputDecoration(
                            label: FittedBox(
                              child: Text(
                                AppStrings.phone.tr(context),
                                maxLines: 1,
                              ),
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
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: context.invertedColor,
                              ),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          textAlign:
                          isArabic(context)
                              ? TextAlign.right
                              : TextAlign.left,
                          initialCountryCode:
                          cubit.countryCode,

                          onChanged: (phone) {
                            cubit.countryCode = phone.countryISOCode;
                            cubit.countryCodeNumber = phone.countryCode;
                          },
                          //countries: AppConstants.arabCountries,
                        ),
                        CustomDropDownMenu(
                          dropdownItems:
                          isArabic(context)
                              ? AppConstants.arabicNationalities
                              : AppConstants.nationalities,
                          value: cubit.selectedNationality,
                          isTextTranslated: true,
                          onChanged: (value) {
                            cubit.selectedNationality = value;
                          },
                          label: AppStrings.nationality.tr(context),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        CustomDropDownMenu(
                          dropdownItems: AppConstants.educationLevelKeys,
                          value: cubit.selectedEducationLevel,
                          isTextTranslated: true,
                          onChanged: (value) {
                            cubit.selectedEducationLevel = value;
                          },
                          label: AppStrings.educationLevel.tr(context),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: context.invertedColor,
                            ),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
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
                            cubit.updateStudent();
                          },
                          height: 40,
                          label: "تعديل",
                          isLoading: state is EditStudentLoadingState,
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
