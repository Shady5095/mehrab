import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/features/my_profile/presentation/manager/my_profile_cubit.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../home/presentation/widgets/more_screen_body.dart';

class DeleteAccountDialog extends StatelessWidget {
  final BuildContext oldContext;

  const DeleteAccountDialog({super.key, required this.oldContext});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: MyProfileCubit.instance(oldContext),
      child: BlocConsumer<MyProfileCubit, MyProfileState>(
        listener: (context, state) {
          if (state is DeleteAccountSuccessState) {
            deleteAppCache();
            FirebaseAuth.instance.signOut();
            if (!context.mounted) {
              return;
            }
            context.navigateAndRemoveUntil(
              pageName: AppRoutes.loginRoute,
            );
            myToast(msg: AppStrings.yourAccountDeletedSuccessfully.tr(context), state: ToastStates.success);
          } else if (state is DeleteAccountErrorState) {
            Navigator.of(context).pop(); // Close the dialog
            myToast(msg: state.errorMessage,state: ToastStates.error);
          }
        },
        builder: (context, state) {
          return MyAlertDialog(
            makeIosAndAndroidSameDialog: true,
            icon: Image(
              image: AssetImage('assets/images/user_delete.png'),
              height: 80.sp,
              width: 80.sp,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.areYouSureDeleteYourAccount.tr(context),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  AppStrings.areYouSureDeleteYourAccountDescription.tr(context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5,
                ),
                if (state is DeleteAccountLoadingState)
                 LinearProgressIndicator(
                   backgroundColor: Colors.grey[400],
                 )
              ],
            ),
            onTapYes: () {
              MyProfileCubit.instance(oldContext).deleteMyAccount();
            },
          );
        },
      ),
    );
  }
}
