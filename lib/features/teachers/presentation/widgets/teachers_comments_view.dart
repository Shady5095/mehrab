import 'package:flutter/material.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_comment_list.dart';

class TeachersCommentsView extends StatelessWidget {
  final TeacherModel model;
  const TeachersCommentsView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TeacherCommentList(model: model),
    );
  }
}
