import 'package:flutter/material.dart';

abstract class AppColors {
  static const darkContainerColor = Color.fromRGBO(50, 50, 50, 0.5);

  //static const darkContainerColorNavy = Color.fromRGBO(34,43,69,0.6);
  static const primaryDarkColor = Color(0xff232323);
  static const firstColor = Color(0xFFC4E2CF);
  static const secondColor = Color(0xFFD7D8EF);
  static const thirdColor = Color(0xFFF0DAC6);
  static const fourthColor = Color(0xFFEBD2E0);
  static const fifthColor = Color(0xFFDEE0D0);
  static const sixthColor = Color(0xFFDBE0E4);
  static const seventhColor = Color(0xFFEDD7D7);
  static const eighthColor = Color(0xFFD5D5D5);
  static const ninthColor = Color(0xFFEDE4C0);
  static const tenthColor = Color(0xFFFFFBEA);
  static const lightGreyColor = Color(0xFF8092A3);
  static const blackColor = Colors.black;
  static const greenColor = Colors.green;
  static const greyColor = Color(0xFF8092A3);
  static const primaryColor = Color(0xFF000000);
  static const darkTextColor = Color(0xff1D2226);
  static const accentColor = Color(0xFF2A7DE1);
  static const accentPaleColor = Color(0xFF85BDFE);
  static const accentLightColor = Color(0xFF2AAFFF);
  static const white = Color(0xffFFFFFF);
  static const blueGrey = Color(0XFF8092a3);
  static const blueyGrey = Color(0XFFa6b3bf);
  static const azure = Color(0XFF0091ff);
  static const navy = Color(0XFF002547);
  static const brightCyan = Color(0XFF3ec7ff);
  static const darkGreyBlue = Color(0XFF33516c);
  static const coral = Color(0XFFf05252);
  static const coolGreen = Color(0XFF37cf6d);
  static const orangeYellow = Color(0XFFffaa01);
  static const paleGrey = Color(0XFFf5f8fa);
  static const paleGreyTwo = Color(0XFFf6f7f8);
  static const whiteTwo = Color(0XFFf2f2f2);
  static const whiteThree = Color(0XFFfcfcfc);
  static const cloudyBlue = Color(0XFFd6dee6);
  static const paleGreyThree = Color(0XFFf2f4f6);
  static const greyBlue = Color(0XFF667c91);
  static const lighterPurple = Color(0XFF8d51fc);
  static const yellowOrange = Color(0XFFf7b500);
  static const paleGreyFour = Color(0XFFf5f7f9);
  static const blueyGreyTwo = Color(0XFFa0b2c3);
  static const paleGreyFive = Color(0XFFe6eaed);
  static const paleGreySix = Color(0XFFf5f6f7);
  static const darkSlateBlue = Color(0XFF244360);
  static const orangeRed = Color(0XFFfe2323);
  static const notificationRed = Color(0XFFf92f2f);
  static const duckEggBlue = Color(0xffd5e5ec);
  static const lighterPurple95 = Color(0XFF8748fc);
  static const veryLightGray = Color(0XFFF0F3F4);
  static const errorRed = Color(0XFFF24024);
  static const purple = Color(0XFF8748FC);
  static const lightRed = Color(0XFFF14242);
  static const redColor = Color(0XFFEE202C);
  static const greyfive = Color(0XFF4D667E);
  static const borderColor = Color(0XFFF1F1F1);
  static const darkNavy = Color(0XFF003561);
  static const darkPink = Color(0xFFE91E63);
  static const lightGreytwo = Color(0xFF667C91);
  static const offlineBlack = Color(0xFF313131);
  static const offlineWhite = Color(0xFFF6F6FA);
  static const offlineNavy = Color(0xFF33516C);
  static const offlineBlue = Color(0xFF002547);
   static const teal = Color(0xFF025D60);
  static const veryLightBlue = Color(0XFFC9E8FF);

  static const darkGreen = Color(0xff38AD61);
  static const myAppColor = Color(0xff2fa39c);

