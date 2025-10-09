import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'color_manage.dart';

class StyleWidgetManage {
  static const gradiantDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: ColorManage.stopsColor,
    ),
  );

  static  BoxDecoration toggleDecoration = BoxDecoration(
    gradient: LinearGradient(//  OR   onBoardingIndicatorTrue
      colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: ColorManage.stopsColor,
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(40.r),
      bottomRight: Radius.circular(40.r),
    ),
  );

  static final nextButtonDecoration =BoxDecoration(
    borderRadius: BorderRadius.circular(20.r),
    gradient:
    StyleWidgetManage.onBoardingIndicatorTrue,
  );

  static const onBoardingIndicatorTrue = LinearGradient(
    colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: ColorManage.stopsColor,
  );

  static const onBoardingIndicatorFalse = LinearGradient(
    colors: [ColorManage.nonActiveIndicator, ColorManage.nonActiveIndicator],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: ColorManage.stopsColor,
  );
}
