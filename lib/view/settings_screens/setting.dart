import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/constant/widgets/text_widget_manage.dart';
import 'package:eduhub/view/settings_screens/about_us.dart';
import 'package:eduhub/view/settings_screens/contact_us.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:eduhub/view/settings_screens/privacy_policy.dart';
import 'package:eduhub/view/settings_screens/videos.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/setting_constants/gesture_and_row.dart';
import '../begin_screens/toggle_switch_widget.dart';
import 'change_password.dart';
class Setting extends StatefulWidget {
  const Setting({super.key});
  @override
  State<Setting> createState() => _SettingState();
}
class _SettingState extends State<Setting> {
  String? _thumb ;
  bool isDarkMode = false;
  bool isPushNotifications = false;
  String userName = 'User';

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadImage();
  }

  _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    _thumb = prefs.getString('image')??'assets/default person picture.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: StyleWidgetManage.settingDecoration,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              padding: EdgeInsets.only(bottom: 38),

              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.settings, size: 40, color: Colors.white),
                  buildText(
                    text: 'Setting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 150),
            child: Center(
              child: Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                _thumb == null
                                ? AssetImage(
                                    'assets/default person picture.webp',
                                  )
                                : NetworkImage(_thumb!),
                          ),
                          buildText(
                            text: userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Column(
                        spacing: 25,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText(
                            text: 'Account settings',
                            style: TextStyleManage.settingTextStyleGrey,
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: EditProfile()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'Edit Profile',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: Verifying()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'Change password',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {},
                            child: rowWidget(
                              text: buildText(
                                text: 'Dark mode',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: cupertinoWidget(
                                value: isDarkMode,
                                onChange: (bool? value) {
                                  setState(() {
                                    isDarkMode = value ?? false;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Column(
                        spacing: 25,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText(
                            text: 'More',
                            style: TextStyleManage.settingTextStyleGrey,
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: Videos()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'Videos',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: AboutUs()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'About us',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: PrivacyPolicy()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'Privacy policy',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.push(
                                context,
                                navigatorFunction(nextScreen: ContactUs()),
                              );
                            },
                            child: rowWidget(
                              text: buildText(
                                text: 'Contact Us',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {},
                            child: rowWidget(
                              text: buildText(
                                text: 'Language Setting',
                                style: TextStyleManage.settingTextStyle,
                              ),
                              trailing: Icon(
                                Icons.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                navigatorFunction(
                                  nextScreen: ToggleSwitchWidget(),
                                ),
                                (route) => false,
                              );
                            },
                            child: buildText(
                              text: 'Login out',
                              style: TextStyleManage.settingTextStyleRed,
                            ),
                          ),
                          inkWellBuilder(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove('id');
                              prefs.remove('name');
                              prefs.remove('email');
                              prefs.remove('role');
                              prefs.remove('image');
                              Navigator.pushAndRemoveUntil(
                                context,
                                navigatorFunction(
                                  nextScreen: ToggleSwitchWidget(),
                                ),
                                (route) => false,
                              );
                            },
                            child: buildText(
                              text: 'Remove Account',
                              style: TextStyleManage.settingTextStyleRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}