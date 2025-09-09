import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../widgets/teachers_screen_body.dart';

class TeachersScreen extends StatelessWidget { 
  const TeachersScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    List<dynamic> args = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
    final bool isFav = args.isNotEmpty ? args[0] as bool : false;
    return  Scaffold(
      backgroundColor: AppColors.offlineWhite,
      body: TeachersScreenBody(),
      floatingActionButton: isFav ? null : AddTeacherFloatingActionButton(),
    );
  }
}

class AddTeacherFloatingActionButton extends StatelessWidget {
  const AddTeacherFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.isAdmin) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: RawMaterialButton(
        onPressed: () {
          context.navigateTo(pageName: AppRoutes.addTeachersScreen,arguments: [null]).then(
                (value) {
              if (value == true) {

              }
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        fillColor: AppColors.myAppColor,
        splashColor: AppColors.myAppColor.withValues(alpha: 0.2),
        highlightColor: AppColors.myAppColor,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints.tightFor(width: 60.0, height: 60.0),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28.sp,
        ),
      ),
    );
  }
}
