import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:eduhub/constant/helpers/prefs.dart';
import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../constant/helpers/theme_provider.dart';
import '../../constant/otherwise/image_manage.dart';
import '../../constant/helpers/theme.dart';
import '../student_screens/bottom_nav_bar.dart';
import '../teacher_screens/bnb_teacher.dart';
import 'onboardin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _darkInit();
      _navigateAfterSplash();
    });
  }
  _darkInit()async{
     if(PrefsHelper.getBool('dark')!=null) {
      return PrefsHelper.getBool('dark')! ?
      Provider
          .of<ThemeProvider>(
        context,
        listen: false,
      )
          .themeData = darkMode : Provider
          .of<ThemeProvider>(
        context,
        listen: false,
      )
          .themeData = lightMode;
    }
    else{
      return Provider
          .of<ThemeProvider>(
        context,
        listen: false,
      )
          .themeData = lightMode;
    }
  }

  Future<void> _navigateAfterSplash() async {

    await Future.delayed(const Duration(seconds: 2));

    final seen = PrefsHelper.getBool('onBoardingDone') ?? false;
    final email = PrefsHelper.getString('email');
    final role = PrefsHelper.getString('role');

    Widget nextPage;

    if (email != null) {
      nextPage = role == "student" ? const BottomNavBar() : const HomeScreen();
    } else {
      nextPage = seen ? const ToggleSwitchWidget() : const OnboardingScreen();
    }

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: nextPage,

        duration: const Duration(milliseconds: 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StyleWidgetManage.gradiantDecoration,
      child: AnimatedSplashScreen(
        backgroundColor: Colors.transparent,
        splash: Image.asset(ImageManage.logo),
        splashIconSize: 300,
        nextScreen:const SizedBox(),
        duration: 2300,
        pageTransitionType: PageTransitionType.rightToLeft,
        splashTransition: SplashTransition.fadeTransition,
      ),
    );
  }}
