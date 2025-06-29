import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/assets.dart';
import '../utilities/resources/colors.dart';
import '../utilities/resources/dimens.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.onPressed,
    required this.label,
    this.labelFontSize,
    this.isLoading = false,
    this.isShowArrow = false,
    this.isTextFitted = false,
    this.width,
    this.height,
    this.color,
    this.labelColor,
    this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final VoidCallback onPressed;
  final String label;
  final double? labelFontSize;
  final Color? labelColor;
  final bool isLoading;
  final bool isShowArrow;
  final bool isTextFitted;
  final double? width;

  final double? height;

  final Color? color;
  final IconData? icon;
  final BorderRadiusGeometry borderRadius;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          onPressed: isLoading ? () {} : onPressed,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
            ),
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child:
              !isLoading
                  ? isTextFitted
                      ? FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: labelColor ?? AppColors.white,
                                fontSize:
                                    labelFontSize ??
                                    AppDimens.buttonFontSize.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isShowArrow)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Icon(
                                  icon ?? Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                          ],
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: labelColor ?? AppColors.white,
                              fontSize:
                                  labelFontSize ??
                                  AppDimens.buttonFontSize.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isShowArrow)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: Icon(
                                icon ?? Icons.arrow_forward,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                        ],
                      )
                  : Lottie.asset(
                    AppAssets.waitingDots,
                    height: AppDimens.buttonHeight,
                    width: 100,
                  ),
        ),
      ),
    );
  }
}

class OutlineButtonWidget extends StatelessWidget {
  const OutlineButtonWidget({
    super.key,
    required this.onPressed,
    required this.label,
    this.labelFontSize,
    this.isLoading = false,
    this.isShowArrow = false,
    this.isTextFitted = false,
    this.width,
    this.height,
    this.color,
    this.labelColor,
    this.icon,
    this.borderColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double? labelFontSize;
  final Color? labelColor;
  final Color? borderColor;
  final bool isLoading;
  final bool isShowArrow;
  final bool isTextFitted;
  final double? width;

  final double? height;

  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      radius: 20,
      onTap: isLoading ? () {} : onPressed,
      child: Container(
        height: height ?? 50,
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? AppColors.accentColor,
            width: 1.5,
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            !isLoading
                ? isTextFitted
                    ? FittedBox(
                      child: Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: labelColor ?? AppColors.accentColor,
                              fontSize: AppDimens.outlineButtonFontSize.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isShowArrow)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: Icon(
                                icon ?? Icons.arrow_forward,
                                color: AppColors.accentColor,
                                size: 20.sp,
                              ),
                            ),
                        ],
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: labelColor ?? AppColors.accentColor,
                            fontSize: AppDimens.outlineButtonFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isShowArrow)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            child: Icon(
                              icon ?? Icons.arrow_forward,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                      ],
                    )
                : Lottie.asset(
                  AppAssets.waitingDots,
                  height: AppDimens.buttonHeight,
                  width: 100,
                ),
      ),
    );
  }
}

class OutlineButtonWidgetWithIcon extends StatelessWidget {
  const OutlineButtonWidgetWithIcon({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.width,
    this.height,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 3,
    child: InkWell(
      onTap: onPressed,
      child: Container(
        height: height ?? AppDimens.buttonHeight,
        width: width ?? double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.accentColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.tr(context),
              style: const TextStyle(
                color: AppColors.accentColor,
                fontSize: AppDimens.outlineButtonFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: AppColors.accentColor),
          ],
        ),
      ),
    ),
  );
}
