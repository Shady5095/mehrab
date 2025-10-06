import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BoardingModel {
  late final String image1;

  late final double topPadding;

  late final String title;

  late final String body;

  BoardingModel({
    required this.image1,
    required this.topPadding,
    required this.title,
    required this.body,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var boarderController = PageController();

  bool isLast = false;

  void onSubmit() {
    CacheService.setData(key: 'onBoarding', value: true);
    context.navigateAndRemoveUntil(pageName: AppRoutes.loginRoute);
  }

  List<BoardingModel> boarding = [
    BoardingModel(
      image1: 'assets/images/onboarding1.jpg',
      topPadding: 40.hR,
      title: 'تعليم النورانية',
      body:
          'القاعدة النورانية هي منهج تعليمي يهدف إلي تيسير قراءة القرآن الكريم للمبتدئين. تعتمد هذه القاعدة علي تعلم الحروف و الأصوات و التركيبات الأساسة التي تشكل البنية اللغوية للقرآن الكريم',
    ),
    BoardingModel(
      image1: 'assets/images/onboarding2.jpg',
      topPadding: -30.hR,
      title: 'الإقراء و الإجازة',
      body:
          'و هي شهادة من الشيخ المجيز إلي الطالب للطالب المجاز بأنه قرأ عليه القرآن عليه كاملا غيبا مع التجويد و الإتقان و التفريق بين المتشابهات و أصبح مؤهلا للإقراء',
    ),
    BoardingModel(
      image1: 'assets/images/onboarding3.jpg',
      topPadding: 54.hR,
      title: 'الحفظ والمراجعة',
      body:
          'مراجعة الحفظ و مداومته حتي لا يتفلت من الطلاب حيث يستطيع طالب العلم أن يتعلم القرآن الكريم تبعا للخطة المتبعة في حفظ الوجه الواحد قرابة 15 دقيقة و هذا عن طريق إعادة حفظ الآية 25 مرة مع ربطها بالآيات السابقة حتي إتمام الوجه الكامل و بذلك يكون الحفظ مرسخ أبدي بإذن الله.',
    ),
    BoardingModel(
      image1: 'assets/images/onboarding4.jpg',
      topPadding: -40.hR,
      title: 'تصحيح التلاوة و التلقين',
      body:
          'تعلم نطق الحروف نطقا عربيا صحيحا من مخارجها و بكامل صفاتها مع إجادة قراءة الكلمات بعلامات الإعراب الصحيحة بجانب تطبيق أحكام التلاوة و التجويد بإتقان و تعلم الوقت و الإبتداء',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) {
              setState(() {
                if (index == boarding.length - 1) {
                  isLast = true;
                } else {
                  setState(() {
                    isLast = false;
                  });
                }
              });
            },
            controller: boarderController,
            scrollDirection: Axis.horizontal,
            itemBuilder:
                (context, index) => buildScreenItem(boarding[index], index),
            itemCount: boarding.length,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      onSubmit();
                    },
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17.sp,
                        fontFamily: 'Cairo'
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(30.0.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: boarderController,
                    count: boarding.length,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.white,
                      activeDotColor: AppColors.myAppColor,
                      expansionFactor: 2,
                      spacing: 10,
                      dotWidth: 8.sp,
                      dotHeight: 8.sp,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (isLast == false) {
                        boarderController.nextPage(
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.fastLinearToSlowEaseIn,
                        );
                      } else {
                        onSubmit();
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: AppColors.myAppColor,
                      radius: 26.sp,
                      child: Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Colors.white,
                        size: 23.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScreenItem(BoardingModel model, int index) => Stack(
    children: [
      Image(
        image: AssetImage(model.image1),

        height: 100.hR,
        width: 100.wR,
        fit: BoxFit.cover,
      ),
      Container(color: Colors.black.withValues(alpha: index == 2 || index == 3 ? 0.7: 0.5)),
      Positioned(
        right: 0,
        left: 0,
        bottom: 0,
        top: model.topPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 25.sp,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 3.0,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.sp),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                model.body,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3.0,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
