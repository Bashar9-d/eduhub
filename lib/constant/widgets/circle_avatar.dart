import 'package:flutter/material.dart';

Widget circleAvatar(
  BuildContext context, {
  double? radius = 28.0,
  double? childSize = 30, icon=Icons.person,
}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    child: Icon(
      icon,
      size: childSize,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
//Widget circleAvatarGr

