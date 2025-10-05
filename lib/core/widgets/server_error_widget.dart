import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/strings.dart';
import '../utilities/resources/styles.dart';


class ServerErrorWidget extends StatelessWidget {
  final String errorMessage;
final double ?size;
  const ServerErrorWidget({super.key, required this.errorMessage, this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/error-404.png',
          width: size?? 220.sp,
          height: size??220.sp,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.oopsSomethingWentWrong.tr(context),
          style: AppStyle.textStyle14Bold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          errorMessage,
          style: AppStyle.textStyleError.copyWith(fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