  static const darkerBlue = Color(0XFF3EBCF0);
  static const primaryBlue = Color(0XFF0091FF);
  static const borderColorLight = Color(0XFFF1F1F5);
  static const dividerColor = Color(0XFFA6B3BF);
  static const greyDarker = Color(0XFFF5F8FA);
  static const darkerGreen = Color(0XFF32BF64);
  static const greyText = Color(0XFFA0B2C3);
  static const containerColor2 = Color(0XFFF5F6F9);
  static const backgroundGradientDark = [
    Color(0xff232323),
    Color(0xff191919),
    Color(0xff141414),
    Color(0xff0F0F0F),
    Color(0xff050505),
  ];
  static final attendanceInfoColors = [
    const Color.fromRGBO(120, 207, 170, 1.0),
    const Color.fromRGBO(153, 162, 215, 1),
    const Color(0xFFFFE082),
    const Color(0xFFFF8A80),
  ];
  static const List<Color> presentColor = [
    Color.fromRGBO(39, 226, 143, 1.0), // Starting color
    Color.fromRGBO(113, 205, 166, 1.0), // Slightly lighter green
    Color.fromRGBO(140, 227, 190, 1.0), // A bit lighter
    Color.fromRGBO(150, 237, 200, 1.0), // Even lighter with more brightness
    // Continuing the progression
  ];
  static const List<Color> lateColors = [
    Color.fromRGBO(63, 79, 187, 1.0), // Starting color (light bluish)
    Color.fromRGBO(98, 113, 187, 1.0), // Slightly lighter with more blue
    Color.fromRGBO(193, 202, 235, 1.0), // Continuing to lighten the blue/purple
    Color.fromRGBO(213, 222, 245, 1.0), // Very light and soft blue
  ];
  static const List<Color> excuse = [
    Color(0xFFCAAD53), // Starting color (soft yellow)
    Color(0xFFB9A055), // Slightly lighter and brighter yellow
    Color(0xFFFFEAB0), // Lighter yellow with more softness
    Color(0xFFFFF0C7), // Very soft, almost pastel yellow
    // Very light, almost white with a yellow tint
  ];
  static const List<Color> absent = [
    Color(0xFFDB3F36), // Darker reddish tone
    Color(0xFFFF4A40),

    Color(0xFFFF7A70), // Slightly darker and deeper red-pink
    Color(0xFFFF8A80), // Deeper red with a stronger tone
  ];
  static const teacherReportItemColor = [
    Color.fromRGBO(100, 207, 150, 1.0),
    Color.fromRGBO(153, 162, 215, 1),
    Color.fromRGBO(248, 180, 80, 1),
    Color.fromRGBO(220, 82, 83, 1),
  ];
  static const List<Color> standardsColors = [
    teal, // Starting color (teal)
    Color.fromRGBO(6, 149, 155, 0.8), // Slightly lighter teal
    Color.fromRGBO(102, 170, 173, 1.0), // Softer teal with hints of blue
    Color.fromRGBO(178, 211, 214, 1.0), // Very light teal
  ];

  /*static const backgroundGradientDarkNavy = [
    Color(0xFF151b31),
    Color(0xff111628),
    Color(0xff101428),
    Color(0xff0b0e1a),
  ];*/

  static List<Color> questionColors = [
    const Color(0xFFb2e5fd),
    const Color(0xFFffcdba),
    const Color(0xFFf2aec7),
    const Color(0xFFdaddfe),
    const Color(0xFFcaf2e0),
  ];
  static const List<Color> quizColorList = [
    Color.fromRGBO(0, 193, 131, 1.0),
    Color.fromRGBO(0, 220, 172, 1.0),
    Color.fromRGBO(0, 237, 182, 0.8),
    Color.fromRGBO(0, 255, 199, 0.7),
  ];
  static  const List<Color> materialFileColorList = [
    Color.fromRGBO(0, 134, 202, 1.0),
    Color.fromRGBO(16, 173, 218, 1.0),
    Color.fromRGBO(70, 185, 255, 1.0),
    Color.fromRGBO(15, 186, 250, 1.0),
  ];
  static  const List<Color> materialPageColorList = [
    Color.fromRGBO(179, 55, 248, 1.0),
    Color.fromRGBO(192, 77, 250, 1.0),
    Color.fromRGBO(207, 135, 255, 1.0),
    Color.fromRGBO(213, 154, 255, 1.0),
  ];
  static const List<Color> materialMediaColorList = [
    Color.fromRGBO(174, 0, 0, 1.0),
    Color.fromRGBO(190, 0, 0, 1.0),
    Color.fromRGBO(218, 0, 0, 1.0),
    Color.fromRGBO(255, 0, 0, 1.0),
  ];
  static  const List<Color> interactiveColorList = [
    Color.fromRGBO(213, 156, 0, 1.0),
    Color.fromRGBO(220, 169, 16, 1.0),
    Color.fromRGBO(232, 192, 29, 1.0),
    Color.fromRGBO(255, 206, 79, 1.0),
  ];
  static const List<Color> quickActionsColorList = [
    Color(0xff113f80),
    Color(0xff2b64b4),
    Color(0xff588bd5),
    Color(0xff84b2f1),
  ];
  static const List<Color> attendanceColorList = [
    Color.fromRGBO(137, 45, 118, 1.0),
    Color.fromRGBO(153, 52, 133, 1.0),
    Color.fromRGBO(199, 76, 175, 1.0),
    Color.fromRGBO(227, 88, 196, 1.0),
  ];

  static List<Color> calendarDarkBgColors = [
    const Color(0XFF37cf6d).withValues(alpha: 0.2),
    const Color(0x8B00BBFF).withValues(alpha: 0.2),
    const Color(0XFF707FFF).withValues(alpha: 0.1),
  ];

  static const List<Color> surveyColorList = [
    Color.fromRGBO(255, 102, 0, 1.0),   // Deep orange
    Color.fromRGBO(255, 133, 27, 1.0),  // Strong orange
    Color.fromRGBO(255, 168, 77, 1.0),  // Mid-range orange
    Color.fromRGBO(255, 204, 128, 0.9), // Light orange
  ];

}
