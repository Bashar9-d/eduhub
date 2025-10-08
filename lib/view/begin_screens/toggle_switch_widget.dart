import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:eduhub/view/begin_screens/register_screen.dart';
import 'package:flutter/material.dart';
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
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0,0.75 ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/eduhub logo.png', width: 170, height: 170),
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
                  indicatorGradient: const LinearGradient(
                    colors: [
                       Color(0xFFE27BF5),Color(0xFF7C5EF1), //0xE27BF5,,0x7C5EF1
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0,0.75 ],
                    // begin: Alignment.centerLeft,
                    // end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
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
        toolbarHeight: MediaQuery.of(context).size.height * 0.30,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: screens[currentIndex],
    );
  }
}
