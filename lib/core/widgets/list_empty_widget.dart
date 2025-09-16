import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../utilities/resources/strings.dart';
import '../utilities/resources/styles.dart';
import 'height_sized_box.dart';

class ListEmptyWidget extends StatelessWidget {
  final String icon;
  final String title;
  final Color? color;
  final String? description;

  const ListEmptyWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (color != null)
          ImageIcon(AssetImage(icon), color: color, size: 80.sp),
        if (color == null) Image.asset(icon, width: 9.hR, height: 9.hR),
        Text(
          title.tr(context),
          style: AppStyle.textStyle20,
          textAlign: TextAlign.center,
        ),
        const HeightSizedBox(height: 0.5),
        if (description != null)
          Text(
            description!.tr(context),
            style: AppStyle.textStyle12GreyBlue,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class ListEmptyWidgetIllustration extends StatelessWidget {
  final String icon;
  final String title;
  final String? description;
  final double? imageSize;
  final BoxFit? imageFit;

  const ListEmptyWidgetIllustration({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.imageSize,
    this.imageFit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          fit: imageFit,
          icon,
          width: imageSize ?? 220.sp,
          height: imageSize ?? 220.sp,
        ),
        Text(
          title.tr(context),
          style: AppStyle.textStyle20,
          textAlign: TextAlign.center,
        ),
        const HeightSizedBox(height: 0.5),
        if (description != null)
          Text(
            description!.tr(context),
            style: AppStyle.textStyle12GreyBlue,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class NoUsersInList extends StatelessWidget {
  const NoUsersInList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 50, color: context.invertedColor),
        Center(child: Text(AppStrings.noStudent.tr(context))),
      ],
    );
  }
}
