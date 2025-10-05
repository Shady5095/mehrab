import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/app_success_dialog.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/features/notifications/presentation/manager/add_notification_cubit/add_notification_cubit.dart';

import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/dimens.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/validator.dart';
import '../../../../core/widgets/buttons_widget.dart';
import '../../../../core/widgets/my_appbar.dart';
import '../../../../core/widgets/my_text_field.dart';
import '../manager/add_notification_cubit/add_notification_state.dart';

class AddNotificationScreenBody extends StatelessWidget {
  const AddNotificationScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: BlocConsumer<AddNotificationCubit, AddNotificationState>(
          listener: (context, state) {
            if (state is AddNotificationSuccessState) {
              showSuccessDialog(
                context: context,
                text: AppStrings.notification,
                state: SuccessStates.add,
              );
            }
            if (state is AddNotificationErrorState) {
              myToast(
                msg: state.errorMessage,
                state: ToastStates.error,
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
          builder: (context, state) {
            final cubit = AddNotificationCubit.get(context);
            return Form(
              key: cubit.formKey,
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        MyAppBar(title: AppStrings.addNotification),
                        Center(
                          child: Image(
                            image: AssetImage(AppAssets.notification),
                            height: 95.sp,
                            width: 95.sp,
                          ),
                        ),
                        if(cubit.oneUserModel != null)
                        Row(
                          children: [
                            Text(
                              "${AppStrings.to.tr(context)} : ",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              cubit.oneUserModel!.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.myAppColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        MyTextField(
                          label: AppStrings.notificationTitle.tr(context),
                          controller: cubit.nameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator:
                              (String? value) => AppValidator.emptyFiled(
                                value,
                                context,
                                AppStrings.notificationTitle,
                              ),
                        ),
                        MyTextField(
                          label: AppStrings.notificationDetails.tr(context),
                          controller: cubit.detailsController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 4,
                          minLines: 4,
                          validator:
                              (String? value) => AppValidator.emptyFiled(
                                value,
                                context,
                                AppStrings.notificationDetails,
                              ),
                        ),
                        if(cubit.oneUserModel ==null)
                        Text(
                          "${AppStrings.sendNotificationTo.tr(context)} :",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if(cubit.oneUserModel ==null)
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  AppStrings.students.tr(context),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                value: cubit.isSendToStudents,
                                onChanged: (value) {
                                  cubit.changeSendToStudents(value!);
                                },
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(
                                  AppStrings.teachers.tr(context),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                value: cubit.isSendToTeachers,
                                onChanged: (value) {
                                  cubit.changeSendToTeachers(value!);
                                },
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: SizedBox(height: 20)),
                        ButtonWidget(
                          onPressed: () {
                            cubit.addNotification();
                          },
                          height: 40,
                          label: AppStrings.add.tr(context),
                          isLoading: state is AddNotificationLoadingState,
                        ),
                        SizedBox(height: 10),
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
