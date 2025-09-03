import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/waiting_indicator.dart';
import '../utilities/functions/is_dark_mode.dart';
import '../utilities/resources/colors.dart';
import '../utilities/resources/strings.dart';
import '../utilities/resources/styles.dart';
import 'height_sized_box.dart';
import 'my_text_field.dart';

class CustomDropDownMenu extends StatefulWidget {
  const CustomDropDownMenu({
    super.key,
    this.dropdownWidth,
    required this.dropdownItems,
    this.value,
    required this.onChanged,
    this.validator,
    this.isTextTranslated = false,
    this.enabled = true,
    this.isShowLoading = true,
    this.label,
    this.suffixIcon,
    this.hint,
    this.disabledBorder,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.onChangedIndex,
    this.isDense = false,
    this.contentPadding,
  });

  final double? dropdownWidth;
  final List<String> dropdownItems;
  final bool isTextTranslated;
  final String? value;
  final void Function(String? value) onChanged;
  final void Function(int? value)? onChangedIndex;
  final String? Function(String?)? validator;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool isShowLoading;
  final Widget? suffixIcon;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final AutovalidateMode autoValidateMode;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  final GlobalKey _textFieldKey = GlobalKey();

  void _showPopupMenu(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Use custom width if provided, otherwise use the width of the TextFormField
    final double menuWidth = widget.dropdownWidth ?? size.width;
    showMenu(
      context: context,
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        reverseDuration: const Duration(milliseconds: 100),
        reverseCurve: Curves.easeInOut,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: context.chatColor,
      position:
          !isRtl
              ? RelativeRect.fromLTRB(
                offset.dx,
                offset.dy + size.height,
                offset.dx,
                offset.dy,
              )
              : RelativeRect.fromLTRB(
                offset.dx - (isRtl ? menuWidth - size.width : 0),
                offset.dy + size.height,
                offset.dx + (isRtl ? menuWidth : size.width),
                offset.dy,
              ),

      items: [
        PopupMenuItem<String>(
          value: '',
          enabled: false,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 30.hR),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.dropdownItems.length,
                    (index) => PopupMenuItem<String>(
                      value: widget.dropdownItems[index],

                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widget.isTextTranslated
                            ? widget.dropdownItems[index].tr(context)
                            : widget.dropdownItems[index],
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.invertedColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      elevation: 20.0,
      shadowColor: isDarkMode(context) ? Colors.black : AppColors.blueGrey,

      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: 30.hR,
      ),
    ).then((value) {
      if (value != null) {
        widget.isTextTranslated
            ? _controller.text = value.tr(context)
            : _controller.text = value;
        if (widget.onChangedIndex != null) {
          widget.onChangedIndex!(widget.dropdownItems.indexOf(value));
        }

        widget.onChanged(value);
      }
    });
  }

  bool get isLoading {
    return widget.dropdownItems.isEmpty && widget.isShowLoading;
  }

  @override
  void didUpdateWidget(covariant CustomDropDownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.isTextTranslated
          ? _controller.text = widget.value?.tr(context) ?? ''
          : _controller.text = widget.value ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.value != null) {
        widget.isTextTranslated
            ? _controller.text = widget.value!.tr(context)
            : _controller.text = widget.value!;
      }
    });
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
      key: _textFieldKey,
      onTap: () {
        if (!isLoading && widget.enabled) {
          _showPopupMenu(context);
        }
      },
      autoValidateMode: widget.autoValidateMode,
      enabled: widget.enabled,
      controller: _controller,
      readOnly: true,
      validator: widget.validator,
      keyboardType: TextInputType.none,
      label: widget.label,
      suffixIcon: suffixIcon,
      hint: widget.hint,
      disabledBorder: widget.disabledBorder,
      errorBorder: widget.errorBorder,
      enabledBorder: widget.enabledBorder,
      focusedBorder: widget.focusedBorder,
      isDense: widget.isDense,
      contentPadding: widget.contentPadding,
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

class CustomDropDownMenu2 extends StatefulWidget {
  const CustomDropDownMenu2({
    super.key,
    this.dropdownWidth,
    required this.dropdownItems,
    this.value,
    required this.onChanged,
    this.validator,
    this.isTextTranslated = false,
    this.enabled = true,
    this.isShowLoading = true,
    required this.label,
  });

  final double? dropdownWidth;
  final List<String> dropdownItems;
  final bool isTextTranslated;
  final String? value;
  final Function(String? value) onChanged;
  final String? Function(String?)? validator;
  final String label;
  final bool enabled;
  final bool isShowLoading;

  @override
  State<CustomDropDownMenu2> createState() => _CustomDropDownMenuState2();
}

