import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/teachers/presentation/manager/teacher_profile_cubit/teacher_profile_cubit.dart';

class TeacherProfileTabs extends StatelessWidget {

  const TeacherProfileTabs({super.key,});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
      builder: (context, state) {
        final cubit = TeacherProfileCubit.get(context);
        final currentIndex = cubit.currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    cubit.changeIndex(0);
                  },
                  child: Container(
                    padding:  EdgeInsets.symmetric(
                        horizontal: 10, vertical:AppConstants.isAdmin ? 7.5 : 6),
                    decoration: BoxDecoration(
                      color: currentIndex ==0 ? AppColors.myAppColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.profile.tr(context),
                        style:  TextStyle(
                          fontSize: AppConstants.isAdmin ? 12.5.sp : 13.5,
                          color: currentIndex ==0 ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              if(!AppConstants.isTeacher)
              Expanded(
                child: InkWell(
                  onTap: () {
                    cubit.changeIndex(1);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: currentIndex ==1 ? AppColors.myAppColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.comments.tr(context),
                        style:  TextStyle(
                          color: currentIndex ==1 ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if(AppConstants.isAdmin)
                ...[
                  const SizedBox(width: 5),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        cubit.changeIndex(2);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: currentIndex == 2 ? AppColors.myAppColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.sessions.tr(context),
                            style:  TextStyle(
                              color: currentIndex ==2 ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

            ],
          ),
        );
      },
    );
  }
}
