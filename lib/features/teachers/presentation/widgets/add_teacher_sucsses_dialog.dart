import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';

class AddTeacherSuccessDialog extends StatelessWidget {
  final TeacherModel teacher;
  const AddTeacherSuccessDialog({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
        makeIosAndAndroidSameDialog: true,
      actions: [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: AssetImage('assets/images/teacher_added.png'),
            height: 100.sp,
            width: 100.sp,
          ),
          SizedBox(height: 10.sp),
          Text(
            teacher.isMale ? 'تم إضافة المعلم بنجاح' : 'تم إضافة المعلمة بنجاح',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            teacher.isMale ? 'برجاء إبلاغ المعلم ببيانات الدخول الخاصة به' : 'برجاء إبلاغ المعلمة ببيانات الدخول الخاصة بها',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10.sp),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                size: 18.sp,
              ),
              SizedBox(width: 5),
              Text(
                "البريد الألكتروني",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.sp),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: teacher.email));
              myToast(msg:"تم نسخ البريد الألكتروني", state: ToastStates.normal);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  teacher.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.myAppColor
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.copy, size: 18.sp, color: AppColors.myAppColor,)
              ],
            ),
          ),
          SizedBox(height: 5.sp),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 18.sp,
              ),
              SizedBox(width: 5),
              Text(
                "كلمة المرور",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.sp),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: teacher.password));
              myToast(msg:"تم نسخ كلمة المرور", state: ToastStates.normal);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    teacher.password,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.myAppColor
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.copy, size: 18.sp, color: AppColors.myAppColor,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
