import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/view/begin_screens/register_screen.dart';
import 'package:flutter/material.dart';
import '../../constant/image_manage.dart';
import '../../constant/style_widget_manage.dart';
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
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(ImageManage.logo, width: 170, height: 170),
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
                  indicatorGradient:  StyleWidgetManage.onBoardingIndicatorTrue,
                  boxShadow: [
                    const BoxShadow(
                      color: ColorManage.boxShadowToggle,
                      spreadRadius: 1,blurRadius: 2,
                      offset: Offset(-3, -3)
                    )
                  ]
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
        toolbarHeight: MediaQuery.of(context).size.height * 0.27,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: screens[currentIndex],
    );
  }
}