class _CustomDropDownMenuState2 extends State<CustomDropDownMenu2> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  final GlobalKey _textFieldKey = GlobalKey();

  void _showPopupMenu(BuildContext context) {
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Use custom width if provided, otherwise use the width of the TextFormField
    final double menuWidth = widget.dropdownWidth ?? size.width;
    showMenu(
      context: context,
      popUpAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        reverseDuration: const Duration(milliseconds: 100),
        reverseCurve: Curves.easeInOut,
      ),
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
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 30.hR),
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.dropdownItems.length,
                    (index) => PopupMenuItem<String>(
                      value: widget.dropdownItems[index],
                      child: Text(
                        maxLines: 2,
                        widget.isTextTranslated
                            ? widget.dropdownItems[index].tr(context)
                            : widget.dropdownItems[index],
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: context.invertedColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      elevation: 20.0,
      shadowColor: AppColors.blueGrey,

      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: 30.hR,
      ),
    ).then((value) {
      if (value != null) {
        widget.isTextTranslated
            ? _controller.text = value.tr(context)
            : _controller.text = value;
        widget.onChanged(value);
      }
    });
  }

  bool get isLoading {
    return widget.dropdownItems.isEmpty && widget.isShowLoading;
  }

  @override
  void didUpdateWidget(covariant CustomDropDownMenu2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (oldWidget.value != widget.value) {
        _controller.text = widget.value ?? '';
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    if (widget.value != null) {
      widget.isTextTranslated
          ? _controller.text = widget.value!.tr(context)
          : _controller.text = widget.value!;
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
      key: _textFieldKey,

      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.blueGrey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: context.invertedColor),
      ),

      onTap: () {
        if (!isLoading && widget.enabled) {
          _showPopupMenu(context);
        }
      },
      formTextAlign: TextAlign.center,
      contentPadding: const EdgeInsets.only(top: 10),
      enabled: widget.enabled,
      controller: _controller,
      readOnly: true,
      validator: widget.validator,
      keyboardType: TextInputType.none,
      hint: widget.label,
      suffixIcon:
          isLoading
              ? const WaitingTextFormIndicator()
              : Icon(
                Icons.keyboard_arrow_down_outlined,
                color: AppColors.blueGrey.withValues(alpha: 0.6),
                size: 20.sp,
              ),
    );
  }
}

class AppExitMenuIcon extends StatelessWidget {
  const AppExitMenuIcon({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 20,
          width: 20,
          child: Align(
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.redColor,
              child: Icon(Icons.close, color: AppColors.white, size: 15),
            ),
          ),
        ),
      ),
    );
  }
}

class MultiSelectionExpansionTile extends StatefulWidget {
  const MultiSelectionExpansionTile({
    super.key,
    required this.items,
    required this.itemsId,
    required this.onSelected,
    required this.title,
  });

  final List<String> items;
  final String title;
  final List<int> itemsId;
  final void Function(List<int>? selectedItemsId) onSelected;

  @override
  State<MultiSelectionExpansionTile> createState() =>
      _MultiSelectionExpansionTileState();
}

