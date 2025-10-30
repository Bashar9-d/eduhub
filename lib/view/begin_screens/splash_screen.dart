import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/otherwise/image_manage.dart';
import '../student_screens/bottom_nav_bar.dart';
import '../teacher_screens/bnb_teacher.dart';
import 'onboardin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Widget? nextPage;

  @override
  void initState() {
    super.initState();
    _checkOnBoarding();
  }


  Future<void> _checkOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onBoardingDone') ?? false;

    setState(() async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString("email") != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            prefs.getString("role") == "student" ? BottomNavBar() : HomeScreen(),
          ),
        );
      }
      else {
        nextPage = seen ? ToggleSwitchWidget() : OnboardingScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (nextPage == null) {
      return Container(
        decoration: StyleWidgetManage.gradiantDecoration,
        child:  Center(
          child: Image(image: AssetImage(ImageManage.logo), width: 200.w),
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
      ),
    );
  }
}
