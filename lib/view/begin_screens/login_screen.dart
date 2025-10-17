import 'package:eduhub/constant/style_widget_manage.dart';
import 'package:eduhub/constant/textstyle_manage.dart';
import 'package:eduhub/view/student_screens/bottom_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/color_manage.dart';
import '../../constant/numbers_manage.dart';
import '../../constant/text_field_manage.dart';
import '../../controller/begin_controller/auth_service.dart';
import '../teacher_screens/teacher_courses.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showErrorEmail = false;
  bool showErrorPassword = false;

  bool isEmail({required String email}) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);

    return regExp.hasMatch(email);
  }

  bool validatePassword({required String password}) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  @override
  void initState() {
    super.initState();
  }

  login() async {
    setState(() {
      showErrorPassword = passwordController.text.isEmpty;
      showErrorEmail = emailController.text.isEmpty;
    });

    if (!showErrorEmail && !showErrorPassword) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authService = AuthService();
      final result = await authService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      Navigator.pop(context);
      print(result);
      if (result["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("email", result["data"]["name"]);
        await prefs.setString("name", result["data"]["name"]);
        await prefs.setInt("id", result["data"]["id"]);
        await prefs.setString("role", result["data"]["role"]);
        if (result["data"]["role"] == "student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        }
        if (result["data"]["role"] == "teacher"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CourseListScreen()),
        );}
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تسجيل الدخول بنجاح ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "فشل تسجيل الدخول ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: NumbersManage.horizontalLoginAndRegister,
          vertical: NumbersManage.verticalLoginAndRegister,
        ),
        child: Column(
          children: [
            buildTextField(
              controller: emailController,

              keyboardType: TextInputType.emailAddress,

              errorText: showErrorEmail ? 'Enter your correct email' : null,

              hint: 'Enter Email here',

              label: 'Email',
            ),

            buildTextField(
              obscure: true,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,

              errorText: showErrorPassword ? 'Enter stronger password' : null,

              hint: 'Enter Password here',
              label: 'Password',
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: NumbersManage.horizontalLoginAndRegister,
                vertical: NumbersManage.verticalLoginAndRegister,
              ),
            ),

            InkWell(
              onTap: login,
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: NumbersManage.verticalLoginAndRegister2,
                  horizontal: NumbersManage.horizontalLoginAndRegister2,
                ),

                height:
                    MediaQuery.of(context).size.height *
                    NumbersManage.nextHeight,
                decoration: StyleWidgetManage.nextButtonDecoration,
                child: Center(
                  child: Text('Login', style: TextStyleManage.nextButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
