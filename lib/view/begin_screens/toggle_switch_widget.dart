import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/view/begin_screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/image_manage.dart';
import '../../constant/style_widget_manage.dart';
import '../student_screens/bottom_nav_bar.dart';
import '../teacher_screens/bottom_nav_bar.dart';
import '../teacher_screens/teacher.dart';
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

  checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("email") != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              prefs.getString("role") == "student" ? BottomNavBar() : BottomNavBarTeacher(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          width: double.infinity,
          //height: MediaQuery.of(context).size.height * 0.35,
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
    );
  }
}
