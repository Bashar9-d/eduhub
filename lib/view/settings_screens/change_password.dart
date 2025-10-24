import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/constant/widgets/text_field_manage.dart';
import 'package:eduhub/constant/widgets/text_widget_manage.dart';
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
              controller: oldPassword,
              //fillColor: Color(0xFFDEDCDF),
              obscure: true,
              keyboardType: TextInputType.visiblePassword,
              label: 'Old Password',
              hint: 'Enter your Old Password',
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  navigatorFunction(nextScreen: ChangePassword()),
                );
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

  @override
  void dispose() {
    super.dispose();
    newPassword.dispose();
    reNewPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change password'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/reset-password.png', width: 200, height: 300),
            buildTextField(
              controller: newPassword,
              obscure: true,
              keyboardType: TextInputType.visiblePassword,
              label: 'New Password',
              hint: 'Enter your New Password',
            ),
            buildTextField(
              controller: reNewPassword,
              obscure: true,
              keyboardType: TextInputType.visiblePassword,
              label: 'Confirm Password',
              hint: 'Confirm New Password',
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
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
