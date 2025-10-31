import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:eduhub/view/begin_screens/register_screen.dart';
import 'package:eduhub/view/teacher_screens/bnb_teacher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/otherwise/image_manage.dart';
import '../../constant/widgets/style_widget_manage.dart';
import '../student_screens/bottom_nav_bar.dart';
import 'login_screen.dart';

class ToggleSwitchWidget extends StatefulWidget {
  const ToggleSwitchWidget({super.key});

  @override
  State<ToggleSwitchWidget> createState() => _ToggleSwitchWidgetState();
}

class _ToggleSwitchWidgetState extends State<ToggleSwitchWidget> {
  List<Widget> screens = [LoginScreen(), RegisterScreen()];
  int currentIndex = 0;
  bool firstSwitchValue = true;



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> willPop() async {
      return await showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text(
            'Exit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Do you want to exit the app?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            width: double.infinity,
            decoration: StyleWidgetManage.toggleDecoration,
            child: Column(
              spacing: 5.h,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(ImageManage.logo, width: 170.w, height: 170.h),
                AnimatedToggleSwitch<bool>.size(
                  current: firstSwitchValue,
                  values: const [true, false],
                  iconOpacity: 0.5,
                  height: 60,
                  indicatorSize: const Size.fromWidth(150),
                  customIconBuilder: (context, local, global) => Text(
                    local.value ? 'Login' : 'Register',
                    style: TextStyle(
                      color: Color.lerp(
                        Colors.black,
                        Colors.white,
                        local.animationValue,
                      ),
                    ),
                  ),
                  borderWidth: 0,
                  iconAnimationType: AnimationType.onSelected,
                  style: ToggleStyle(
                    indicatorGradient: StyleWidgetManage.onBoardingIndicatorTrue,
                    boxShadow: [
                      const BoxShadow(
                        color: ColorManage.boxShadowToggle,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(-3, -3),
                      ),
                    ],
                  ),
                  selectedIconScale: 1,
                  onChanged: (value) {
                    firstSwitchValue = value;
                    if (firstSwitchValue) {
                      currentIndex = 0;
                    } else {
                      currentIndex = 1;
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.3.h,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: screens[currentIndex],
      ),
    );
  }
}
