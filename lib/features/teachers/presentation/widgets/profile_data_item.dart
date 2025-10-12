import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/resources/styles.dart';

class ProfileDataItem extends StatelessWidget {
  final String? title;
  final String? description;
  final bool isTitleTranslated;
  final Color? color;
  final String? igazPdfUrl;

  const ProfileDataItem({
    super.key,
    required this.title,
    required this.description,
    this.isTitleTranslated = true,
    this.color,
    this.igazPdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (description == null || description == 'null' || description == '') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTitleTranslated ? (title?.tr(context) ?? '') : title ?? '',
          style: AppStyle.textStyle14AccentColor,
        ),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color ?? context.containerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [Expanded(child: _buildDescriptionContent(context))]),
        ),
      ],
    );
  }

  Widget _buildDescriptionContent(BuildContext context) {
    if (description == '-') {
      return const Center(
        child: SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.myAppColor),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SelectableText(
            description!,
            textAlign: TextAlign.start,

            style: AppStyle.textStyle14.copyWith(height: 1.5),
            maxLines: 15,
            minLines: 1,
          ),
        ),
        if (title == AppStrings.igaz &&
            AppConstants.isAdmin &&
            igazPdfUrl != null)
          InkWell(
            onTap: () {
              context.navigateTo(pageName: AppRoutes.pdfNetworkViewer, arguments: igazPdfUrl);
            },
            child: Image(
              image: const AssetImage("assets/images/pdfReports.png"),
              width: 30.sp,
              height: 30.sp,
            ),
          ),
      ],
    );
  }
}
