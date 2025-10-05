import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import '../../../../../core/utilities/functions/toast.dart';
import '../../../../../core/utilities/resources/colors.dart';
import '../../../../../core/utilities/resources/strings.dart';
import '../../../../../core/widgets/buttons_widget.dart';
import '../../../../../core/widgets/my_alert_dialog.dart';

class DeleteConfigurationDialog extends StatefulWidget {
  final TeacherModel teacherModel;
  const DeleteConfigurationDialog({super.key, required this.teacherModel});

  @override
  State<DeleteConfigurationDialog> createState() => _DeleteConfigurationDialog();
}

class _DeleteConfigurationDialog extends State<DeleteConfigurationDialog> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
      isFailed: true,
      makeIosAndAndroidSameDialog: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppStrings.areYouSureYouWantToDelete.tr(context)} ${AppStrings.teacher.tr(context)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 1.hR),
        ],
      ),
      actions: [
        if (!isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonWidget(
              labelColor: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
              label: AppStrings.no.tr(context),
              color: AppColors.white,
              width: 23.wR,
              height: 3.5.hR,
            ),
          ),
        if (isLoading)
          SizedBox(
            width: double.infinity,
            height: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.myAppColor.withValues(alpha: 0.4),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.myAppColor,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonWidget(
              onPressed: () {
                isLoading = true;
                setState(() {});
                FirebaseFirestore.instance.collection("users").doc(widget.teacherModel.uid).delete().then((
                  value,
                ) {
                      myToast(msg: "تم حذف المعلم بنجاح", state: ToastStates.success);
                      if(!context.mounted)return;
                      context.pop();
                }).catchError((error){
                  myToast(
                    msg: error.errorMessage,
                    state: ToastStates.error,
                  );
                  if(!context.mounted)return;
                  context.pop();
                });
              },
              label: AppStrings.yes.tr(context),
              width: 23.wR,
              height: 3.5.hR,
              color: AppColors.myAppColor,
            ),
          ),
      ],
    );
  }
}
