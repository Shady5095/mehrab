import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: 100.hR,
        width: 100.wR,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: const DecorationImage(
            opacity: 0.4,
            image: AssetImage('assets/images/startScreen.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 15.hR),
            Text(
              "محراب القرآن",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              textAlign: TextAlign.center,
              "منصة لتعليم القرآن الكريم و علومه و استقبال ضيوف الرحمن. تتيح هذه المنصة تعلم القرآن عن بعد مجانا علي يد نخبة من المعلمين و المعلمات المجازين علي مدار 24 ساعة",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            Spacer(),
            ButtonWidget(
              onPressed: () {
                context.navigateAndRemoveUntil(pageName: AppRoutes.onboardingRoute);
              },
              label: "ابدأ الان",
              height: 40,
              width: 55.wR,
              isShowArrow: true,
            ),
            SizedBox(height: 7.hR),
          ],
        ),
      ),
    );
  }
}
