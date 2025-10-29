import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/constant/widgets/text_field_manage.dart';
import 'package:eduhub/constant/widgets/text_widget_manage.dart';
import 'package:eduhub/view/settings_screens/setting.dart';
import 'package:flutter/material.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/widgets/style_widget_manage.dart';

class Verifying extends StatefulWidget {
  const Verifying({super.key});

  @override
  State<Verifying> createState() => _VerifyingState();
}

class _VerifyingState extends State<Verifying> {
  TextEditingController oldPassword = TextEditingController();
  bool obscureText = true;
  bool showError = false;

  @override
  void dispose() {
    super.dispose();
    oldPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verifying password'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/verification.png', width: 200, height: 300),
            buildTextField(
              obscure: obscureText,
              controller: oldPassword,
              keyboardType: TextInputType.visiblePassword,
              suffix: IconButton(
                onPressed: () => setState(() => obscureText = !obscureText),
                icon: Icon(
                  color: Colors.black,
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              errorText: showError ? 'Enter valid password' : null,

              hint: 'Enter your old Password',
              label: 'Old Password',
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                setState(() {
                  showError = oldPassword.text.isEmpty;
                });
                if (!showError) {
                  Navigator.push(
                    context,
                    navigatorFunction(nextScreen: ChangePassword()),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: StyleWidgetManage.nextButtonDecoration,
                child: Center(
                  child: buildText(
                    text: 'Verifying',
                    style: TextStyleManage.nextButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController reNewPassword = TextEditingController();

  bool validatePassword({required String password}) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  bool obscureText1 = true;
  bool showError1 = false;
  bool obscureText2 = true;
  bool showError2 = false;

  @override
  void dispose() {
    super.dispose();
    newPassword.dispose();
    reNewPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(title: Text('Change password'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/reset-password.png', width: 200, height: 300),
            buildTextField(
              controller: newPassword,
              obscure: obscureText1,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    obscureText1 = !obscureText1;
                  });
                },
                icon: Icon(
                  color: Colors.black,
                  obscureText1
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              errorText: showError1 ? 'Enter strong password' : null,
              keyboardType: TextInputType.visiblePassword,
              label: 'New Password',
              hint: 'Enter your New Password',
            ),
            buildTextField(
              controller: reNewPassword,
              obscure: obscureText2,

              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    obscureText2 = !obscureText2;
                  });
                },
                icon: Icon(
                  color: Colors.black,
                  obscureText2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              errorText: showError2 ? 'Enter strong password' : null,
              keyboardType: TextInputType.visiblePassword,
              label: 'Confirm Password',
              hint: 'Confirm New Password',
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showError1 = !validatePassword(password: newPassword.text);
                showError2 = !validatePassword(password: reNewPassword.text);
                setState(() {});
                if( newPassword.text != reNewPassword.text){
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text(
                        'The passwords are not the same',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                }
                else if (!showError1 &&
                    !showError2) {

                  Navigator.popUntil(context, (route) => route.isFirst);

                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: StyleWidgetManage.nextButtonDecoration,
                child: Center(
                  child: Text(
                    'Change password',
                    style: TextStyleManage.nextButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
