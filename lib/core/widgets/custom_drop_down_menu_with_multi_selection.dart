import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/waiting_indicator.dart';

import '../utilities/functions/is_dark_mode.dart';
import '../utilities/resources/colors.dart';
import '../utilities/resources/strings.dart';
import 'my_text_field.dart';

class CustomDropDownMenuWithMultiSelection extends StatefulWidget {
  const CustomDropDownMenuWithMultiSelection({
    super.key,
    this.menuWidth,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    this.isTranslateText = false,
    this.enabled = true,
    required this.label,
    required this.itemsIds,
    this.hint,
    this.isLoadingState = false,
    this.suffixIcon,
  });

  final double? menuWidth;
  final List<String> items;
  final List<int> itemsIds;
  final bool isTranslateText;
  final List<int>? value;
  final Function(List<int>? value) onChanged;
  final String? Function(String?)? validator;
  final String label;
  final String? hint;
  final bool enabled;
  final bool isLoadingState;
  final Widget? suffixIcon;

  @override
  State<CustomDropDownMenuWithMultiSelection> createState() =>
      _CustomDropDownMenuWithMultiSelectionState();
}

class _CustomDropDownMenuWithMultiSelectionState
    extends State<CustomDropDownMenuWithMultiSelection> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late List<bool> checkBoxValues;
  final List<String> selectedItemsName = [];
  final List<int> selectedItemsIds = [];
  final GlobalKey _textFieldKey = GlobalKey();
  late int itemsLength;

  void _showPopupMenu(BuildContext context) {
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Use custom width if provided, otherwise use the width of the TextFormField
    final double menuWidth = widget.menuWidth ?? size.width;

    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: context.chatColor,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx,
        offset.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: '',
          enabled: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 30.hR),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: StatefulBuilder(
                  builder: (
                    BuildContext context,
                    void Function(void Function()) setState,
                  ) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(itemsLength, (index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 40,
                                child: CheckboxListTile(
                                  title: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(
                                      AppStrings.selectAll.tr(context),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: context.invertedColor,
                                      ),
                                    ),
                                  ),
                                  value: checkBoxValues[index],
                                  onChanged: (value) {
                                    addOrDeleteData(value, index);
                                    setState(() {
                                      checkBoxValues[index] = value!;
                                    });
                                    widget.onChanged(selectedItemsIds);
                                    setControllerText(context);
                                  },
                                ),
                              ),
                              const SizedBox(height: 5),
                              Divider(
                                color:
                                    isDarkMode(context)
                                        ? Colors.grey[800]
                                        : Colors.black45,
                                height: 1,
                              ),
                            ],
                          );
                        }

                        return SizedBox(
                          height: index == itemsLength - 1 ? 50 : 40,
                          child: CheckboxListTile(
                            title: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              widget.isTranslateText
                                  ? widget.items[index - 1].tr(context)
                                  : widget.items[index - 1],
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: context.invertedColor,
                              ),
                            ),
                            value: checkBoxValues[index],
                            onChanged: (value) {
                              addOrDeleteData(value, index);
                              setState(() {
                                checkBoxValues[index] = value!;
                              });
                              widget.onChanged(selectedItemsIds);
                              setControllerText(context);
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: 30.hR,
      ),
    );
  }

  void setControllerText(BuildContext context) {
    widget.isTranslateText
        ? _controller.text = selectedItemsName
            .map((e) => e.tr(context))
            .join(', ')
        : _controller.text = selectedItemsName.join(', ');
  }

  void addOrDeleteData(bool? value, int index) {
    if (index == 0) {
      final int length = itemsLength;
      addOrRemoveInFristIndex(value, length);
    } else {
      final int classesIndex = index - 1;
      addOrRemoveInNormalItem(value, classesIndex);
    }
  }

  void addOrRemoveInNormalItem(bool? value, int classesIndex) {
    if (value == true) {
      if (widget.items.length == 1) {
        checkBoxValues.first = true;
      }
      selectedItemsName.add(widget.items[classesIndex]);
      selectedItemsIds.add(widget.itemsIds[classesIndex]);
    } else {
      checkBoxValues.first = false;
      selectedItemsName.remove(widget.items[classesIndex]);
      selectedItemsIds.remove(widget.itemsIds[classesIndex]);
    }
  }

  void addOrRemoveInFristIndex(bool? value, int length) {
    if (value == true) {
      selectedItemsName.clear();
      selectedItemsIds.clear();
      checkBoxValues = List.filled(length, true);
      selectedItemsIds.addAll(widget.itemsIds);
      selectedItemsName.addAll(widget.items);
    } else {
      selectedItemsName.clear();
      selectedItemsIds.clear();
      checkBoxValues = List.filled(length, false);
    }
  }

  bool get isLoading {
    return widget.items.isEmpty && widget.isLoadingState;
  }

  @override
  void didUpdateWidget(
    covariant CustomDropDownMenuWithMultiSelection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.value?.isEmpty == true) {
        resetData();
      }

      // Handle value transitioning from null to non-null
      if (oldWidget.value == null && widget.value != null) {
        resetData(); // Clear previous data
        setupOldValues(); // Rebuild selected values
        setControllerText(context); // Update displayed text
      }

      if (oldWidget.value?.length != widget.value?.length &&
          oldWidget.value?.isNotEmpty == true) {
        resetData();
        setupOldValues();
        setControllerText(context);
      }

      if (oldWidget.items.length != widget.items.length) {
        itemsLength = widget.items.length + 1;
        checkBoxValues = List.filled(widget.items.length + 1, false);
      }
    });
  }

  void resetData() {
    selectedItemsName.clear();
    selectedItemsIds.clear();
    checkBoxValues = List.filled(widget.items.length + 1, false);
    _controller.clear();
  }

  @override
  void initState() {
    super.initState();
    setupValues();
  }

  void setupValues() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    checkBoxValues = List.filled(widget.items.length + 1, false);
    itemsLength = widget.items.length + 1;
    if (widget.value != null) {
      //  get index of selected items
      setupOldValues();
      setControllerText(context);
    }
  }

  void setupOldValues() {
    if (widget.value == null) {
      return;
    }
    if (widget.value?.length != widget.items.length) {
      for (int i = 0; i < widget.value!.length; i++) {
        final int index = widget.itemsIds.indexOf(widget.value![i]);
        if (index != -1) {
          checkBoxValues[index + 1] = true;
          selectedItemsName.add(widget.items[index]);
          selectedItemsIds.add(widget.itemsIds[index]);
        }
      }
    } else {
      checkBoxValues = List.filled(widget.items.length + 1, true);
      selectedItemsName.addAll(widget.items);
      selectedItemsIds.addAll(widget.itemsIds);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      onTap: () {
        if (!isLoading && widget.enabled) {
          _showPopupMenu(context);
        }
      },
      key: _textFieldKey,
      maxLines: 1,
      minLines: 1,
      contentPadding: const EdgeInsets.all(10),
      enabled: widget.enabled,
      controller: _controller,
      readOnly: true,
      validator: widget.validator,
      keyboardType: TextInputType.none,
      label: widget.label,
      hint: widget.hint,
      suffixIcon: suffixIcon,
    );
  }

  Widget get suffixIcon {
    if (isLoading) {
      return const WaitingTextFormIndicator();
    }
    if (widget.suffixIcon == null) {
      return Icon(
        Icons.keyboard_arrow_down_outlined,
        color: AppColors.blueGrey.withValues(alpha: 0.6),
        size: 20.sp,
      );
    } else {
      return widget.suffixIcon!;
    }
  }
}
