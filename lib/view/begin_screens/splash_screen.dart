import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:eduhub/constant/style_widget_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/image_manage.dart';
import 'onboardin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //int y=Random().nextInt((3500-1)-2600)+2600;
  Widget? nextPage;

  @override
  void initState() {
    super.initState();
    _checkOnBoarding();
  }

  Future<void> _checkOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onBoardingDone') ?? false;

    setState(() {
      nextPage = seen ? ToggleSwitchWidget() : OnboardingScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nextPage == null) {
      return Container(
        decoration: StyleWidgetManage.gradiantDecoration,
        child: const Center(
          child: Image(image: AssetImage(ImageManage.logo), width: 200),
        ),
      );
    }

    return Container(
      decoration: StyleWidgetManage.gradiantDecoration,
      child: AnimatedSplashScreen(
        backgroundColor: Colors.transparent,
        splash: Image.asset(ImageManage.logo),
        splashIconSize: 300,
        nextScreen: nextPage!,
        duration: 2300,
        pageTransitionType: PageTransitionType.rightToLeft,
        splashTransition: SplashTransition.fadeTransition,
        // animationDuration: Duration(seconds: 1),
      ),
    );
  }
}

// @override
//   void initState() {
//     super.initState();
//     _navigateNext();
//   }
//   Future<void> _navigateNext() async {
//     await Future.delayed(const Duration(seconds: 2)); // وقت العرض
//     final prefs = await SharedPreferences.getInstance();
//     final seenOnBoarding = prefs.getBool('onBoardingDone') ?? false;
//
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => seenOnBoarding
//               ?  LoginScreen()
//               :  OnboardinScreen(),//const
//         ),
//       );
//     }
//   }
