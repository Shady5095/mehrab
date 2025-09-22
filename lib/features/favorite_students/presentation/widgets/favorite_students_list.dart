import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../../../authentication/data/user_model.dart';
import 'favorite_student_item.dart';

class FavoriteStudentsList extends StatelessWidget {

  const FavoriteStudentsList({super.key,});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .collection('favoriteStudents')
              .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ServerErrorWidget(
              errorMessage: snapshot.error.toString(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListEmptyWidget(
                icon: "assets/images/student_fav.png",
                title: AppStrings.noFavStudentsTitle,
                description: AppStrings.noFavStudentsDescription,
              ),
            ],
          );
        }
        final students =
            snapshot.data!.docs
                .map(
                  (doc) => UserModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();
        return AnimationLimiter(
          child: ListView.separated(
            separatorBuilder:
                (context, index) => SizedBox(
                  height: 10,
                ),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListItemAnimation(
                index: index,
                child: FavoriteStudentItem(userModel: student),
              );
            },
          ),
        );
      },
    );
  }
}
