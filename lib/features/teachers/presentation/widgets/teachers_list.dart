import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_item.dart';

import '../../../../core/widgets/list_empty_widget.dart';
import '../../data/models/teachers_model.dart';

class TeachersList extends StatelessWidget {
  const TeachersList({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;

    return BlocBuilder<TeachersCubit, TeachersState>(
      buildWhen: (previous, current) => current is TeachersSearchUpdatedState,
      builder: (context, state) {
        final cubit = TeachersCubit.get(context);
        return StreamBuilder<QuerySnapshot>(
          stream: cubit.getTeachersStream(isFav: isFav, searchQuery: cubit.searchQuery),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: ServerErrorWidget(errorMessage: snapshot.error.toString()),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return isFav
                  ? ListEmptyWidget(
                icon: 'assets/images/teacher.png',
                title: AppStrings.teachersFavEmpty,
                description: AppStrings.teachersEmptyFavDescription,
              )
                  : ListEmptyWidget(
                icon: 'assets/images/teacher.png',
                title: AppStrings.teachersEmpty,
                description: AppStrings.teachersEmptyDescription,
              );
            }

            final teachers = snapshot.data!.docs
                .map((doc) => TeacherModel.fromJson(doc.data() as Map<String, dynamic>))
                .toList();

            return AnimationLimiter(
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: teachers.length,
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  return ListItemAnimation(
                    index: index,
                    child: TeacherItem(teacher: teacher),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}