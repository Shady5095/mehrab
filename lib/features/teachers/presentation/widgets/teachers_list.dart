import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_item.dart';

import '../../../../core/widgets/list_empty_widget.dart';
import '../../data/models/teachers_model.dart';

class TeachersList extends StatelessWidget {
  const TeachersList({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
        ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    return StreamBuilder<QuerySnapshot>(
      stream:
          !isFav
              ? FirebaseFirestore.instance
                  .collection('users')
                  .where("userRole", isEqualTo: "teacher")
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('users').doc(myUid).collection('favoriteTeachers')
                  .where("userRole", isEqualTo: "teacher")
                  .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ServerErrorWidget(errorMessage: snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return !isFav
              ? ListEmptyWidget(
                icon: 'assets/images/teacher.png',
                title: AppStrings.teachersEmpty,
                description: AppStrings.teachersEmptyDescription,
              )
              : ListEmptyWidget(
                icon: 'assets/images/teacher.png',
                title: AppStrings.teachersFavEmpty,
                description: AppStrings.teachersEmptyFavDescription,
              );
        }

        final teachers =
            snapshot.data!.docs
                .map(
                  (doc) =>
                      TeacherModel.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList();

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return ListItemAnimation(
              index: index,
              child: TeacherItem(teacher: teacher),
            );
          },
        );
      },
    );
  }
}
