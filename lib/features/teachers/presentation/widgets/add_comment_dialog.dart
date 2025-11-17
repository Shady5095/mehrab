import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/core/widgets/my_text_field.dart';

import '../../../../core/utilities/functions/print_with_color.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/firebase_notification.dart';
import '../../data/models/teacher_comment_model.dart';

class AddCommentDialog extends StatefulWidget {
  final String teacherUid;
  final String? oldComment;
  final double? oldRating;
  const AddCommentDialog({super.key, required this.teacherUid, this.oldComment, this.oldRating});

  @override
  State<AddCommentDialog> createState() => _AddCommentDialogState();
}

class _AddCommentDialogState extends State<AddCommentDialog> {
  double rating = 0.0;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    if (widget.oldComment != null) {
      commentController.text = widget.oldComment!;
    }
    if (widget.oldRating != null) {
      rating = widget.oldRating!;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
      makeIosAndAndroidSameDialog: true,
      width: 75.wR,
      title: AppStrings.addComment.tr(context),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.howDoYouRateThisTeacher.tr(context),
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          RatingBar.builder(
            minRating: 0,
            unratedColor: Colors.black.withValues(alpha: 0.3),
            itemSize: 33.sp,
            initialRating: rating,
            itemPadding: const EdgeInsets.symmetric(
              horizontal: 0.0,
            ),
            itemBuilder: (context, _) =>
            const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                this.rating = rating;
              });
            },
          ),
          const SizedBox(height: 15),
          MyTextField(
            controller: commentController,
            maxLines: 4,
            minLines: 4,
            label: AppStrings.writeYourComment.tr(context),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            AppStrings.cancel.tr(context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (rating != 0.0) {
              rateTeacher(
                widget.teacherUid,
                rating,
                comment: commentController.text,
              );
              Navigator.of(context).pop();
              myToast(
                msg: AppStrings.commentAddedSuccessfully.tr(context),
                state: ToastStates.success,
              );
              CacheService.setData(key: "isThisTeacherRated-${widget.teacherUid}", value: true);
            } else {
              myToast(msg: "برجاء اختيار تقييم من 1 ل 5",
                  state: ToastStates.error);
            }
          },
          child: Text(
            AppStrings.send.tr(context),
            style: TextStyle(
              color: rating == 0.0 ? Colors.grey : AppColors.myAppColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
  Future<void> rateTeacher(String teacherUid, num newRating, {String? comment}) async {
    final userUid = currentUserModel?.uid??'';
    try {
      // Find existing comment by the user
      final commentsSnapshot =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(teacherUid)
          .collection("comments")
          .where('userUid', isEqualTo: userUid)
          .limit(1)
          .get();

      if (commentsSnapshot.docs.isNotEmpty) {
        // Update existing comment
        final commentDoc = commentsSnapshot.docs.first;
        final updatedComment = TeacherCommentsModel(
          userUid: userUid,
          teacherUid: teacherUid,
          comment: comment ?? commentDoc.data()['comment'],
          rating: newRating,
          timestamp: Timestamp.now(),
          userName: currentUserModel?.name,
          userImage: currentUserModel?.imageUrl,
          commentId: commentDoc.id,
        );
        await commentDoc.reference.update(updatedComment.toJson());
      } else {
        // Add new comment with commentId
        final commentRef =
        FirebaseFirestore.instance.collection("users").doc(teacherUid).collection("comments").doc();
        final newComment = TeacherCommentsModel(
          userUid: userUid,
          teacherUid: teacherUid,
          comment: comment,
          rating: newRating,
          timestamp: Timestamp.now(),
          userName: currentUserModel?.name,
          userImage: currentUserModel?.imageUrl,
          commentId: commentRef.id,
        );
        await commentRef.set(newComment.toJson());
      }

      // Recalculate average rating after comment is set/updated
      final allCommentsSnapshot =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(teacherUid)
          .collection("comments")
          .get();
      if (allCommentsSnapshot.docs.isNotEmpty) {
        final totalRating = allCommentsSnapshot.docs
            .map((doc) => (doc.data()['rating'] as num))
            .reduce((a, b) => a + b);
        final averageRating = totalRating / allCommentsSnapshot.docs.length;
        // Update teacher document with new average rating
        await FirebaseFirestore.instance.collection("users").doc(teacherUid).update({
          'averageRating': averageRating,
        });
      }
      rateTeacherPushNotification(teacherUid, newRating.toInt(),
          comment: comment);
      if(widget.oldRating == null){
        increaseTeacherRateCount(teacherUid);
      }
    } catch (error) {
      printWithColor(error);
    }
  }

  void rateTeacherPushNotification(
      String teacherUid,
      int rating, {
        String? comment,
      }) {
    AppFirebaseNotification.pushNotification(
      title:
      "تقييم جديد من ${currentUserModel?.name ?? ''} (${rating.toString()} نجوم)",
      body: comment ?? '',
      dataInNotification: {"type": "studentRate"},
      topic: teacherUid,
    );
  }

  Future<void> increaseTeacherRateCount(String teacherUid) async {
    try {
      FirebaseFirestore.instance.collection("users").doc(teacherUid).update({
        'rateCount': FieldValue.increment(1),
      });
    } catch (error) {
      printWithColor(error);
    }
  }
}
