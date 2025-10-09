import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/constant/style_widget_manage.dart';
import 'package:eduhub/constant/textstyle_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';

import '../../constant/numbers_manage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool showErrorEmail = false;
  bool showErrorPassword = false;
  bool showErrorName = false;

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

  List<String> dropDownItems = ['Student', 'Teacher'];
  String? selectedItem;

  bool showErrorDropDown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NumbersManage.horizontalLoginAndRegister,
              vertical: NumbersManage.verticalLoginAndRegister,
            ),
            child: TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                errorText: showErrorName ? 'This field is required' : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Enter Name here',
                labelText: 'Name',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NumbersManage.horizontalLoginAndRegister,
              vertical: NumbersManage.verticalLoginAndRegister,
            ),
            child: SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                //OR    DropdownButton
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  hintText: 'Choose Role',
                  errorText: showErrorDropDown
                      ? 'This Field is required'
                      : null,
                ),
                items: dropDownItems
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyleManage.textInDropDown,
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (item) => setState(() => selectedItem = item),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NumbersManage.horizontalLoginAndRegister,
              vertical: NumbersManage.verticalLoginAndRegister,
            ),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                errorText: showErrorPassword
                    ? 'Enter your correct email'
                    : null,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Enter Email here',
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NumbersManage.horizontalLoginAndRegister,
              vertical: NumbersManage.verticalLoginAndRegister,
            ),
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
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                showErrorDropDown = selectedItem == null ? true : false;
                showErrorPassword =
                    passwordController.text.isEmpty ||
                    (!validatePassword(password: passwordController.text));
                showErrorEmail =
                    emailController.text.isEmpty ||
                    (!isEmail(email: emailController.text));
                showErrorName = nameController.text.isEmpty;
              });
              if (!showErrorDropDown &&
                  !showErrorEmail &&
                  !showErrorPassword &&
                  !showErrorName) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ToggleSwitchWidget()),
                  (route) => false,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: NumbersManage.verticalRegister2,
                horizontal: NumbersManage.horizontalRegister2,
              ),
              width:
                  MediaQuery.of(context).size.width * NumbersManage.nextWidth,
              height:
                  MediaQuery.of(context).size.height * NumbersManage.nextHeight,

              decoration: StyleWidgetManage.nextButtonDecoration,
              child: Center(
                child: Text('Next', style: TextStyleManage.nextButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
