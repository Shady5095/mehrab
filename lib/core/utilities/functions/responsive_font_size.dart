import '../resources/size_config.dart';

double getResponsiveFontSize(double fontSize) {
  final double scaleFactor = getScaleFactor();
  final double responsiveFontSize = fontSize * scaleFactor;
  final double lowerLimit = fontSize * 0.8;
  final double upperLimit = fontSize * 1.4;

  return responsiveFontSize.clamp(lowerLimit, upperLimit);
}

double getScaleFactor() {
  if (SizeConfig.width < SizeConfig.maxMobileWidth) {
    return SizeConfig.width / 400;
  } else {
    return SizeConfig.width / 600;
  }
}
