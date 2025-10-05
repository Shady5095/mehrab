import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/colors.dart';

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
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
    super.key,
  });

  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 2.wR,
              bottom: 0.2.hR,
            ),
            child: Text(
              hint,
              style: TextStyle(color: AppColors.blueyGrey, fontSize: 9.5.sp),
            ),
          ),
        if (value == null)
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
            //To avoid long text overflowing.
            isExpanded: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            hint: Container(
              alignment: hintAlignment,
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        hint,
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
                  if (dropdownItems.isEmpty && isShowLoading)
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            value: value,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
            items:
                dropdownItems
                    .map(
                      (String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Container(
                          alignment: valueAlignment,
                          color: Colors.transparent,
                          child: Text(
                            isTextTranslated ? item.tr(context) : item,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color:
                                  readOnly == true
                                      ? Colors.grey[500]
                                      : context.invertedColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: readOnly == true ? null : onChanged,
            validator: validator,

            selectedItemBuilder: selectedItemBuilder,

            iconStyleData: IconStyleData(
              icon:
                  icon ??
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: AppColors.blueGrey.withValues(alpha: 0.4),
                  ),
              iconSize: iconSize ?? 20,
              iconEnabledColor: iconEnabledColor,
              iconDisabledColor: iconDisabledColor,
            ),
            dropdownStyleData: DropdownStyleData(
              //Max height for the dropdown menu & becoming scrollable if there are more items. If you pass Null it will take max height possible for the items.
              maxHeight: dropdownHeight ?? 25.hR,
              width: dropdownWidth ?? 45.wR,
              padding: dropdownPadding,
              decoration:
                  dropdownDecoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: context.chatColor,
                  ),
              elevation: dropdownElevation ?? 12,
              //Null or Offset(0, 0) will open just under the button. You can edit as you want.
              offset: offset ?? Offset.zero,
            ),
            menuItemStyleData: MenuItemStyleData(
              height: itemHeight ?? 40,
              padding:
                  itemPadding ?? const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}
