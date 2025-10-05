import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/shimmer_rectangle_widget.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/widgets/my_cached_image_widget.dart';

class UserNameAndPhotoWidget extends StatelessWidget {
  const UserNameAndPhotoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cubit.userModel == null
                  ? ShimmerRectangleWidget(
                    width: 150.sp,
                    height: 20.sp,
                    borderRadius: BorderRadius.circular(10),
                  )
                  : Text(
                    "${AppStrings.hello.tr(context)} ${cubit.userModel?.name.firstName ?? ''}",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              InkWell(
                onTap: () {
                  if (!context.mounted ||
                      HomeCubit.instance(context).userModel == null) {
                    return;
                  }
                  if (currentUserModel?.userRole == "teacher") {
                    context
                        .navigateTo(
                      pageName: AppRoutes.myProfileScreenTeacher,
                      arguments: [HomeCubit.instance(context).teacherModel],
                    )
                        .then((value) {
                      if (value == true) {
                        if (!context.mounted) {
                          return;
                        }
                        HomeCubit.instance(context).userModel = null;
                        HomeCubit.instance(context).teacherModel = null;
                        HomeCubit.instance(context).getUserData(context);
                      }
                    });
                  }else{
                    context
                        .navigateTo(
                      pageName: AppRoutes.myProfileRoute,
                      arguments: [HomeCubit.instance(context).userModel],
                    )
                        .then((value) {
                      if (value == true) {
                        if (!context.mounted) {
                          return;
                        }
                        HomeCubit.instance(context).userModel = null;
                        HomeCubit.instance(context).getUserData(context);
                      }
                    });
                  }
                },
                child: Hero(tag: "myProfile" ,child: buildPhoto(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPhoto(BuildContext context) {
    final cubit = HomeCubit.instance(context);
    if (cubit.userModel == null) {
      return ShimmerCircleWidget(radius: 30.sp);
    } else if (cubit.userModel?.imageUrl != null) {
      return Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: MyCachedNetworkImage(
          width: 60.sp,
          height: 60.sp,
          fit: BoxFit.cover,
          imageUrl: cubit.userModel!.imageUrl!,
          borderRadius: BorderRadius.circular(50),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 30.sp,
        backgroundColor: context.backgroundColor,
        child: Image.asset(AppAssets.profilePlaceholder),
      );
    }
  }
}
