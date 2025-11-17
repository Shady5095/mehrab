import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/shimmer_rectangle_widget.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/widgets/my_cached_image_widget.dart';

class UserNameAndPhotoWidget extends StatelessWidget {

  const UserNameAndPhotoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = HomeCubit.instance(context);
          return InkWell(
            onTap: () => _navigateToProfile(context, cubit),
            child: Hero(tag: "myProfile", child: buildPhoto(context)),
          );

      },
    );
  }

  void _navigateToProfile(BuildContext context, HomeCubit cubit) {
    if (!context.mounted || cubit.userModel == null) {
      return;
    }

    if (AppConstants.isTeacher) {
      context
          .navigateTo(
        pageName: AppRoutes.myProfileScreenTeacher,
        arguments: [cubit.teacherModel],
      )
          .then((value) {
        if (value == true) {
          if (!context.mounted) {
            return;
          }
          cubit.userModel = null;
          cubit.teacherModel = null;
          cubit.getUserData(context);
        }
      });
    } else {
      context
          .navigateTo(
        pageName: AppRoutes.myProfileRoute,
        arguments: [cubit.userModel],
      )
          .then((value) {
        if (value == true) {
          if (!context.mounted) {
            return;
          }
          cubit.currentScreenIndex = 0;
          cubit.userModel = null;
          cubit.getUserData(context);
        }
      });
    }
  }

  Widget buildPhoto(BuildContext context) {
    final cubit = HomeCubit.instance(context);

    if (cubit.userModel == null) {
      return ShimmerCircleWidget(radius: 30.sp);
    } else if (cubit.userModel?.imageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: MyCachedNetworkImage(
          width: 60.sp,
          height: 60.sp,
          fit: BoxFit.cover,
          imageUrl: cubit.userModel!.imageUrl!,
          borderRadius: BorderRadius.circular(50),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: CircleAvatar(
          radius: 30.sp,
          backgroundColor: context.backgroundColor,
          child: Image.asset(AppAssets.profilePlaceholder),
        ),
      );
    }
  }
}