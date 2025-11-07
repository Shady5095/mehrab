import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/utilities/resources/styles.dart';
import '../../../home/presentation/widgets/contact_us_dialog.dart';

class StudentProfileDataItem extends StatelessWidget {
  final String? title;
  final String? description;
  final bool isTitleTranslated;
  final Color? color;

  const StudentProfileDataItem({
    super.key,
    required this.title,
    required this.description,
    this.isTitleTranslated = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (description == null || description == 'null' || description == '' || description == 'unkonwn') {
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
          child: Row(children: [Expanded(child: _buildDescriptionContent())]),
        ),
      ],
    );
  }

  Widget _buildDescriptionContent() {
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
        SelectableText(
          description!,
          textAlign: TextAlign.start,
          style: AppStyle.textStyle14.copyWith(height: 1.5),
          maxLines: 15,
          minLines: 1,
        ),
        if (title == AppStrings.phone) ...[
          Spacer(),
          InkWell(
            onTap: () {
              openWhatsapp(phoneNumber: description.toString(), text: '');
            },
            child: Icon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
              size: 22.sp,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              callDial(description.toString());
            },
            child: Icon(
              Icons.call,
              color: Colors.blue,
              size: 22.sp,
            ),
          ),
        ],
      ],
    );
  }
}
