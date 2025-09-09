import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/students/presentation/widgets/student_item.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../manager/students_cubit/students_cubit.dart';

class StudentsList extends StatelessWidget {
  const StudentsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsCubit, StudentsState>(
      buildWhen: (previous, current) => current is StudentsSearchUpdatedState,
      builder: (context, state) {
        final cubit = StudentsCubit.get(context);
        return StreamBuilder<QuerySnapshot>(
          stream: cubit.getStudentsStream(searchQuery: cubit.searchQuery),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: ServerErrorWidget(errorMessage: snapshot.error.toString()),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return ListEmptyWidget(
                icon: 'assets/images/students.png',
                title: AppStrings.noStudents,
                description: AppStrings.noStudentDescription,
              );
            }

            final students = snapshot.data!.docs
                .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
                .toList();

            return AnimationLimiter(
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListItemAnimation(
                    index: index,
                    child: StudentItem(userModel: student),
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