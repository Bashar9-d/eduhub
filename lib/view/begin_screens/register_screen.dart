import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/view/begin_screens/toggle_switch_widget.dart';
import 'package:flutter/material.dart';
import '../../constant/otherwise/numbers_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/widgets/text_field_manage.dart';
import '../../controller/begin_controller/auth_service.dart';
import '../../model/users_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool showErrorEmail = false;
  bool showErrorPassword = false;
  bool showErrorName = false;
  bool obsecureText = true;
  bool obsecureText2 = true;

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

  register() async {
    setState(() {
      showErrorDropDown = selectedItem == null ? true : false;
      showErrorPassword =
          passwordController.text.isEmpty ||
          (!validatePassword(password: passwordController.text)) ||
          confirmPasswordController.text != passwordController.text;
      showErrorEmail =
          emailController.text.isEmpty ||
          (!isEmail(email: emailController.text));
      showErrorName = nameController.text.isEmpty;
    });

    if (!showErrorDropDown &&
        !showErrorEmail &&
        !showErrorPassword &&
        !showErrorName) {
      UsersModel newUser = UsersModel(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedItem!.toLowerCase(),
      );

      AuthService authService = AuthService();
      final result = await authService.addUser(newUser);

      if (result["success"] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ToggleSwitchWidget()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Something went wrong")),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: NumbersManage.horizontalLoginAndRegister,
          vertical: NumbersManage.verticalLoginAndRegister,
        ),
        child: ListView(
          children: [
            buildTextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              errorText: showErrorName ? 'This field is required' : null,
              hint: 'Enter Name here',
              label: 'Name',
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: NumbersManage.verticalLoginAndRegister),
            Text("Role"),

            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                dropdownColor: Theme.of(context).colorScheme.background,

                //  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                  alignLabelWithHint: true,
                  hintText: 'Choose Role',
                  errorText: showErrorDropDown
                      ? 'This Field is required'
                      : null,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: dropDownItems
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (item) => setState(() => selectedItem = item),
              ),
            ),

            buildTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: showErrorEmail ? 'Enter your correct email' : null,
              hint: 'Enter Email here',
              label: 'Email',
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            buildTextField(
              obscure: obsecureText,
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              errorText: showErrorPassword ? 'Enter stronger password' : null,
              suffix: IconButton(
                onPressed: () => setState(() {
                  obsecureText = !obsecureText;
                }),
                icon: Icon(
                  color: Theme.of(context).colorScheme.primary,
                  obsecureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              hint: 'Enter Password here',
              label: 'Password',
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            buildTextField(
              obscure: obsecureText2,
              controller: confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              errorText: showErrorPassword ? 'Enter stronger password' : null,
              suffix: IconButton(
                onPressed: () => setState(() {
                  obsecureText2 = !obsecureText2;
                }),
                icon: Icon(
                  color: Theme.of(context).colorScheme.primary,
                  obsecureText2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              hint: 'Enter Confirm Password here',
              label: 'Confirm Password',
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            InkWell(
              onTap: register,
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
                  child: Text('Register', style: TextStyleManage.nextButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
