
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:eduhub/constant/color_manage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'onboardin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //int y=Random().nextInt((3500-1)-2600)+2600;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
           ColorManage.firstPrimary,
            ColorManage.secondPrimary,
          ],begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0,0.75 ],
        ),
      ),
      child: AnimatedSplashScreen(
        backgroundColor: Colors.transparent,
        splash: Image.asset('assets/splash.png',),
        splashIconSize: 300,
        nextScreen: OnboardinScreen(),
        duration: 2300,
        pageTransitionType: PageTransitionType.rightToLeft,
        splashTransition:SplashTransition.fadeTransition ,
       // animationDuration: Duration(seconds: 1),
      ),
    );
  }


}
