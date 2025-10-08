
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/color_manage.dart';
import '../../constant/textstyle_manage.dart';
import '../../model/onborading_model.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<OnBoardingModel> pages = [
    OnBoardingModel(
      image: 'assets/onboarding1.png',
      title: 'Welcome to the EduHub',
      subtitle:
          'Reference site about Lorem Ipsum, giving information on its origins, as well .',
    ),
    OnBoardingModel(
      image: 'assets/onboarding2.png',
      title: 'Enjoy the EduHub',
      subtitle:
          'Reference site about Lorem Ipsum, giving information on its origins, as well .',
    ),
    OnBoardingModel(
      image: 'assets/onboarding1.png',
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
     backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20),
          child: PageView.builder(
            itemCount: pages.length,
            controller: _controller,
            onPageChanged: (value) {
              _currentPage = value;
              setState(() {});
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 30,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Spacer(),
                    Center(child: Image.asset(pages[index].image,)),
                    Column(
                      spacing: 10,
                      children: [
                        Center(
                          child: Text(
                            pages[index].title,
                            style: TextStyleManage.titleOnBoarding,
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: Center(
                            child: Text(
                              pages[index].subtitle,
                              style: TextStyleManage.subtitleOnBoarding,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      spacing: 24,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pages.length, (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _currentPage == index
                                    ? LinearGradient(
                                        colors: [
                                  ColorManage.firstPrimary, ColorManage.secondPrimary,
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops:ColorManage.stopsColor,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          ColorManage.nonActiveIndicator,
                                          ColorManage.nonActiveIndicator,
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  stops: ColorManage.stopsColor,
                                      ),
                              ),
                              width: 10,
                              height: 10,
                            );
                          }),
                        ),
                        GestureDetector(
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.5,
                            height:   MediaQuery.of(context).size.height * 0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [ColorManage.firstPrimary, ColorManage.secondPrimary, ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: ColorManage.stopsColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Next',
                                style: TextStyleManage.nextButtonOnBoarding,
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (_currentPage != pages.length - 1) {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              SharedPreferences seenOnBoarding=await SharedPreferences.getInstance();
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
                            ? GestureDetector(
                                onTap: () async {
                                  SharedPreferences seenOnBoarding=await SharedPreferences.getInstance();
                                  seenOnBoarding.setBool('onBoardingDone', true);

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
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          ColorManage.firstPrimary, ColorManage.secondPrimary
                                        ],
                                        // begin: Alignment.centerLeft,
                                        // end: Alignment.centerRight,
                                        stops: ColorManage.stopsColor,
                                      ).createShader(
                                        Rect.fromLTWH(
                                          0,
                                          0,
                                          bounds.width,
                                          bounds.height,
                                        ),
                                      ),
                                  child: Text(
                                    'Skip',
                                    style: TextStyleManage.skipButtonOnBoarding,
                                  ),
                                ),
                              )
                            : //else
                              SizedBox(child: Text('')),
                      ],
                    ),

                    //Spacer(),
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
