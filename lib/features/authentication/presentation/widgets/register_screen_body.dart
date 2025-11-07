import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/dimens.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/utilities/validator.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/core/widgets/my_text_field.dart';
import 'package:mehrab/features/authentication/manager/register_screen_cubit/register_cubit.dart';
import 'package:mehrab/features/authentication/presentation/widgets/register_profile_photo_build.dart';

import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/widgets/app_cusstom_drop_down_menu.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/circle_toggle_button.dart';

class RegisterScreenBody extends StatelessWidget {
  const RegisterScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccessState) {
              context.navigateAndRemoveUntil(
                pageName: AppRoutes.homeLayoutRoute,
              );
            }
            if (state is RegisterErrorState) {
              myToast(
                msg: state.errorMessage,
                state: ToastStates.error,
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
          builder: (context, state) {
            final cubit = RegisterCubit.instance(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      spacing: 10,
                      children: [
                        MyAppBar(
                          title:
                              cubit.socialSignInModel == null
                                  ? AppStrings.registerStudent
                                  : AppStrings.completeRegistration,
                        ),
                        RegisterProfilePhotoBuild(),
                        if(!Platform.isIOS || cubit.socialSignInModel?.singInMethod != 'apple' || cubit.socialSignInModel?.displayName ==null)
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
                        if(!Platform.isIOS || cubit.socialSignInModel?.singInMethod != 'apple')
                        MyTextField(
                          label: AppStrings.email.tr(context),
                          controller: cubit.emailController,
                          enabled: cubit.socialSignInModel == null,
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
                              CacheService.currentCountryCode ?? "EG",

                          onChanged: (phone) {
                            cubit.countryCode = phone.countryISOCode;
                            cubit.countryCodeNumber = phone.countryCode;
                            // ✅ إزالة الصفر في حالة مصر فقط
                            if (phone.countryISOCode == 'EG') {
                              final text = cubit.phoneController.text;
                              if (text.startsWith('0')) {
                                cubit.phoneController.text = text.substring(1);
                                cubit.phoneController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: cubit.phoneController.text.length),
                                );
                              }
                            }
                          },
                          //countries: AppConstants.arabCountries,
                        ),
                        if (cubit.socialSignInModel == null)
                          MyTextField(
                            label: AppStrings.password.tr(context),
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
                              }else if (value.contains(' ')) {
                                return 'كلمة السر لا يجب أن تحتوي على مسافات';
                              }
                              else if (!RegExp(r'^[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$').hasMatch(value)) {
                                return 'يرجى إدخال كلمة السر باللغة الإنجليزية فقط';
                              }
                              return null;
                            },
                          ),
                        if (cubit.socialSignInModel == null)
                          MyTextField(
                            label: AppStrings.confirmPassword.tr(context),
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
                              onPressed:
                                  () => cubit.toggleConfirmPasswordVisibility(),
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
                              }
                              else if (value.contains(' ')) {
                                return 'كلمة السر لا يجب أن تحتوي على مسافات';
                              }
                              else if (!RegExp(r'^[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$').hasMatch(value)) {
                                return 'يرجى إدخال كلمة السر باللغة الإنجليزية فقط';
                              } else if (value !=
                                  cubit.passwordController.text) {
                                return AppStrings.passNotMatch.tr(context);
                              }
                              return null;
                            },
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropDownMenu(
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
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: CustomDropDownMenu(
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
                            ),
                          ],
                        ),
                        CustomDropDownMenu(
                          dropdownItems: cubit.qiraatList,
                          value: cubit.favoriteIgaz,
                          onChanged: (value) {
                            cubit.favoriteIgaz = value;
                          },
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
                          label: AppStrings.favoriteIgaz.tr(context),
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
                            cubit.onTabRegister(context);
                          },
                          height: 40,
                          label:
                              cubit.socialSignInModel == null
                                  ? AppStrings.register.tr(context)
                                  : AppStrings.register2.tr(context),
                          isLoading: state is RegisterLoadingState,
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
