import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'functions/format_date_and_time.dart';

abstract class AppValidator {
  static String? passwordValidator(String? value, BuildContext context) {
    if (value?.isEmpty == true) {
      return AppStrings.passwordValue.tr(context);
    } else if ((value?.length ?? 0) <= 2) {
      return AppStrings.passwordShort.tr(context);
    } else {
      return null;
    }
  }

  static String? userNameValidator(String? value, BuildContext context) {
    final bool nameValid = RegExp(r'^[a-zA-Z0-9_\s\-]+$').hasMatch(value ?? '');
    if (value?.isEmpty == true) {
      return AppStrings.nameValue.tr(context);
    }
    if (!nameValid) {
      return AppStrings.validName.tr(context);
    } else {
      return null;
    }
  }

  static String? domainValidator(String? value, BuildContext context) {
    if (value?.isEmpty == true) {
      return AppStrings.enterUrl.tr(context);
    }
    if (value?.trim().toLowerCase().contains(AppConstants.domainName) ==
        false) {
      return AppStrings.enterValidUrl.tr(context);
    } else {
      return null;
    }
  }

  static String? emptyFiled(
    String? value,
    BuildContext context,
    String filedName, [
    bool isTestTranslated = true,
  ]) {
    if (value?.isEmpty == true || value == null || value.trim().isEmpty) {
      return '${AppStrings.mustHaveValue.tr(context)} ${isTestTranslated ? filedName.tr(context) : filedName}';
    }
    return null;
  }

  static String? fileValidator(
    String? value,
    BuildContext context,
    File? file,
  ) {
    if (file != null) {
      return null;
    } else if (value?.isEmpty == true || value?.trim() == '') {
      return AppStrings.answerRequired.tr(context);
    }
    return null;
  }

  static String? endDateValidator(
    String? value,
    BuildContext context,
    String startDate, {
    String formatString = 'M/d/yyyy, h:mm a',
  }) {
    if (value?.isEmpty == true || value == null) {
      return '${AppStrings.mustHaveValue.tr(context)} ${AppStrings.endDate.tr(context)}';
    } else if (!isDateBeforeAnother(
      startDate,
      value,
      formatString: formatString,
    )) {
      return AppStrings.endDateAfterStartDate.tr(context);
    }
    return null;
  }

  static String? markValidator(String? value, BuildContext context) {
    final bool validNumber = RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value ?? '');
    if (value?.isEmpty == true || value == null) {
      return '${AppStrings.mustHaveValue.tr(context)} ${AppStrings.mark.tr(context)}';
    } else if (!validNumber || value == '0') {
      return AppStrings.pleaseEnterValidMark.tr(context);
    }
    return null;
  }

  static String? markValidatorWithLimit(
    String? value,
    BuildContext context,
    int limit,
  ) {
    final bool validNumber = RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value ?? '');
    if (value?.isEmpty == true || value == null) {
      return '${AppStrings.mustHaveValue.tr(context)} ${AppStrings.mark.tr(context)}';
    } else if (!validNumber) {
      return AppStrings.pleaseEnterValidMark.tr(context);
    } else if (double.parse(value) > limit) {
      return '${AppStrings.markMustBeLessThan.tr(context)} $limit';
    }
    return null;
  }

  static String? valueValidatorWithLimit(
    String? value,
    BuildContext context,
    int limit,
  ) {
    final bool validNumber = RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value ?? '');
    if (value?.isEmpty == true || value == null) {
      return '${AppStrings.mustHaveValue.tr(context)} ${AppStrings.mark.tr(context)}';
    } else if (!validNumber) {
      return AppStrings.pleaseEnterValidMark.tr(context);
    } else if (double.parse(value) > limit) {
      return '${AppStrings.percentageMustBeLessThan.tr(context)} $limit';
    }
    return null;
  }

  static String? scheduleDateValidator(
    String? value,
    BuildContext context,
    String startDate,
  ) {
    if (isDateAfterAnother(value ?? '', startDate)) {
      return AppStrings.scheduleDateBeforeStartData.tr(context);
    }
    return null;
  }

  static String? realUrlValidator(String? value, BuildContext context) {
    final bool urlValidate = RegExp(
      r'^(https?:\/\/)?'
      r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})'
      r'(\/[^\s]*)?'
      r'(\?[^\s]*)?'
      r'(#\w+)?$',
      caseSensitive: false,
    ).hasMatch(value ?? '');
    if (value?.isEmpty == true) {
      return AppStrings.enterUrl.tr(context);
    }
    if (!urlValidate) {
      return AppStrings.enterValidUrl.tr(context);
    } else {
      return null;
    }
  }

  static String? validateNumberAcceptNullValue(String? value) {
    // Regular expression to match valid integers or decimal numbers
    final RegExp numberRegExp = RegExp(r'^-?\d+(\.\d+)?$');

    if (!numberRegExp.hasMatch(value ?? '1')) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (value == '0') {
      return 'Please enter a valid number';
    }

    // Regular expression to match valid integers or decimal numbers
    final RegExp numberRegExp = RegExp(r'^-?\d+(\.\d+)?$');

    if (!numberRegExp.hasMatch(value)) {
      return 'Please enter a valid number';
    }

    return null;
  }

  static String? videoLinkValidator(String? value, BuildContext context) {
    final bool isUrlYouTubeValidate = RegExp(
      r'(https?://)?(www\.)?youtube\.com/watch\?v=[\w-]{11}|(https?://)?(www\.)?youtu\.be/[\w-]{11}',
    ).hasMatch(value ?? '');
    final bool urlVimeoValidate = RegExp(
      r'https?:\/\/(www\.)?vimeo\.com\/(\d+)(?:$|\/|\?)',
    ).hasMatch(value ?? '');
    if (value?.isEmpty == true) {
      return '${AppStrings.mustHaveValue.tr(context)} ${AppStrings.link.tr(context)}';
    }
    if (!isUrlYouTubeValidate && !urlVimeoValidate) {
      return AppStrings.enterValidVideoUrl.tr(context);
    } else {
      return null;
    }
  }

  static String? testTate(
    String? value,
    BuildContext context,
    String startDate,
  ) {
    if (!isDateBeforeAnother(startDate, value ?? '')) {
      return AppStrings.endDateAfterStartDate.tr(context);
    }
    return null;
  }

  static String? gradeMarkValidatorWithLimit(
    String? value,
    BuildContext context,
    int limit,
  ) {
    final bool validNumber = RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(value ?? '');
    if (value?.isEmpty == true || value == null) {
      return null;
    } else if (!validNumber) {
      return AppStrings.pleaseEnterValidMark.tr(context);
    } else if (double.parse(value) > limit) {
      return '${AppStrings.markMustBeLessThan.tr(context)} $limit';
    }
    return null;
  }

  static String? appHtmlEditorValidator(
    String? value,
    BuildContext context,
    String filedName,
  ) {
    if (value?.isEmpty == true ||
        value == null ||
        value.trim().isEmpty ||
        value == '<p></p>' ||
        value == '<p><br></p>' ||
        value == '<p><br/></p>' ||
        value == '<br>') {
      return '${AppStrings.mustHaveValue.tr(context)} ${filedName.tr(context)}';
    }
    return null;
  }
}

class ValidatorText extends StatelessWidget {
  const ValidatorText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 7, start: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: Theme.of(context).inputDecorationTheme.errorStyle),
        ],
      ),
    );
  }
}
