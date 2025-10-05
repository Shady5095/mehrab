import 'package:flutter/material.dart';

import '../../../../../core/utilities/resources/assets.dart';
import '../../../../../core/widgets/my_cached_image_widget.dart';

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
            borderRadius: BorderRadius.circular(120),
          ),
        ),
      ],
    );
  }
}
