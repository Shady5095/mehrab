import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import 'package:mehrab/features/teachers/data/models/teacher_comment_model.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/resources/styles.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import 'my_reviews_item.dart';

class MyReviewsList extends StatelessWidget {

  const MyReviewsList({super.key,});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
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
                title: AppStrings.noReviewsAndCommentsTitle,
                description: AppStrings.noReviewsAndCommentsDescription,
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

        return Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(
                      "${comments.length}",
                      style: AppStyle.textStyle18.copyWith(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.reviewsAndComments.tr(context),
                      style: AppStyle.textStyleSubtitle.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  children: [
                    Text(
                      currentTeacherModel?.averageRating.toStringAsFixed(1)??'0.0',
                      style: AppStyle.textStyle18.copyWith(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RatingBar.builder(
                      minRating: 1,
                      unratedColor: Colors.black.withValues(alpha: 0.3),
                      itemSize: 23.sp,
                      initialRating: currentTeacherModel?.averageRating.toDouble()??0,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemPadding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                      itemBuilder:
                          (context, _) => Icon(Icons.star, color: Colors.amber,size: 23.sp,),
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(
                color: Colors.black,
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
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListItemAnimation(
                      index: index,
                      child: MyReviewsItem(model: comment),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
