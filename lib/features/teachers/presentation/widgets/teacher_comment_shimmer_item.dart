import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import '../../../../core/widgets/shimmer_rectangle_widget.dart';

class TeacherCommentShimmerItem extends StatelessWidget {
  const TeacherCommentShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCircleWidget(radius: 27.sp),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerRectangleWidget(
                      width: double.infinity,
                      height: 14.sp,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ShimmerCircleWidget(radius: 8.5.sp),
                        SizedBox(width: 2),
                        ShimmerCircleWidget(radius: 8.5.sp),
                        SizedBox(width: 2),
                        ShimmerCircleWidget(radius: 8.5.sp),
                        SizedBox(width: 2),
                        ShimmerCircleWidget(radius: 8.5.sp),
                        SizedBox(width: 2),
                        ShimmerCircleWidget(radius: 8.5.sp),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 7),
              ShimmerRectangleWidget(
                width: 60.sp,
                height: 12.sp,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          SizedBox(height: 7),
          ShimmerRectangleWidget(
            width: double.infinity,
            height: 14.sp,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}