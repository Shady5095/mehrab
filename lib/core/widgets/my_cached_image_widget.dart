import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';

class MyCachedNetworkImage extends StatelessWidget {
  final String imageUrl;

  final BoxFit? fit;

  final BorderRadius? borderRadius;

  const MyCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.borderRadius,
    this.width,
    this.height,
    this.loadingIndicatorColor,
    this.errorBuilderWidget,
  });

  final double? width;
  final double? height;
  final Color? loadingIndicatorColor;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilderWidget;

  Widget loadingBuilder(
    BuildContext? context,
    Widget? child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: CircularProgressIndicator(
          color: loadingIndicatorColor ?? AppColors.myAppColor,
          value:
              loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
        ),
      ),
    );
  }

  static Widget errorBuilder(
    BuildContext? context,
    Object? exception,
    StackTrace? stackTrace,
  ) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[300],
        size: 25.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Image(
        height: height,
        fit: fit ?? BoxFit.cover,
        width: width ?? double.infinity,
        errorBuilder: errorBuilderWidget ?? errorBuilder,
        loadingBuilder: loadingBuilder,

        image: CachedNetworkImageProvider(imageUrl),
      ),
    );
  }
}
