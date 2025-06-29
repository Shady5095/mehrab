import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

class HeightSizedBox extends StatelessWidget {
  const HeightSizedBox({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height.hR);
  }
}
