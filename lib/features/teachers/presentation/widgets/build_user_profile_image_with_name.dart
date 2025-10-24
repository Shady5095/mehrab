import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/manager/teacher_profile_cubit/teacher_profile_cubit.dart';
import '../../../../core/config/routes/adaptive_page_route.dart';
import '../../../../core/utilities/resources/assets.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/resources/styles.dart';
import '../../../../core/widgets/image_viewer.dart';

class UserProfileImageWithName extends StatelessWidget {
  const UserProfileImageWithName({super.key, required this.model});

  final TeacherModel model;

  @override
  Widget build(BuildContext context) {
    final cubit = TeacherProfileCubit.get(context);
    TeacherModel teacher = model;
    return BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
      builder: (context, state) {

        return SizedBox(
          height: 29.hR + MediaQuery.of(context).padding.top,
          child: Stack(
            children: [
              Container(
                height: 18.hR,
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
                          padding: EdgeInsets.all(10),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_sharp,
                            color: AppColors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            cubit.toggleTeacherFav(teacher.uid);
                            cubit.addStudentInTeacherCollection(teacher.uid);
                            cubit.addTeacherInStudentCollection(teacher.copyWith(
                              favoriteStudentsUid:
                              isTeacherInMyFavorites(teacher)
                                  ? (teacher.favoriteStudentsUid..remove(myUid))
                                  : (teacher.favoriteStudentsUid..add(myUid)),
                            ),);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isTeacherInMyFavorites(teacher)
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              size: 22.sp,
                              color:
                                  isTeacherInMyFavorites(teacher)
                                      ? AppColors.redColor
                                      : Colors.black54,
                            ),
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
                    height: 24.hR,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Flexible(
                          child: Hero(
                            tag: teacher.uid,
                            child: buildPhoto(context, teacher),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          textAlign: TextAlign.center,
                          teacher.name,
                          style: AppStyle.textStyle20,
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: RatingBar.builder(
                            minRating: 1,
                            unratedColor: Colors.black.withValues(alpha: 0.3),
                            itemSize: 22.sp,
                            initialRating: teacher.averageRating,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 0.0,
                            ),
                            itemBuilder:
                                (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {},
                          ),
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

  Widget buildPhoto(BuildContext context,TeacherModel teacher) {
    if (teacher.imageUrl != null) {
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
                      photo: CachedNetworkImageProvider(teacher.imageUrl!),
                      isNetworkImage: true,
                    ),
              ),
            );
          },
          child: CircleAvatar(
            radius: 9.hR,
            backgroundColor: context.backgroundColor,
            child: CircleAvatar(
              radius: 7.hR,
              backgroundImage: CachedNetworkImageProvider(teacher.imageUrl!),
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

  bool  isTeacherInMyFavorites(TeacherModel teacher) {
    if (teacher.favoriteStudentsUid.isNotEmpty) {
      return teacher.favoriteStudentsUid.contains(myUid);
    }
    return false; // Placeholder return value
  }
}
