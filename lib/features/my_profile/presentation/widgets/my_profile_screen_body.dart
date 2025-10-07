import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/my_profile/presentation/manager/my_profile_cubit.dart';
import '../../../../app/app_locale/app_locale.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/dimens.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/app_cusstom_drop_down_menu.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/circle_toggle_button.dart';
import '../../../../core/widgets/my_text_field.dart';
import 'delete_account_dialog.dart';
import 'my_profile_profile_photo_build.dart';

class MyProfileScreenBody extends StatelessWidget { 
  const MyProfileScreenBody({super.key}); 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: BlocConsumer<MyProfileCubit, MyProfileState>(
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
            final cubit = MyProfileCubit.instance(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                  slivers: [SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      spacing: 10,
                      children: [
                        MyAppBar(title: AppStrings.myProfile,),
                        MyProfileProfilePhotoBuild(),
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
                        IntlPhoneField(
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          controller: cubit.phoneController,
                          languageCode: isArabic(context)?  "ar" : "en",
                          decoration: InputDecoration(

                            label: FittedBox(child: Text(AppStrings.phone.tr(context), maxLines: 1)),
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
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: context.invertedColor),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          textAlign: isArabic(context) ? TextAlign.right : TextAlign.left,
                          initialCountryCode: cubit.countryCode,

                          onChanged: (phone) {
                            cubit.countryCodeNumber = phone.countryISOCode;
                            cubit.countryCode = phone.countryCode;
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
                            borderSide: BorderSide(color: context.invertedColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.invertedColor),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.invertedColor),
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
                            borderSide: BorderSide(color: context.invertedColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.invertedColor),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.invertedColor),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        IgnorePointer(
                          child: CircleToggleButtonGridView(
                            height: 6.hR,
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
                        if(cubit.userModel.signInMethod != "google")
                        Row(
                          children: [
                            Expanded(
                              child: ButtonWidget(
                                onPressed: () {
                                  context.navigateTo(pageName: AppRoutes.changePasswordScreen,arguments: [context]);
                                },
                                height: 40,
                                color: Colors.grey,
                                label:  AppStrings.changePassword.tr(context),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: ButtonWidget(
                                onPressed: () {
                                  showDialog(context: context, builder: (_){
                                    return DeleteAccountDialog(oldContext: context,);
                                  });
                                },
                                height: 40,
                                color: Colors.red,
                                label:  AppStrings.deleteAccount.tr(context),
                              ),
                            ),
                          ],
                        )else
                          ButtonWidget(
                            onPressed: () {
                              showDialog(context: context, builder: (_){
                                return DeleteAccountDialog(oldContext: context,);
                              });
                            },
                            height: 40,
                            color: Colors.red,
                            label:  AppStrings.deleteAccount.tr(context),
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
