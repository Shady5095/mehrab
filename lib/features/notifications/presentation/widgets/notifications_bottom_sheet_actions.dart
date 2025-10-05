import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/notifications/presentation/manager/notifications_cubit/notifications_cubit.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/teacher_bottom_sheet_design.dart';
import '../../data/models/notification_model.dart';
import 'delete_notification_dialog.dart';

class NotificationsBottomSheetActions extends StatelessWidget {
  final NotificationModel notificationModel;
  final BuildContext oldContext;

  const NotificationsBottomSheetActions({
    super.key,
    required this.notificationModel,
    required this.oldContext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: oldContext.read<NotificationsCubit>(),
      child: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
          /*if (state is DeleteSurveySuccessState) {
            Navigator.pop(context);
            myToast(
              msg:
                  '${AppStrings.survey.tr(context)} ${successDialogText(SuccessStates.delete).tr(context)}',
              state: ToastStates.success,
            );
          } else if (state is DeleteSurveyErrorState) {
            myToast(
              msg: state.serverFailure.errorMessage,
              state: ToastStates.error,
            );
          }*/
        },
        builder: (context, state) {
          return MyBottomSheetDesign(
            children: [
              BottomSheetItem(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (context)=>DeleteNotificationDialog(notificationModel: notificationModel,));

                },
                icon: Icons.delete,
                title: AppStrings.delete.tr(context),
                titleColor: AppColors.redColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
