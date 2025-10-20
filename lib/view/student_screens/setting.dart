import 'package:eduhub/constant/style_widget_manage.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
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
              margin: EdgeInsets.symmetric(horizontal: MediaQuery
                  .of(context)
                  .size
                  .width * 0.05, vertical:12),
              // width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.settings, size: 35, color: Colors.white),
                  Text(
                    'Setting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'User Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Column(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Settings',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Add a payment method',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.add),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Push notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Dark mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
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
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'About us',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Privacy policy',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contact Us',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Language Setting',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Login out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Remove Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right_rounded),
                              ],
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