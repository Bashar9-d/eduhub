import 'package:eduhub/constant/helpers/prefs.dart';
import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/view/student_screens/bottom_nav_bar.dart';
import 'package:eduhub/view/teacher_screens/bnb_teacher.dart';

import 'package:flutter/material.dart';
import '../../constant/otherwise/numbers_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../constant/widgets/text_field_manage.dart';
import '../../controller/begin_controller/auth_service.dart';

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
  bool obsecureText = true;
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
        builder: (context) => Center(child: CircularProgress.circular),
      );

      final authService = AuthService();
      final result = await authService.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      Navigator.pop(context);
      print(result);
      if (result["success"] == true) {
        await PrefsHelper.setString("email", result["data"]["email"]);
        await PrefsHelper.setString("name", result["data"]["name"]);
        await PrefsHelper.setInt("id", result["data"]["id"]);
        await PrefsHelper.setString("role", result["data"]["role"]);
        if (result["data"]["role"] == "student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar()),
          );
        }
        if (result["data"]["role"] == "teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Register successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Login failed"),
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
      backgroundColor: Theme.of(context).colorScheme.background,
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

              label: 'Email',fillColor: Theme.of(context).colorScheme.secondary
            ),

            buildTextField(
              obscure: obsecureText,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              suffix: IconButton(
                onPressed: () => setState(() => obsecureText = !obsecureText),
                icon: Icon(color: Theme.of(context).colorScheme.primary,
                  obsecureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              errorText: showErrorPassword ? 'Enter stronger password' : null,

              hint: 'Enter Password here',
              label: 'Password',fillColor: Theme.of(context).colorScheme.secondary
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
