import 'package:flutter/material.dart';

import '../../app/app_locale/app_locale.dart';
import 'back_button.dart';

class ChangeBackButtonDirection extends StatelessWidget {
  final VoidCallback? onTap;

  const ChangeBackButtonDirection({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isArabic(context) ? Alignment.topRight : Alignment.topLeft,
      child: MyBackButton(onTap: onTap),
    );
  }
}
