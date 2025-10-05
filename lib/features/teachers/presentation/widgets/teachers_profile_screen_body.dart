import 'package:flutter/material.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/widgets/profile_data_widget.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_profile_tabs.dart';
import 'build_user_profile_image_with_name.dart';

class TeachersProfileScreenBody extends StatefulWidget {
  final TeacherModel model;

  const TeachersProfileScreenBody({
    super.key,
    required this.model,
  });

  @override
  State<TeachersProfileScreenBody> createState() => _TeachersProfileScreenBodyState();
}

class _TeachersProfileScreenBodyState extends State<TeachersProfileScreenBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserProfileImageWithName(
          model: widget.model,
        ),
        const SizedBox(height: 10),
        TeacherProfileTabs(),
        const SizedBox(height: 10),
        UserProfileData(
          model: widget.model,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
