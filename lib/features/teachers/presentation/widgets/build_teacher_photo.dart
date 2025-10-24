import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';

import '../../../../../core/utilities/resources/assets.dart';
import '../../../../../core/widgets/my_cached_image_widget.dart';

class BuildTeacherPhoto extends StatelessWidget {
  const BuildTeacherPhoto({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.imageColor,
    this.isOnline = false,
    this.isBusy = false,
    this.isFromFav = false,
  });

  final String? imageUrl;
  final double radius;

  final Color? imageColor;
  final bool isOnline ;
  final bool isBusy ;
  final bool isFromFav;

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
            if(!isFromFav)
            CircleAvatar(
              radius: 8.3,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            if(!isFromFav)
             CircleAvatar(
              radius: 7,
              backgroundColor: isBusy ? AppColors.redColor : (isOnline ? AppColors.coolGreen : Colors.grey[500]),
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
          if(!isFromFav)
          CircleAvatar(
            radius: 8.3,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          if(!isFromFav)
           CircleAvatar(
            radius: 7,
            backgroundColor: isBusy ? AppColors.redColor : (isOnline ? AppColors.coolGreen : Colors.grey[500]),
          ),
      ],
    );
  }
}
