import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/features/teachers/data/models/teacher_comment_model.dart';

import '../../../../core/utilities/functions/format_date_and_time.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/widgets/my_cached_image_widget.dart';

class MyReviewsItem extends StatelessWidget {
  final TeacherCommentsModel model;

  const MyReviewsItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      child: buildMyComment(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildUserItemPhoto(
                  imageUrl: model.userImage,
                  radius: 27.sp,
                  imageColor: AppColors.myAppColor.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.userName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      RatingBar.builder(
                        minRating: 1,
                        unratedColor: Colors.black.withValues(alpha: 0.3),
                        itemSize: 17.sp,
                        initialRating: model.rating.toDouble(),
                        allowHalfRating: true,
                        ignoreGestures: true,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        itemBuilder:
                            (context, _) => Icon(Icons.star, color: Colors.amber,size: 17.sp,),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  formatDate(context, model.timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if(model.comment != null)
              SizedBox(height: 7),
            Text(
              model.comment ?? '',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMyComment({
    required Widget child,
  }){
    if(model.userUid == myUid){
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.myAppColor.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
    }else{
      return child;
    }
  }
}
class BuildUserItemPhoto extends StatelessWidget {
  const BuildUserItemPhoto({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.imageColor,
  });

  final String? imageUrl;
  final double radius;

  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrl?.isEmpty == true || imageUrl == null) {
      return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Container(
            width: radius * 2,
            decoration: BoxDecoration(shape: BoxShape.circle, color: imageColor),
            child: const Image(image: AssetImage(AppAssets.profilePlaceholder)),
          ),
        ],
      );
    }
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Container(
          width: radius * 2,
          decoration: BoxDecoration(shape: BoxShape.circle, color: imageColor),
          child: MyCachedNetworkImage(
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            imageUrl: imageUrl!,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ],
    );
  }
}