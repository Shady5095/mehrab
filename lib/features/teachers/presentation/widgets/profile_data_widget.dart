import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/widgets/profile_data_item.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_sessions_in_profile.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teachers_comments_view.dart';

import '../../../../core/utilities/resources/strings.dart';
import '../manager/teacher_profile_cubit/teacher_profile_cubit.dart';

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
    if(AppConstants.isAdmin)
    AppStrings.phone,
    AppStrings.experience,
    AppStrings.igaz,
    AppStrings.specialization,
    AppStrings.foundationalTexts,
    AppStrings.categories,
    AppStrings.tracks,
    AppStrings.compositions,
    AppStrings.curriculum,
    AppStrings.compatibility,
    AppStrings.universityDegree,
    AppStrings.nationality,
    if(AppConstants.isAdmin)
    AppStrings.email,
    if(AppConstants.isAdmin)
    AppStrings.password,
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
      if(AppConstants.isAdmin)
      widget.model.phone,
      "${widget.model.experience} عاما",
      widget.model.igazah,
      widget.model.specialization,
      widget.model.foundationalTexts,
      widget.model.categories,
      widget.model.tracks,
      widget.model.compositions,
      widget.model.curriculum,
      widget.model.compatibility,
      widget.model.school,
      widget.model.nationality,
      if(AppConstants.isAdmin)
      widget.model.email,
      if(AppConstants.isAdmin)
      widget.model.password,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cubit = TeacherProfileCubit.get(context);
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
            child: PageView(
              controller: cubit.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListView.builder(
                  itemCount: profileDataTitles.length,
                  itemBuilder:
                      (context, index) => ProfileDataItem(
                        title: profileDataTitles[index],
                        description: profileDataDescriptions[index],
                        igazPdfUrl: widget.model.igazPdfUrl,
                      ),
                ),
                TeachersCommentsView(model: widget.model,),
                TeacherSessionsInProfileView(model: widget.model,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
