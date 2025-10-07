import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../../../core/utilities/services/firebase_notification.dart';
import 'change_lang_dialog.dart';
import 'contact_us_dialog.dart';

class MoreScreenBody extends StatelessWidget {
  const MoreScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              MyAppBar(title: AppStrings.more, isShowBackButton: false),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  if (!context.mounted ||
                      HomeCubit.instance(context).userModel == null) {
                    return;
                  }
                  if (currentUserModel?.userRole == "teacher") {
                    context
                        .navigateTo(
                      pageName: AppRoutes.myProfileScreenTeacher,
                      arguments: [HomeCubit.instance(context).teacherModel],
                    )
                        .then((value) {
                      if (value == true) {
                        if (!context.mounted) {
                          return;
                        }
                        HomeCubit.instance(context).userModel = null;
                        HomeCubit.instance(context).teacherModel = null;
                        HomeCubit.instance(context).getUserData(context);
                      }
                    });
                  }else{
                    context
                        .navigateTo(
                      pageName: AppRoutes.myProfileRoute,
                      arguments: [HomeCubit.instance(context).userModel],
                    )
                        .then((value) {
                      if (value == true) {
                        if (!context.mounted) {
                          return;
                        }
                        HomeCubit.instance(context).currentScreenIndex = 0;
                        HomeCubit.instance(context).userModel = null;
                        HomeCubit.instance(context).getUserData(context);
                      }
                    });
                  }
                },
                contentPadding: const EdgeInsets.all(10),
                leading: Icon(Icons.person_outline, size: 24.sp),
                title: Text(
                  AppStrings.myProfile.tr(context),
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangeLangDialog(),
                  );
                },
                contentPadding: const EdgeInsets.all(10),
                leading: Icon(Icons.language, size: 24.sp),
                title: Text(
                  AppStrings.language.tr(context),
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) =>  ContactUsDialog(),
                  );
                },
                contentPadding: const EdgeInsets.all(10),
                leading: Icon(Icons.call, size: 24.sp),
                title: Text(
                  AppStrings.contactUs.tr(context),
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder:
                        (newContext) => BlocProvider.value(
                          value: HomeCubit.instance(context),
                          child: MyAlertDialog(
                            title: AppStrings.areYouSureLogout.tr(context),
                            isFailed: true,
                            onTapYes: () {
                              deleteAppCache();
                              FirebaseAuth.instance.signOut();
                              //HomeCubit.instance(context).onSignOut();
                              if (!context.mounted) {
                                return;
                              }
                              context.navigateAndRemoveUntil(
                                pageName: AppRoutes.loginRoute,
                              );
                            },
                          ),
                        ),
                  );
                },
                contentPadding: const EdgeInsets.all(10),
                leading: Icon(
                  Icons.logout,
                  size: 24.sp,
                  color: AppColors.redColor,
                ),
                title: Text(
                  AppStrings.logout.tr(context),
                  style: TextStyle(fontSize: 18.sp, color: AppColors.redColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> deleteAppCache() async {
  await Future.wait([
    AppFirebaseNotification.unSubscribeFromTopic(CacheService.userRole ?? ''),
    CacheService.removeData(key: AppConstants.uid),
    CacheService.removeData(key: AppConstants.userRole),
    AppFirebaseNotification.deleteNotificationToken(),
  ]);
  CacheService.uid = null;
  CacheService.userRole = null;
  AppConstants.isAdmin = false;
  AppConstants.isTeacher = false;
  AppConstants.isStudent = false;
  currentUserModel = null;
  myUid = '';
  currentTeacherModel = null;
}
