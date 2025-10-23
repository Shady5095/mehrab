import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../../../app/main_app_cubit/main_app_cubit.dart';
import '../../../../app/main_app_cubit/main_app_state.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/resources/styles.dart';

class ChangeLangDialog extends StatelessWidget {
  const ChangeLangDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      actions: const [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.appLanguage.tr(context),
            style: AppStyle.textStyle14Bold,
          ),
          const SizedBox(height: 30),
          BlocBuilder<MainAppCubit, MainAppStates>(
            builder: (context, state) {
              final MainAppCubit cubit = MainAppCubit.instance(context);
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      cubit.changeLanguage('ar');
                      context.pop();
                    },
                    child: Container(
                      height: 6.hR,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        color: cubit
                            .setLanguageColor(context, 'ar')
                            .withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.arabic,
                            style: AppStyle.textStyle14,
                          ),
                          Image(
                            image: AssetImage(AppAssets.arabicLang),
                            height: 4.hR,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: () {
                      cubit.changeLanguage('en');
                      context.pop();
                    },
                    child: Container(
                      height: 6.hR,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        color: cubit
                            .setLanguageColor(context, 'en')
                            .withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.english,
                            style: AppStyle.textStyle14,
                          ),
                          Image(
                            image: AssetImage(AppAssets.englishLang),
                            height: 4.hR,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: () {
                      cubit.changeLanguage('tr');
                      context.pop();
                    },
                    child: Container(
                      height: 6.hR,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        color: cubit
                            .setLanguageColor(context, 'tr')
                            .withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.turkish,
                            style: AppStyle.textStyle14,
                          ),
                          Image(
                            image: AssetImage("assets/images/turkey.png"),
                            height: 4.hR,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: () {
                      cubit.changeLanguage('de');
                      context.pop();
                    },
                    child: Container(
                      height: 6.hR,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        color: cubit
                            .setLanguageColor(context, 'de')
                            .withValues(alpha: 0.6),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppConstants.germany,
                            style: AppStyle.textStyle14,
                          ),
                          Image(
                            image: AssetImage("assets/images/germanyIcon.png"),
                            height: 4.hR,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}