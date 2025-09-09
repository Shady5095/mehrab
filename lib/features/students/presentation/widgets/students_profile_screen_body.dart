import 'package:flutter/material.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/students/presentation/widgets/student_profile_data_widget.dart';
import 'build_student_profile_image_with_name.dart';

class StudentsProfileScreenBody extends StatefulWidget {
  final UserModel model;

  const StudentsProfileScreenBody({
    super.key,
    required this.model,
  });

  @override
  State<StudentsProfileScreenBody> createState() => _StudentsProfileScreenBodyState();
}

class _StudentsProfileScreenBodyState extends State<StudentsProfileScreenBody> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BuildStudentProfileImageWithName(
          model: widget.model,
        ),
        const SizedBox(height: 10),
        StudentProfileDataWidget(
          model: widget.model,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
