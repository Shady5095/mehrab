import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';

import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/teacher_bottom_sheet_design.dart';
import 'delete_teacher_dialog.dart';

class TeachersBottomSheetActions extends StatelessWidget {
  final TeacherModel teacherModel;
  final Function(dynamic value)? onFinish;
  final BuildContext oldContext;

  const TeachersBottomSheetActions({
    super.key,
    required this.teacherModel,
    this.onFinish,
    required this.oldContext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: oldContext.read<TeachersCubit>(),
      child: BlocBuilder<TeachersCubit, TeachersState>(
        builder: (context, state) {
          return MyBottomSheetDesign(
            children: [
              BottomSheetItem(
                onTap: () {
                  Navigator.pop(context);
                  context
                      .navigateTo(
                        pageName: AppRoutes.addTeachersScreen,
                        arguments: [teacherModel],
                      )
                      .then((value) {
                        if (value != null && onFinish != null) {
                          onFinish!(value);
                        }
                      });
                },
                icon: Icons.edit,
                title: AppStrings.edit.tr(context),
              ),
              BottomSheetItem(
                onTap: () {
                  Navigator.pop(context);
                  context.read<TeachersCubit>().changeTeacherAvailability(teacherModel);
                },
                icon: Icons.toggle_off_outlined,
                title: teacherModel.isOnline
                    ? "تحويل المعلم الي غير متاح"
                    : "تحويل المعلم الي متاح",
              ),
              BottomSheetItem(
                onTap: () {
                  Navigator.pop(context);
                  showDialog(context: context, builder: (context)=>TeacherDeleteConfigurationDialog(teacherModel: teacherModel,));

                },
                icon: Icons.delete,
                title: AppStrings.delete.tr(context),
                titleColor: AppColors.redColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
