import 'package:eduhub/view/student_screens/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Container(
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showErrorEmail = false;
  bool showErrorPassword = false;

  bool rememberMe = false;

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
    saveDataLogin();
  }

  saveDataLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemembered = await prefs.getBool('remember_Me') ?? false;
    if (isRemembered) {
      rememberMe = true;
      emailController.text = await prefs.getString('email') ?? "";
      passwordController.text = await prefs.getString('password') ?? "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42.0, vertical: 22),
            child: TextField(
              controller: emailController,

              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorText: showErrorEmail ? 'Enter your correct email' : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Enter Email here',

                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42.0, vertical: 22),
            child: TextField(
              obscureText: true,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                errorText: showErrorPassword ? 'Enter stronger password' : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Enter Password here',
                labelText: 'Password',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42.0, vertical: 22),
            child: Row(
              children: [
                Text('Remember Me?'),
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {});
                    rememberMe = value!;
                  },
                ),
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () async {
              setState(() {
                showErrorPassword =
                    passwordController.text.isEmpty ||
                    (!validatePassword(password: passwordController.text));
                showErrorEmail =
                    emailController.text.isEmpty ||
                    (!isEmail(email: emailController.text));
              });
              if (!showErrorEmail && !showErrorPassword) {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                if (rememberMe) {
                  await prefs.setBool('remember_Me', true);
                  await prefs.setString('email', emailController.text);
                  await prefs.setString('password', passwordController.text);
                } else {
                  await prefs.remove('remember_Me');
                  await prefs.remove('email');
                  await prefs.remove('password');
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavBar()),
                  (route) => false,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 90, horizontal: 34),
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.06,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.75],
                ),
              ),
              child: Center(
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
