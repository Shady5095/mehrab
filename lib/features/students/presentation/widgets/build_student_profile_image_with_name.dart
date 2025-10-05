import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/students/presentation/manager/student_profile_cubit/students_profile_state.dart';
import '../../../../core/config/routes/adaptive_page_route.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/styles.dart';
import '../../../../core/widgets/image_viewer.dart';
import '../manager/student_profile_cubit/students_profile_cubit.dart';

class BuildStudentProfileImageWithName extends StatelessWidget {
  const BuildStudentProfileImageWithName({super.key, required this.model});

  final UserModel model;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsProfileCubit, StudentsProfileState>(
      builder: (context, state) {
        return SizedBox(
          height: 32.hR + MediaQuery.of(context).padding.top,
          child: Stack(
            children: [
              Container(
                height: 20.hR,
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                  color: AppColors.myAppColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(200),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_sharp,
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        if(AppConstants.isAdmin)
                        IconButton(
                          onPressed: () {
                            context.navigateTo(pageName: AppRoutes.addNotificationScreen,arguments: [model]);
                          },
                          icon: Icon(Icons.notification_add_outlined,
                            size: 28.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 25.5.hR,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Flexible(
                          child: Hero(
                            tag: model.uid,
                            child: buildPhoto(context, model),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.center,
                          model.name,
                          style: AppStyle.textStyle20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPhoto(BuildContext context,UserModel model) {
    if (model.imageUrl != null) {
      return Material(
        borderRadius: BorderRadius.circular(100),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute(
                builder:
                    (context) => ImageViewer(
                      photo: CachedNetworkImageProvider(model.imageUrl!),
                      isNetworkImage: true,
                    ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 69.sp,
            backgroundColor: context.backgroundColor,
            child: CircleAvatar(
              radius: 65.sp,
              backgroundImage: CachedNetworkImageProvider(model.imageUrl!),
            ),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 65.sp,
        backgroundColor: context.backgroundColor,
        child: Image.asset(AppAssets.profilePlaceholder),
      );
    }
  }
}
