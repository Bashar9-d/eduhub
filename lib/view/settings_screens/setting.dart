import 'package:eduhub/constant/widgets/style_widget_manage.dart';
import 'package:eduhub/constant/widgets/text_widget_manage.dart';
import 'package:eduhub/controller/screens_controller/setting_controller.dart';
import 'package:eduhub/constant/helpers/theme.dart';
import 'package:eduhub/view/settings_screens/about_us.dart';
import 'package:eduhub/view/settings_screens/contact_us.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:eduhub/view/settings_screens/privacy_policy.dart';
import 'package:eduhub/view/settings_screens/downloaded_videos_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/helpers/prefs.dart';
import '../../constant/helpers/theme_provider.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/setting_constants/gesture_and_row.dart';
import '../../constant/widgets/circle_avatar.dart';
import '../begin_screens/toggle_switch_widget.dart';
import 'change_password.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late SettingController settingProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settingProvider = Provider.of<SettingController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SettingController>(context, listen: false);
      provider.loadUserName();
      provider.loadImage();
      PrefsHelper.getBool('dark') ?? null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<SettingController>(
        builder: (context, settingController, child) {
          return Stack(
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
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: [
                        BoxShadow(color: Colors.black54, blurRadius: 1),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            spacing: 10,
                            children: [
                              circleAvatar(context),
                              buildText(
                                text: settingController.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color:Colors.grey
                        ),
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
                                    navigatorFunction(
                                      nextScreen: EditProfile(),
                                    ),
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
                              rowWidget(
                                text: buildText(
                                  text: 'Dark mode',
                                  style: TextStyleManage.settingTextStyle,
                                ),
                                trailing: cupertinoWidget(
                                  value:
                                      PrefsHelper.getBool('dark') ??
                                      settingController.isDarkMood,
                                  onChange: (bool? value) async {
                                    settingController.isDarkMood =
                                        value ?? false;
                                    if (PrefsHelper.getBool('dark') == true) {
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).themeData = darkMode;
                                    }
                                    Provider.of<ThemeProvider>(
                                      context,
                                      listen: false,
                                    ).toggleTheme();
                                    await PrefsHelper.setBool(
                                      'dark',
                                      settingController.isDarkMood,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: Colors.grey

                        ),
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

                              if (PrefsHelper.getString('role') == 'student')
                                inkWellBuilder(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      navigatorFunction(
                                        nextScreen: DownloadedVideosPage(),
                                      ),
                                    );
                                  },
                                  child: rowWidget(
                                    text: buildText(
                                      text: 'Downloaded videos',
                                      style: TextStyleManage.settingTextStyle,
                                    ),
                                    trailing: Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                    ),
                                  ),
                                ),
                              // inkWellBuilder(
                              //   onTap: () {},
                              //   child: rowWidget(
                              //     text: buildText(
                              //       text: 'Language Setting',
                              //       style: TextStyleManage.settingTextStyle,
                              //     ),
                              //     trailing: Icon(
                              //       Icons.keyboard_arrow_right_rounded,
                              //     ),
                              //   ),
                              // ),
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
                                    navigatorFunction(
                                      nextScreen: PrivacyPolicy(),
                                    ),
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
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    useSafeArea: true,
                                    builder: (context) => AlertDialog(
                                      scrollable: true,
                                      title: const Text(
                                        'Login out',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                      content: const Text(
                                        'Do you want to Login out?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade100,
                                          ),
                                          onPressed: () {
                                            PrefsHelper.remove('email');
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              navigatorFunction(
                                                nextScreen: ToggleSwitchWidget(),
                                              ),
                                                  (route) => false,
                                            );
                                          },
                                          child: const Text(
                                            'Login Out',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ColorManage.secondPrimary,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                },
                                child: buildText(
                                  text: 'Login out',
                                  style: TextStyleManage.settingTextStyleRed,
                                ),
                              ),
                              inkWellBuilder(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    useSafeArea: true,
                                    builder: (context) => AlertDialog(
                                      scrollable: true,
                                      title: const Text(
                                        'Remove',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      ),
                                      content: const Text(
                                        'Do you want to remove your account?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade100,
                                          ),
                                          onPressed: () {
                                           // Navigator.of(context).pop(true);
                                            PrefsHelper.remove('id');
                                            PrefsHelper.remove('name');
                                            PrefsHelper.remove('email');
                                            PrefsHelper.remove('role');
                                            PrefsHelper.remove('image');
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              navigatorFunction(
                                                nextScreen: ToggleSwitchWidget(),
                                              ),
                                                  (route) => false,
                                            );
                                          },
                                          child: const Text(
                                            'Remove',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: ColorManage.secondPrimary,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
          );
        },
      ),
    );
  }
}
