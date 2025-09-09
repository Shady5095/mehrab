import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/widgets/profile_data_item.dart';

import '../../../../core/utilities/resources/strings.dart';

class UserProfileData extends StatefulWidget {
  const UserProfileData({
    super.key,
    required this.model,
  });

  final TeacherModel model;
  @override
  State<UserProfileData> createState() => _UserProfileDataState();
}

class _UserProfileDataState extends State<UserProfileData> {
  late List<String?> profileDataDescriptions;
  late final List<String> profileDataTitles = [
    AppStrings.name,
    AppStrings.email,
    AppStrings.password,
    AppStrings.phone,
    AppStrings.experience,
    AppStrings.specialization,
    AppStrings.foundationalTexts,
    AppStrings.categories,
    AppStrings.tracks,
    AppStrings.compositions,
    AppStrings.curriculum,
    AppStrings.compatibility,
    AppStrings.universityDegree,
    AppStrings.igaz,
  ];

  @override
  void initState() {
    super.initState();
    _setProfileDataDescriptions();
  }

  @override
  void didUpdateWidget(covariant UserProfileData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _setProfileDataDescriptions();
    }
  }

  void _setProfileDataDescriptions() {
    profileDataDescriptions = [
      widget.model.name,
      widget.model.email,
      widget.model.password,
      widget.model.phone,
      widget.model.experience,
      widget.model.specialization,
      widget.model.foundationalTexts,
      widget.model.categories,
      widget.model.tracks,
      widget.model.compositions,
      widget.model.curriculum,
      widget.model.compatibility,
      widget.model.school,
      widget.model.igazah,

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
                  (context, index) => ProfileDataItem(
                    title: profileDataTitles[index],
                    description: profileDataDescriptions[index],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
