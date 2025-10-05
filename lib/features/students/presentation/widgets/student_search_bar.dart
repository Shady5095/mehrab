import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';

import '../manager/students_cubit/students_cubit.dart';

class StudentSearchBar extends StatelessWidget {
  const StudentSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = StudentsCubit.get(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 45,
        child: SearchBar(
          controller: cubit.searchController,
          hintStyle: WidgetStateProperty.all(
            TextStyle(color: context.invertedColor, fontSize: 14),
          ),
          textStyle: WidgetStateProperty.all(
            TextStyle(color: context.invertedColor, fontSize: 14),
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
          leading: const Icon(Icons.search_outlined, size: 21),
          onSubmitted: (value) {
            cubit.setSearchText(value);
          },
        ),
      ),
    );
  }
}