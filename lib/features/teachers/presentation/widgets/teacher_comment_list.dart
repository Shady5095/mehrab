import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import 'package:mehrab/features/teachers/data/models/teacher_comment_model.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/manager/teacher_profile_cubit/teacher_profile_cubit.dart';
import 'package:mehrab/features/teachers/presentation/widgets/teacher_comment_item.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import 'add_comment_dialog.dart';

class TeacherCommentList extends StatelessWidget {
  final TeacherModel model;

  const TeacherCommentList({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
      buildWhen: (oldState, newState) => newState is RateTeacherSuccessState,
      builder: (context, state) {
        return FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(model.uid)
                  .collection('comments')
                  .orderBy("timestamp", descending: true)
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
                    icon: AppAssets.teacherComments,
                    title: AppStrings.noComments,
                    description: AppStrings.noCommentsDescription,
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (newContext) => AddCommentDialog(
                              oldContext: context,
                              teacherUid: model.uid,
                              oldComment: null,
                              oldRating: null,
                            ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_comment_outlined,
                          color: AppColors.myAppColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 5),
                        Text(
                          AppStrings.addComment.tr(context),
                          style: TextStyle(
                            color: AppColors.myAppColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            // build the comments list
            final comments =
                snapshot.data!.docs
                    .map(
                      (doc) => TeacherCommentsModel.fromJson(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList();

            // separate my comment (if exists) from others
            TeacherCommentsModel? myComment;
            final otherComments = <TeacherCommentsModel>[];

            for (var c in comments) {
              if (c.userUid == currentUserModel?.uid) {
                myComment = c;
              } else {
                otherComments.add(c);
              }
            }

            // reorder so my comment is first if it exists
            final orderedComments = [
              if (myComment != null) myComment,
              ...otherComments,
            ];

            // from all comments make a TeacherCommentsModel variable if you have a comment with your uid set the model if not make it null
            TeacherCommentsModel? myCommentModel = comments.firstWhere(
              (comment) => comment.userUid == currentUserModel?.uid,
              orElse:
                  () => TeacherCommentsModel(
                    userUid: '',
                    comment: '',
                    rating: 0.0,
                    timestamp: Timestamp.now(),
                    teacherUid: '',
                    commentId: '',
                    userImage: '',
                    userName: '',
                  ),
            );

            return Column(
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (newContext) => AddCommentDialog(
                            oldContext: context,
                            teacherUid: model.uid,
                            oldComment: myCommentModel.comment,
                            oldRating: myCommentModel.rating.toDouble(),
                          ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_comment_outlined,
                        color: AppColors.myAppColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 5),
                      Text(
                        AppStrings.addComment.tr(context),
                        style: TextStyle(
                          color: AppColors.myAppColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.separated(
                      separatorBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: const Divider(),
                          ),
                      itemCount: orderedComments.length,
                      itemBuilder: (context, index) {
                        final comment = orderedComments[index];
                        return ListItemAnimation(
                          index: index,
                          child: TeacherCommentItem(model: comment),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
