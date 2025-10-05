import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:shimmer/shimmer.dart';

import '../utilities/resources/colors.dart';

class ShimmerRectangleWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Color? color;

  const ShimmerRectangleWidget({
    super.key,
    this.width = double.infinity,
    this.height = 10,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Theme.of(context).shadowColor,
      highlightColor: highlightColor ?? Colors.grey.shade200,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? context.containerColor,
          borderRadius: borderRadius ?? BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class ShimmerRectangleDarkColor extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerRectangleDarkColor({
    super.key,
    this.width = double.infinity,
    this.height = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.navy,
      highlightColor: AppColors.blueGrey.withValues(alpha: 0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.offlineBlue,
          borderRadius: borderRadius ?? BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class ShimmerCircleWidget extends StatelessWidget {
  final double radius;

  const ShimmerCircleWidget({super.key, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).shadowColor,
      highlightColor: Colors.grey.shade200,
      child: CircleAvatar(
        backgroundColor: context.containerColor,
        radius: radius,
      ),
    );
  }
}

class ShimmerRectangleWeeklyPlan extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerRectangleWeeklyPlan({
    super.key,
    this.width = double.infinity,
    this.height = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black12,
      highlightColor: Colors.black.withValues(alpha: 0.2),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: borderRadius ?? BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class ShimmerShapeItem extends StatelessWidget {
  const ShimmerShapeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).shadowColor,
      highlightColor: Colors.grey.shade200,
      child: Container(
        height: 45.sp,
        width: 45.sp,
        decoration: BoxDecoration(
          color: context.containerColor,
          borderRadius: const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(60),
            topStart: Radius.circular(10),
          ),
        ),
        padding: const EdgeInsetsDirectional.only(
          top: 13,
          end: 18,
          bottom: 23,
          start: 13,
        ),
      ),
    );
  }
}
