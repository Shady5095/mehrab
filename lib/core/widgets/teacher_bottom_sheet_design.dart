
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';

class MyBottomSheetDesign extends StatelessWidget {
  const MyBottomSheetDesign({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FirstBottomSheetItem(),
              ...children,
              SizedBox(height: 2.hR),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSheetItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final Color? titleColor;
  final bool isLoading;

  const BottomSheetItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    this.titleColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: titleColor ?? context.invertedColor,
                size: 22.sp,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? context.invertedColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirstBottomSheetItem extends StatelessWidget {
  const FirstBottomSheetItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[500],
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
