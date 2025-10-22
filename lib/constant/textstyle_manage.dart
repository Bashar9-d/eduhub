import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_manage.dart';

class TextStyleManage {
  static TextStyle titleOnBoarding = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23.sp,
  );
  static const TextStyle subtitleOnBoarding = TextStyle(
    color: ColorManage.subtitleOnBoarding,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
  );

  static TextStyle skipButtonOnBoarding = TextStyle(
    color: Colors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle listTileHomeStudentName = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle listTileHomeStudentHello = TextStyle(
    color: Colors.black,
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle nextButton = TextStyle(
    color: Colors.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static  TextStyle coursesTypeStyle = TextStyle(
    color: Colors.white,
    fontSize: 30.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle courseNameInGridView= TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 18,
  );

  static TextStyle courseTypeInGridView=TextStyle(
    color: Colors.grey,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const textInDropDown = TextStyle(color: Color(0xFF616161));
}
