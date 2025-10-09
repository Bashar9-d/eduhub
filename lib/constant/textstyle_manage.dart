import 'dart:ui';
import 'package:flutter/material.dart';

import 'color_manage.dart';

class TextStyleManage {
  static const TextStyle titleOnBoarding = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23,
  );
  static const TextStyle subtitleOnBoarding = TextStyle(
    color: ColorManage.subtitleOnBoarding,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,

  );

  // static const TextStyle nextButtonOnBoarding = TextStyle(
  //   color: Colors.white,
  //   fontSize: 16,
  //   fontWeight: FontWeight.w600,
  // );
  static const TextStyle skipButtonOnBoarding = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const nextButton = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const textInDropDown = TextStyle(color: Color(0xFF616161));
}
