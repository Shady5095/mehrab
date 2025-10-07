import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/students/presentation/widgets/student_profile_data_item.dart';

import '../../../../core/utilities/resources/strings.dart';

class StudentProfileDataWidget extends StatefulWidget {
  const StudentProfileDataWidget({
    super.key,
    required this.model,
  });

  final UserModel model;
  @override
  State<StudentProfileDataWidget> createState() => _StudentProfileDataWidgetState();
}

class _StudentProfileDataWidgetState extends State<StudentProfileDataWidget> {
  late List<String?> profileDataDescriptions;
  late final List<String> profileDataTitles = [
    AppStrings.name,
    if(AppConstants.isAdmin)
    AppStrings.email,
    if(AppConstants.isAdmin)
    AppStrings.password,
    if(AppConstants.isAdmin)
    AppStrings.phone,
    AppStrings.nationality,
    AppStrings.educationLevel,
  ];

  @override
  void initState() {
    super.initState();
    _setProfileDataDescriptions();
  }

  @override
  void didUpdateWidget(covariant StudentProfileDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _setProfileDataDescriptions();
    }
  }

  void _setProfileDataDescriptions() {
    profileDataDescriptions = [
      widget.model.name,
      if(AppConstants.isAdmin)
      widget.model.email,
      if(AppConstants.isAdmin)
      widget.model.password,
      if(AppConstants.isAdmin)
        widget.model.phoneNumber.isEmpty  ? null : "${widget.model.countryCodeNumber.replaceAll('+', '')}${widget.model.phoneNumber}",
      widget.model.nationality,
      widget.model.educationalLevel,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 5,
          color: context.backgroundColor,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ListView.builder(
              itemCount: profileDataTitles.length,
              itemBuilder:
                  (context, index) {
                bool isLastTwoItems = index == profileDataTitles.length - 1 || index == profileDataTitles.length - 2;
                    return StudentProfileDataItem(
                title: profileDataTitles[index],
                description: isLastTwoItems ? profileDataDescriptions[index]?.tr(context) : profileDataDescriptions[index],
              );
                  },
            ),
          ),
        ),
      ),
    );
  }
}
