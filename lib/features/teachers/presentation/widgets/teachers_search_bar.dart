import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/features/teachers/presentation/manager/teachers_cubit/teachers_cubit.dart';

class TeacherSearchBar extends StatelessWidget {
  const TeacherSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = TeachersCubit.get(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 45,
        child: SearchBar(
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),

          controller: cubit.searchController,
          hintStyle: WidgetStateProperty.all(
            TextStyle(color: context.invertedColor, fontSize: 13.sp),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(color: context.invertedColor, fontSize: 13.sp),
          ),
          trailing: [
            IconButton(
              onPressed: () {
                cubit.clearSearchText();
              },
              icon: const Icon(Icons.close),
            ),
          ],
          backgroundColor: WidgetStateProperty.all(Colors.white),
          hintText: AppStrings.search.tr(context),
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          leading:  Icon(Icons.search_outlined, size: 20.sp),
          onSubmitted: (value) {
            cubit.setSearchText(value);
          },
        ),
      ),
    );
  }
}