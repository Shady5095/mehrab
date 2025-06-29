import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';

// Assuming MyCustomModel is defined elsewhere
class MyCustomModel {
  final int id;
  final String name;

  MyCustomModel({required this.id, required this.name});
}

class MultiSelectionDropDownMenuWithSearch extends StatefulWidget {
  const MultiSelectionDropDownMenuWithSearch({
    required this.hint,
    required this.dropdownItemsNames,
    required this.dropdownItemsIds,
    required this.onChangedIds,
    this.onChangedNames,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.valueAlignment,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset,
    this.validator,
    this.isTextTranslated = false,
    this.readOnly,
    this.isShowLoading = true,
    this.initialSelectedNames,
    this.initialSelectedIds,
    required this.context,
    super.key,
  });

  final String hint;
  final List<String> dropdownItemsNames;
  final List<int> dropdownItemsIds;
  final ValueChanged<List<int>?> onChangedIds;
  final ValueChanged<List<String>?>? onChangedNames;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight, buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final bool isTextTranslated;
  final Offset? offset;
  final FormFieldValidator<String>? validator;
  final bool? readOnly;
  final bool isShowLoading;
  final BuildContext context;
  final List<String>? initialSelectedNames;
  final List<int>? initialSelectedIds;

  @override
  State<MultiSelectionDropDownMenuWithSearch> createState() =>
      _MultiSelectionDropDownMenuWithSearch();
}

class _MultiSelectionDropDownMenuWithSearch
    extends State<MultiSelectionDropDownMenuWithSearch> {
  List<MyCustomModel> myCustomModelList = [];
  List<String> selectedItems = [];
  List<int> selectedItemsIds = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSelectedItems();
    putItemsInList();
  }

  void putItemsInList() {
    myCustomModelList.clear();
    for (int i = 0; i < widget.dropdownItemsNames.length; i++) {
      myCustomModelList.add(
        MyCustomModel(
          id: widget.dropdownItemsIds[i],
          name: widget.dropdownItemsNames[i],
        ),
      );
    }
  }

  void toggleSelectAll() {
    setState(() {
      if (selectedItems.length == myCustomModelList.length) {
        selectedItems.clear();
        selectedItemsIds.clear();
      } else {
        selectedItems = myCustomModelList.map((item) => item.name).toList();
        selectedItemsIds = myCustomModelList.map((item) => item.id).toList();
      }
      widget.onChangedIds(selectedItemsIds);
      if (widget.onChangedNames != null) {
        widget.onChangedNames!(selectedItems);
      }
    });
  }

  void toggleItemSelection(MyCustomModel item) {
    setState(() {
      if (selectedItemsIds.contains(item.id)) {
        selectedItems.remove(item.name);
        selectedItemsIds.remove(item.id);
      } else {
        selectedItems.add(item.name);
        selectedItemsIds.add(item.id);
      }
      widget.onChangedIds(selectedItemsIds);
      if (widget.onChangedNames != null) {
        widget.onChangedNames!(selectedItems);
      }
    });
  }

  void initSelectedItems() {
    if (widget.initialSelectedNames == null ||
        widget.initialSelectedIds == null) {
      return;
    }
    selectedItems = widget.initialSelectedNames!;
    selectedItemsIds = widget.initialSelectedIds!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dropdownItemsNames.isEmpty) {
      myCustomModelList = [];
      selectedItems = [];
      selectedItemsIds = [];
    }
    if (widget.initialSelectedIds?.isEmpty == true) {
      selectedItems = [];
      selectedItemsIds = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedItems.isNotEmpty)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 2.wR,
              bottom: 0.2.hR,
            ),
            child: Text(
              widget.hint,
              style: TextStyle(color: AppColors.blueyGrey, fontSize: 9.5.sp),
            ),
          ),
        if (selectedItems.isEmpty)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 2.wR,
              bottom: 0.2.hR,
            ),
            child: Text(
              '',
              style: TextStyle(color: AppColors.blueyGrey, fontSize: 9.sp),
            ),
          ),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            hint: Container(
              alignment: widget.hintAlignment,
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        widget.hint,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.blueyGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (myCustomModelList.isEmpty && widget.isShowLoading)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            value: selectedItems.isEmpty ? null : selectedItems.last,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            items:
                myCustomModelList.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.name,
                    child: Row(
                      children: [
                        Icon(
                          selectedItemsIds.contains(item.id)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color:
                              selectedItemsIds.contains(item.id)
                                  ? AppColors.accentColor
                                  : context.invertedColor,
                          size: 24.sp,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {},
            validator: widget.validator,
            selectedItemBuilder: (context) {
              return myCustomModelList.map((item) {
                return Container(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    selectedItems.join(', '),
                    style: TextStyle(
                      fontSize: 13.sp,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            iconStyleData: IconStyleData(
              icon:
                  widget.icon ??
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: AppColors.blueGrey.withValues(alpha: 0.4),
                  ),
              iconSize: widget.iconSize ?? 20,
              iconEnabledColor: widget.iconEnabledColor,
              iconDisabledColor: widget.iconDisabledColor,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: widget.dropdownHeight ?? 25.hR,
              width: widget.dropdownWidth ?? 45.wR,
              padding: widget.dropdownPadding,
              decoration:
                  widget.dropdownDecoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: context.chatColor,
                  ),
              elevation: widget.dropdownElevation ?? 12,
              offset: widget.offset ?? Offset.zero,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: widget.itemHeight ?? 40,
              padding:
                  widget.itemPadding ??
                  const EdgeInsets.symmetric(horizontal: 14),
            ),
            // Adding search functionality
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  left: 8,
                  right: 8,
                ),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Search...',
                    hintStyle: TextStyle(fontSize: 12.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                final model = myCustomModelList.firstWhere(
                  (m) => m.name == item.value,
                );
                return model.name.toLowerCase().contains(
                  searchValue.toLowerCase(),
                );
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                searchController.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}