class _MultiSelectionExpansionTileState
    extends State<MultiSelectionExpansionTile> {
  late List<bool> checkBoxValues;

  late List<int> itemsWithAllId;
  final selectedItemsId = <int>[];
  final selectedItemsNames = <String>[];

  bool get isShowError => selectedItemsId.isEmpty;

  // this variable to show error when user click on the expansion tile

  @override
  void initState() {
    super.initState();
    checkBoxValues = List.filled(widget.items.length + 1, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isShowError ? AppColors.redColor : Colors.transparent,
            ),
          ),
          title: Padding(
            padding: const EdgeInsetsDirectional.only(start: 10),
            child: Text(
              "${widget.title.tr(context)} ${selectedItemsNames.join(" / ")}",
              style: AppStyle.textStyle14Bold,
            ),
          ),
          children: List.generate(widget.items.length + 1, (index) {
            if (index == 0) {
              return CheckboxListTile(
                title: Text(
                  '${AppStrings.all.tr(context)} ${widget.title.tr(context)} ',
                  style: AppStyle.textStyle14Bold,
                ),
                value: checkBoxValues[index],
                onChanged: (value) {
                  noChangeCheckBox(index, value);
                },
              );
            }
            return CheckboxListTile(
              title: Text(
                '${widget.items[index - 1]} ',
                style: AppStyle.textStyle14Bold,
              ),
              value: checkBoxValues[index],
              onChanged: (value) {
                noChangeCheckBox(index, value);
              },
            );
          }),
        ),
        Builder(
          builder: (context) {
            if (isShowError) {
              return Column(
                children: [
                  const HeightSizedBox(height: 0.6),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        '${AppStrings.mustHaveValue.tr(context)} ${widget.title.tr(context)}',
                        style: AppStyle.formErrorStyle,
                      ),
                    ],
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void noChangeCheckBox(int index, bool? value) {
    setState(() {
      checkBoxValues[index] = value!;
      if (index == 0) {
        onTapOnAll(value);
      } else {
        onTapOnNormalItems(value, index);
      }
    });
    widget.onSelected(selectedItemsId);
  }

  void onTapOnNormalItems(bool value, int index) {
    final int classesIndex = index - 1;
    if (value) {
      selectedItemsId.add(widget.itemsId[classesIndex]);
      selectedItemsNames.add(widget.items[classesIndex]);
    } else {
      checkBoxValues.first = false;
      selectedItemsId.remove(widget.itemsId[classesIndex]);
      selectedItemsNames.remove(widget.items[classesIndex]);
    }
  }

  void onTapOnAll(bool value) {
    final int classesLength = widget.items.length + 1;
    if (value == true) {
      selectedItemsId.clear();
      selectedItemsNames.clear();
      checkBoxValues = List.filled(classesLength, value);
      selectedItemsId.addAll(widget.itemsId);
      selectedItemsNames.addAll(widget.items);
    } else {
      checkBoxValues = List.filled(classesLength, value);
      selectedItemsId.clear();
      selectedItemsNames.clear();
    }
  }
}


class CustomDropDownMenuWithSearch extends StatefulWidget {
  const CustomDropDownMenuWithSearch({
    super.key,
    this.dropdownWidth,
    required this.dropdownItems,
    this.value,
    required this.onChanged,
    this.validator,
    this.isTextTranslated = false,
    this.enabled = true,
    this.isShowLoading = true,
    this.label,
    this.suffixIcon,
    this.hint,
    this.disabledBorder,
    this.enabledBorder,
    this.focusedBorder,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.onChangedIndex,
    this.isDense = false,
    this.contentPadding,
  });

  final double? dropdownWidth;
  final List<String> dropdownItems;
  final bool isTextTranslated;
  final String? value;
  final void Function(String? value) onChanged;
  final void Function(int? value)? onChangedIndex;
  final String? Function(String?)? validator;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool isShowLoading;
  final Widget? suffixIcon;
  final InputBorder? disabledBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final AutovalidateMode autoValidateMode;
  final bool isDense;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<CustomDropDownMenuWithSearch> createState() => _CustomDropDownMenuWithSearchState();
}

class _CustomDropDownMenuWithSearchState extends State<CustomDropDownMenuWithSearch> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  final GlobalKey _textFieldKey = GlobalKey();
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    filteredItems = widget.dropdownItems;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = widget.isTextTranslated
          ? widget.value?.tr(context) ?? ''
          : widget.value ?? '';
    });
  }

  @override
  void didUpdateWidget(covariant CustomDropDownMenuWithSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = widget.isTextTranslated
          ? widget.value?.tr(context) ?? ''
          : widget.value ?? '';
    });
  }

  void _showPopupMenu(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final RenderBox renderBox =
    _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final double menuWidth = widget.dropdownWidth ?? size.width;

    _searchController.clear();
    filteredItems = widget.dropdownItems;

    showMenu<String>(
      context: context,
      color: context.chatColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      position: !isRtl
          ? RelativeRect.fromLTRB(offset.dx, offset.dy + size.height, offset.dx, offset.dy)
          : RelativeRect.fromLTRB(offset.dx - (menuWidth - size.width), offset.dy + size.height, offset.dx + menuWidth, offset.dy),
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: 40.hR,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      filteredItems = widget.dropdownItems
                          .where((item) => (widget.isTextTranslated
                          ? item.tr(context)
                          : item)
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.search.tr(context),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 30.hR),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        filteredItems.length,
                            (index) => PopupMenuItem<String>(
                          value: filteredItems[index],
                          child: Text(
                            widget.isTextTranslated
                                ? filteredItems[index].tr(context)
                                : filteredItems[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: context.invertedColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _controller.text = widget.isTextTranslated ? value.tr(context) : value;
        widget.onChanged(value);
        if (widget.onChangedIndex != null) {
          widget.onChangedIndex!(widget.dropdownItems.indexOf(value));
        }
      }
    });
  }

  bool get isLoading => widget.dropdownItems.isEmpty && widget.isShowLoading;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      key: _textFieldKey,
      onTap: () {
        if (!isLoading && widget.enabled) {
          _showPopupMenu(context);
        }
      },
      autoValidateMode: widget.autoValidateMode,
      enabled: widget.enabled,
      controller: _controller,
      readOnly: true,
      validator: widget.validator,
      keyboardType: TextInputType.none,
      label: widget.label,
      suffixIcon: suffixIcon,
      hint: widget.hint,
      disabledBorder: widget.disabledBorder,
      enabledBorder: widget.enabledBorder,
      focusedBorder: widget.focusedBorder,
      isDense: widget.isDense,
      contentPadding: widget.contentPadding,
    );
  }

  Widget get suffixIcon {
    if (isLoading) {
      return const WaitingTextFormIndicator();
    }
    return widget.suffixIcon ??
        Icon(
          Icons.keyboard_arrow_down_outlined,
          color: AppColors.blueGrey.withValues(alpha: 0.6),
          size: 20.sp,
        );
  }
}
