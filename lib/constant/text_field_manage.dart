
import 'package:eduhub/constant/color_manage.dart';
import 'package:flutter/material.dart';

import 'numbers_manage.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  String? errorText,
}) {
  return  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: NumbersManage.verticalLoginAndRegister),
      Text(label),
     TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManage.field,
            errorText: errorText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),

            ),
          ),
        ),

    ]
  );
}
