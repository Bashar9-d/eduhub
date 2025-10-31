import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/otherwise/image_manage.dart';
import '../../constant/otherwise/numbers_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../controller/begin_controller/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<OnBoardingModel> pages = [
    OnBoardingModel(
      image: ImageManage.onBoarding1,
      title: 'Welcome to the EduHub',
      subtitle:
          'Reference site about Lorem Ipsum, giving information on its origins, as well .\n\u200B\n\u200B',
    ),
    OnBoardingModel(
      image: ImageManage.onBoarding2,
      title: 'Enjoy the EduHub',
      subtitle:
          'Reference site about Lorem Ipsum, giving information on its origins, as well .',
    ),
    OnBoardingModel(
      image: ImageManage.onBoarding3,
      title: 'No interruption',
      subtitle:
          'Reference site about Lorem Ipsum, giving information on its origins, as well .',
    ),
  ];

  final PageController _controller = PageController();

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 25.0.h, horizontal: 20.w),
          child: PageView.builder(
            itemCount: pages.length,
            controller: _controller,
            onPageChanged: (value) {
              _currentPage = value;
              setState(() {});
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),

                child: Column(
                  spacing: 30.h,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Center(child: Image.asset(pages[index].image)),
                    Column(
                      spacing: 10.h,
                      children: [
                        Center(
                          child: Text(
                            pages[index].title,
                            style: TextStyleManage.titleOnBoarding,
                          ),
                        ),
                        Text(
                          pages[index].subtitle,
                           style: TextStyleManage.subtitleOnBoarding,
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),
                    Column(
                      spacing: 24.h,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pages.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _currentPage == index
                                    ? StyleWidgetManage.onBoardingIndicatorTrue
                                    : StyleWidgetManage
                                          .onBoardingIndicatorFalse,
                              ),
                              width: 10.w,
                              height: 10.h,
                            );
                          }),
                        ),
                        InkWell(
                          child: Container(

                            height: MediaQuery.of(context).size.height * NumbersManage.nextHeight,
                            decoration:StyleWidgetManage.nextButtonDecoration,
                            child: Center(
                              child: Text(
                                'Next',
                                style: TextStyleManage.nextButton,
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (_currentPage != pages.length - 1) {
                              _controller.nextPage(
                                duration: Duration(milliseconds: NumbersManage.nextPageDuration),
                                curve: Curves.easeIn,
                              );
                            } else {
                              SharedPreferences seenOnBoarding =
                                  await SharedPreferences.getInstance();
                              seenOnBoarding.setBool('onBoardingDone', true);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ToggleSwitchWidget(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                        _currentPage != pages.length - 1
                            ? InkWell(
                                onTap: () async {
                                  SharedPreferences seenOnBoarding =
                                      await SharedPreferences.getInstance();
                                  seenOnBoarding.setBool(
                                    'onBoardingDone',
                                    true,
                                  );

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ToggleSwitchWidget(),
                                    ),
                                    (route) => false,
                                  );
                                },

                                child: ShaderMask(
                                  shaderCallback: (bounds) => StyleWidgetManage
                                      .onBoardingIndicatorTrue
                                      .createShader(
                                        Rect.fromLTWH(
                                          0,
                                          0,
                                          bounds.width.w,
                                          bounds.height.h,
                                        ),
                                      ),
                                  child: Text(
                                    'Skip',
                                    style: TextStyleManage.skipButtonOnBoarding,
                                  ),
                                ),
                              )
                            : SizedBox(child: Text('')),
                      ],
                    ),

                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
