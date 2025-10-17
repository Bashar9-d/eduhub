import 'package:flutter/material.dart';

Widget buildText({
  required String text,
  int? maxLines,
  TextOverflow? overflow,
  TextStyle? style,
}) {
  return Text(text, style: style, overflow: overflow, maxLines: maxLines);
}
