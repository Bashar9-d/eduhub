import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../otherwise/color_manage.dart';

Widget inkWellBuilder({
  required void Function() onTap,
  required Widget child,
  void Function()? doubleTap,
  void Function()? onLongTap,
}) {
  return InkWell(
    onTap: onTap,
    onLongPress: onLongTap,
    onDoubleTap: doubleTap,
    child: child,
  );
}

Widget cupertinoWidget({required bool value,required void Function(bool) onChange}) {
  return CupertinoSwitch(
    value: value,
    activeTrackColor: Color.lerp(
      //or activeColor
      ColorManage.firstPrimary,
      ColorManage.secondPrimary,
      0.27,
    )!,
    onChanged:onChange,
  );
}
Widget rowWidget({required Widget text, Widget? trailing}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [text, trailing!],
  );
}

navigatorFunction({required Widget nextScreen}) {
  return MaterialPageRoute(builder: (context) => nextScreen);
}
