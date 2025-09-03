import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../app/main_app_cubit/main_app_cubit.dart';
import '../../../../app/main_app_cubit/main_app_state.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';

class ChangeLanguageWidget extends StatelessWidget {
  const ChangeLanguageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppCubit, MainAppStates>(
      builder: (context, state) {
        final cubit = context.read<MainAppCubit>();
        final isEnglish = cubit.isEnglish;
        return SizedBox(
          height: 70,
          child: Center(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      cubit.englishFunction();
                    },
                    child: Text(
                      "English",
                      style: TextStyle(
                        color: isEnglish ? AppColors.myAppColor : Colors.grey,
                        fontSize: 13.sp,
                        fontFamily: AppConstants.englishFont,
                        fontWeight:
                        isEnglish ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.grey,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  TextButton(
                    onPressed: () {
                      cubit.arabicFunction();
                    },
                    child: Text(
                      "العربية",
                      style: TextStyle(
                        color: !isEnglish ? AppColors.myAppColor : Colors.grey,
                        fontSize: 14.sp,
                        fontFamily: AppConstants.arabicFont,
                        fontWeight:
                        !isEnglish ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
