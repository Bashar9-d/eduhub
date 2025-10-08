
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/color_manage.dart';
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
      nextPage = seen ?  ToggleSwitchWidget() :  OnboardingScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nextPage == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: ColorManage.stopsColor,
          ),
        ),
        child: const Center(
          child: Image(
            image: AssetImage('assets/eduhub logo.png'),
            width: 200,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE27BF5), Color(0xFF7C5EF1),
          ],begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0,0.75 ],
        ),
      ),
      child: AnimatedSplashScreen(
        backgroundColor: Colors.transparent,
        splash: Image.asset('assets/eduhub logo.png',),
        splashIconSize: 300,
        nextScreen:nextPage!,
        duration: 2300,
        pageTransitionType: PageTransitionType.rightToLeft,
        splashTransition:SplashTransition.fadeTransition ,
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