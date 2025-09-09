import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';
import '../utilities/resources/styles.dart';

class CircleToggleButtonList extends StatefulWidget {
  final int length;
  final List<String> titles; // Titles for each button
  final Color selectedColor;
  final Color unselectedColor;
  final double size;
  final ValueChanged<int>?
  onChangeIndex; // Callback to notify when a button is selected
  final ValueChanged<String>?
  onChangeName; // Callback to notify when a button is selected
  final int? initialIndex;

  const CircleToggleButtonList({
    super.key,
    required this.length,
    required this.titles,
    this.selectedColor = AppColors.myAppColor,
    this.unselectedColor = Colors.transparent,
    this.size = 22.0,
    this.onChangeIndex,
    this.initialIndex,
    this.onChangeName,
  });

  @override
  CircleToggleButtonListState createState() => CircleToggleButtonListState();
}

class CircleToggleButtonListState extends State<CircleToggleButtonList> {
  int? selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.initialIndex;
    super.initState();
  }

  void _onToggle(int index, String name) {
    setState(() {
      selectedIndex = index;
    });
    if (widget.onChangeIndex != null) {
      widget.onChangeIndex!(
        index,
      ); // Notify the parent widget of the selected index
    }
    if (widget.onChangeName != null) {
      widget.onChangeName!(
        name,
      ); // Notify the parent widget of the selected name
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return InkWell(
          onTap: () => _onToggle(index, widget.titles[index]),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleToggleButton(
                  isSelected: selectedIndex == index,
                  selectedColor: widget.selectedColor,
                  unselectedColor: widget.unselectedColor,
                  size: widget.size,
                ),
                const SizedBox(width: 15.0),
                Text(
                  widget.titles[index].tr(context),
                  style: AppStyle.textStyle12Regular.copyWith(
                    fontSize: 14.sp,
                    color: context.invertedColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CircleToggleButton extends StatelessWidget {
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final double size;

  const CircleToggleButton({
    super.key,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10.sp,
      backgroundColor: isSelected ? selectedColor : context.invertedColor,
      child: CircleAvatar(
        radius: 8.sp,
        backgroundColor: context.backgroundColor,
        child: CircleAvatar(
          radius: 5.sp,
          backgroundColor: isSelected ? selectedColor : unselectedColor,
        ),
      ),
    );
  }
}

class CircleToggleButtonGridView extends StatefulWidget {
  final int length;
  final List<String> titles; // Titles for each button
  final Color selectedColor;
  final Color unselectedColor;
  final double size;
  final ValueChanged<int>?
  onChangeIndex; // Callback to notify when a button is selected
  final ValueChanged<String>?
  onChangeName; // Callback to notify when a button is selected
  final int? initialIndex;
  final MainAxisAlignment? mainAxisAlignment;
  final TextStyle? textStyle;
  final bool isTextTranslated;
  final double? height;

  const CircleToggleButtonGridView({
    super.key,
    required this.length,
    required this.titles,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.transparent,
    this.size = 22.0,
    this.onChangeIndex,
    this.initialIndex,
    this.onChangeName,
    this.mainAxisAlignment,
    this.textStyle,
    this.isTextTranslated = true,
    this.height,
  });

  @override
  _CircleToggleButtonGridViewState createState() =>
      _CircleToggleButtonGridViewState();
}

class _CircleToggleButtonGridViewState
    extends State<CircleToggleButtonGridView> {
  int? selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.initialIndex;
    super.initState();
  }

  // add here didUpdateWidget to check if the initialIndex is changed
  @override
  void didUpdateWidget(covariant CircleToggleButtonGridView oldWidget) {
    selectedIndex = widget.initialIndex;
    super.didUpdateWidget(oldWidget);
  }

  void _onToggle(int index, String name) {
    setState(() {
      selectedIndex = index;
    });
    if (widget.onChangeIndex != null) {
      widget.onChangeIndex!(
        index,
      ); // Notify the parent widget of the selected index
    }
    if (widget.onChangeName != null) {
      widget.onChangeName!(
        name,
      ); // Notify the parent widget of the selected name
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height, // Adjust height based on size
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          childAspectRatio: 5, // Adjust the height-to-width ratio
          crossAxisSpacing: 8.0, // Spacing between columns
          mainAxisSpacing: 8.0, // Spacing between rows
        ),
        itemCount: widget.length,
        shrinkWrap: true,
        // To make GridView take up the necessary space only
        physics: const NeverScrollableScrollPhysics(),
        // Disable scrolling in the grid
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _onToggle(index, widget.titles[index]),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment:
                    widget.mainAxisAlignment ?? MainAxisAlignment.start,
                children: [
                  CircleToggleButton(
                    isSelected: selectedIndex == index,
                    selectedColor: widget.selectedColor,
                    unselectedColor: widget.unselectedColor,
                    size: widget.size,
                  ),
                  const SizedBox(width: 15.0),
                  Text(
                    widget.isTextTranslated
                        ? widget.titles[index].tr(context)
                        : widget.titles[index],
                    style:
                        widget.textStyle ??
                        AppStyle.textStyle12Regular.copyWith(
                          fontSize: 14.sp,
                          color: context.invertedColor,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircleToggleButtonGridViewWithMultiSelection extends StatefulWidget {
  final int length;
  final List<String> titles; // Titles for each button
  final Color selectedColor;
  final Color unselectedColor;
  final double size;
  final ValueChanged<List<int>>?
  onChangeIndex; // Callback to notify when buttons are selected
  final ValueChanged<List<String>>?
  onChangeName; // Callback to notify when buttons are selected
  final List<int>? initialIndices;
  final MainAxisAlignment? mainAxisAlignment;
  final TextStyle? textStyle;
  final bool isTextTranslated;

  const CircleToggleButtonGridViewWithMultiSelection({
    super.key,
    required this.length,
    required this.titles,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.transparent,
    this.size = 22.0,
    this.onChangeIndex,
    this.onChangeName,
    this.initialIndices,
    this.mainAxisAlignment,
    this.textStyle,
    this.isTextTranslated = true,
  });

  @override
  _CircleToggleButtonGridViewWithMultiSelectionState createState() =>
      _CircleToggleButtonGridViewWithMultiSelectionState();
}

class _CircleToggleButtonGridViewWithMultiSelectionState
    extends State<CircleToggleButtonGridViewWithMultiSelection> {
  late List<int> selectedIndices;

  @override
  void initState() {
    selectedIndices = widget.initialIndices ?? [];
    super.initState();
  }

  @override
  void didUpdateWidget(
    covariant CircleToggleButtonGridViewWithMultiSelection oldWidget,
  ) {
    if (widget.initialIndices != oldWidget.initialIndices) {
      selectedIndices = widget.initialIndices ?? [];
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onToggle(int index, String name) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });

    if (widget.onChangeIndex != null) {
      widget.onChangeIndex!(List.unmodifiable(selectedIndices));
    }
    if (widget.onChangeName != null) {
      final selectedNames =
          selectedIndices.map((i) => widget.titles[i]).toList();
      widget.onChangeName!(List.unmodifiable(selectedNames));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two columns
        childAspectRatio: 5, // Adjust the height-to-width ratio
        crossAxisSpacing: 8.0, // Spacing between columns
        mainAxisSpacing: 8.0, // Spacing between rows
      ),
      itemCount: widget.length,
      shrinkWrap: true,
      // To make GridView take up the necessary space only
      physics: const NeverScrollableScrollPhysics(),
      // Disable scrolling in the grid
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _onToggle(index, widget.titles[index]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment:
                  widget.mainAxisAlignment ?? MainAxisAlignment.start,
              children: [
                CircleToggleButton(
                  isSelected: selectedIndices.contains(index),
                  selectedColor: widget.selectedColor,
                  unselectedColor: widget.unselectedColor,
                  size: widget.size,
                ),
                const SizedBox(width: 15.0),
                Text(
                  widget.isTextTranslated
                      ? widget.titles[index].tr(context)
                      : widget.titles[index],
                  style:
                      widget.textStyle ??
                      AppStyle.textStyle12Regular.copyWith(
                        fontSize: 14.sp,
                        color: context.invertedColor,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
