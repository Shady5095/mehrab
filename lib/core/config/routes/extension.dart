import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_locale/app_locale.dart';
import '../../utilities/functions/responsive_font_size.dart';
import '../../utilities/resources/size_config.dart';

extension NavigateToExtension on BuildContext {
  Future navigateTo({required String pageName, Object? arguments}) async =>
      Navigator.of(this).pushNamed(pageName, arguments: arguments);
}

extension NavigatorPopExtension on BuildContext {
  void pop({dynamic result = false}) => Navigator.of(this).pop(result);
}

extension NavigateReplacementExtension on BuildContext {
  Future<Object?> navigateAndRemoveUntil({required String pageName, Object? arguments}) =>
      Navigator.of(this).pushNamedAndRemoveUntil(
        pageName,
        (Route<dynamic> route) => false,
        arguments: arguments,
      );
}

extension PopUntilSpecificRouteExtension on BuildContext {
  void popUntilSpecificRoute({required String pageName}) =>
      Navigator.of(this).popUntil(ModalRoute.withName(pageName));
}

extension GetContainerDuckColorColorOnDarkAndLightTheme on BuildContext {
  Color get containerColor => Theme.of(this).cardTheme.color!;
}

extension GetContainerWhiteColorColorOnDarkAndLightTheme on BuildContext {
  Color get backgroundColor => Theme.of(this).primaryColor;
}

extension GetContainerInvertColorColorOnDarkAndLightTheme on BuildContext {
  Color get invertedColor => Theme.of(this).secondaryHeaderColor;
}

extension GetContainerGrayColorColorOnDarkAndLightTheme on BuildContext {
  Color get grayColor => Theme.of(this).primaryColorDark;
}

extension GetChatColorOnDarkAndLightTheme on BuildContext {
  Color get chatColor => Theme.of(this).dividerColor;
}

extension GetHeightRatioFromScreen on num {
  double get hR => SizeConfig.height * this / 100;
}

extension ResetHrHight on num {
  double resetHeight() => (this * 100 / SizeConfig.height) * 3 / 4;
}

extension GetWidthRatioFromScreen on num {
  double get wR => SizeConfig.width * this / 100;
}

extension GetResponsiveFont on num {
  double get sp => getResponsiveFontSize(toDouble());
}

extension TranslateLanguage on String {
  String tr(BuildContext context) => getLang(context, this);
}

extension CapitalizeFirstLetter on String {
  String get capitalizeFirstLetter => this[0].toUpperCase() + substring(1);
}

extension MakeStringInteger on String {
  int get toInt => int.tryParse(this) ?? 0;
}

extension NumberFormatting on num {
  /// Formats the number with separators based on the locale.
  String withSeparator({String locale = 'en_US'}) {
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(this);
  }
}
extension FormatDateToString on DateTime?{
  String get formattedDateToString =>toString().split(' ')[0];


}
extension FirstNameFromFullName on String {
  String get firstName {
    final trimmed = trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(' ').first;
  }
}