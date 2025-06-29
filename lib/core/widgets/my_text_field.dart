import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/styles.dart';

class MyTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onFieldSubmitted;
  final void Function(String?)? onChanged;
  final bool obsceure;
  final int? maxLines;
  final int? minLines;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool? centerLabel;
  final EdgeInsetsGeometry? contentPadding;

  final bool? enabled;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final InputBorder? errorBorder;
  final TextAlign formTextAlign;
  final Color? fillColor;
  final bool? isDense;
  final AutovalidateMode autoValidateMode;
  final bool autofocus;

  const MyTextField({
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obsceure = false,
    this.maxLines,
    this.minLines,
    this.onFieldSubmitted,
    this.onChanged,
    this.keyboardType,
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
    this.style,
    this.hintStyle,
    this.readOnly,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onTap,
    this.centerLabel,
    this.contentPadding,
    this.enabled,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.formTextAlign = TextAlign.start,
    this.fillColor,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
    this.errorBorder,
    this.isDense,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      autofocus: autofocus,
      textAlign: formTextAlign,
      autovalidateMode: autoValidateMode,
      controller: controller,
      focusNode: focusNode,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      validator: validator,
      obscureText: obsceure,
      minLines: minLines,
      initialValue: initialValue,
      onTap: onTap,
      maxLines: maxLines ?? 1,
      inputFormatters: inputFormatters,
      readOnly: readOnly ?? false,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      style: style ?? AppStyle.inputTextStyle,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        alignLabelWithHint: centerLabel,
        fillColor: fillColor,
        filled: fillColor != null,
        label:
            label != null ? FittedBox(child: Text(label!, maxLines: 1)) : null,
        suffixIcon: suffixIcon,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: disabledBorder,
        focusedErrorBorder: errorBorder,
        errorBorder: errorBorder,
        isDense: isDense,

        prefixIcon: prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 8.wR),
        suffixIconConstraints: BoxConstraints(minWidth: 8.wR),
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(
              vertical: (maxLines != null && maxLines! > 1) ? 10 : 0,
              horizontal: 10,
            ),
        hintText: hint,
        hintStyle: hintStyle,
        //hintStyle: hintStyle ?? AppStyle.inputTextStyle,
      ),
    );
  }
}
