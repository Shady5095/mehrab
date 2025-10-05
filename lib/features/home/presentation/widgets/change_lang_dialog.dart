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
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        cubit.englishFunction();
                        context.pop();
                      },
                      child: Container(
                        height: 12.hR,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          color: cubit
                              .setEnglishColor(context)
                              .withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                             Expanded(
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(AppAssets.englishLang),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    AppConstants.english,
                                    style: AppStyle.textStyle14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        cubit.arabicFunction();
                        context.pop();
                      },
                      child: Container(
                        height: 12.hR,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          color: cubit
                              .setArabicColor(context)
                              .withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                             Expanded(
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(AppAssets.arabicLang),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    AppConstants.arabic,
                                    style: AppStyle.textStyle14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
