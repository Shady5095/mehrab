import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/styles.dart';
import 'back_button.dart';



class MyAppBar extends StatelessWidget {
  final String title;
  final bool isShowBackButton;
  final bool centerTitle;
  final bool isExitButton;
  final TextStyle? titleTextStyle;

  final VoidCallback? onTapAddButton;
  final Widget? actionIcon;
  final int? flex;
  final VoidCallback? onTapBackButton;
  final bool isTextTranslate;

  const MyAppBar({
    super.key,
    required this.title,
    this.isShowBackButton = true,
    this.centerTitle = true,
    this.isExitButton = false,
    this.titleTextStyle,

    this.onTapAddButton,
    this.actionIcon,
    this.flex,
    this.onTapBackButton,
    this.isTextTranslate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isShowBackButton)
              MyBackButton(onTap: onTapBackButton, isExitButton: isExitButton),
            if (isShowBackButton) Spacer(flex: flex ?? 3),
            Text(
              textAlign: TextAlign.center,
              isTextTranslate ? title.tr(context) : title,
              maxLines: 1,
              style:
                  titleTextStyle ??
                  AppStyle.textStyle28.copyWith(fontSize: 22.sp),
            ),
            if (isShowBackButton) const Spacer(flex: 4),

            if (actionIcon != null) actionIcon!,
          ],
        ),
      ),
    );
  }
}

class CenterAppBar extends StatelessWidget {
  const CenterAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      title.tr(context),
      maxLines: 1,
      style: AppStyle.textStyle28,
    );
  }
}
