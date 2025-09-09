import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/presentation/manager/add_teacher_cubit/add_teacher_cubit.dart';

import '../../../../../core/utilities/functions/is_dark_mode.dart';
import '../../../../../core/utilities/resources/assets.dart';
import '../../../../../core/utilities/resources/colors.dart';
import '../../../../../core/utilities/resources/strings.dart';
import '../../../../../core/utilities/resources/styles.dart';

class AddTeacherProfilePhotoBuild extends StatelessWidget {
  const AddTeacherProfilePhotoBuild({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AddTeacherCubit.get(context);
    return BlocBuilder<AddTeacherCubit, AddTeacherState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: buildPhoto(context),
              ),
              CircleAvatar(
                radius: 15.sp,
                backgroundColor: context.backgroundColor,
              ),
              if (cubit.imageFile != null || cubit.imageUrl != null)
                CircleAvatar(
                  radius: 14.sp,
                  backgroundColor: context.backgroundColor,
                  child: SpeedDial(
                    icon: Icons.edit,
                    activeIcon: Icons.edit,
                    spacing: 3,
                    childrenButtonSize: const Size(45.0, 45.0),
                    childPadding: const EdgeInsets.all(5),
                    spaceBetweenChildren: 4,
                    direction: SpeedDialDirection.down,
                    buttonSize: const Size(40.0, 40.0),
                    overlayColor: Colors.black,
                    overlayOpacity: 0.6,
                    tooltip: 'Open Speed Dial',
                    heroTag: 'speed-dial-hero-tag',
                    elevation: 8.0,

                    animationCurve: Curves.elasticInOut,
                    children: [
                      SpeedDialChild(
                        onTap: cubit.removeCurrentImage,
                        child: Icon(Icons.close, size: 17.sp),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: AppStrings.removeCurrentPhoto.tr(context),
                        labelBackgroundColor:
                        isDarkMode(context)
                            ? Colors.grey[900]
                            : const Color.fromRGBO(192, 192, 192, 1.0),
                        labelShadow: [
                          const BoxShadow(color: Colors.transparent),
                        ],
                        shape: const StadiumBorder(),
                        elevation: 0,
                        labelStyle: AppStyle.textStyle14.copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                      SpeedDialChild(
                        onTap: () {
                          cubit.pickProfileImage(context);
                        },
                        child: Icon(Icons.add_a_photo_outlined, size: 17.sp),
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        label: AppStrings.addNewPhoto.tr(context),
                        labelBackgroundColor:
                        isDarkMode(context)
                            ? Colors.grey[900]
                            : const Color.fromRGBO(192, 192, 192, 1.0),
                        labelShadow: [
                          const BoxShadow(color: Colors.transparent),
                        ],
                        shape: const StadiumBorder(),
                        elevation: 0,
                        labelStyle: AppStyle.textStyle14.copyWith(
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                )
              else
                CircleAvatar(
                  radius: 14.sp,
                  backgroundColor: context.backgroundColor,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      minimumSize: const Size(45.0, 45.0),
                      backgroundColor: AppColors.myAppColor,
                    ),
                    onPressed: () {
                      cubit.pickProfileImage(context);
                    },
                    icon: Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.white,
                      size: 14.sp,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPhoto(BuildContext context) {
    final cubit = AddTeacherCubit.get(context);
    if (cubit.imageFile != null) {
      return CircleAvatar(
        radius: 55.sp,
        backgroundImage: (FileImage(cubit.imageFile!) as ImageProvider),
      );
    } else if (cubit.imageUrl != null) {
      return CircleAvatar(
        radius: 55.sp,
        backgroundColor: context.backgroundColor,
        backgroundImage: CachedNetworkImageProvider(cubit.imageUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 48.sp,
        backgroundColor: context.backgroundColor,
        child: Image.asset(AppAssets.profilePlaceholder),
      );
    }
  }
}
