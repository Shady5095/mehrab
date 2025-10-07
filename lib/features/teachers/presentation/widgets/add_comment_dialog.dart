import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/core/widgets/my_text_field.dart';

import '../manager/teacher_profile_cubit/teacher_profile_cubit.dart';

class AddCommentDialog extends StatefulWidget {
  final BuildContext oldContext;
  final String teacherUid;
  final String? oldComment;
  final double? oldRating;
  const AddCommentDialog({super.key, required this.oldContext, required this.teacherUid, this.oldComment, this.oldRating});

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
    return BlocProvider.value(
      value: TeacherProfileCubit.get(widget.oldContext),
      child: BlocConsumer<TeacherProfileCubit, TeacherProfileState>(
        listener: (context, state) {
          if (state is RateTeacherSuccessState) {
            Navigator.of(context).pop();
            myToast(
              msg: AppStrings.commentAddedSuccessfully.tr(context),
              state: ToastStates.success,
            );
          }
          if (state is RateTeacherErrorState) {
            myToast(
              msg: state.error,
              state: ToastStates.success,
            );
          }
        },
        builder: (context, state) {
          final cubit = TeacherProfileCubit.get(context);
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
                if(state is RateTeacherLoadingState)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LinearProgressIndicator(),
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
                    cubit.rateTeacher(
                      widget.teacherUid,
                      rating,
                      comment: commentController.text,
                    );
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
        },
      ),
    );
  }
}
