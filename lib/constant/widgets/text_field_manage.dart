import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:flutter/material.dart';
import '../otherwise/numbers_manage.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  String? errorText,
  Widget? suffix,
  Color? fillColor
}) {
  return  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: NumbersManage.verticalLoginAndRegister),
      Text(label),
     StatefulBuilder(
       builder: (context, setState) {
        return TextField(
           controller: controller,
           keyboardType: keyboardType,
           obscureText: obscure,
           onChanged: (value) {
             setState(() {});
           },
           decoration: InputDecoration(
             filled: true,
             fillColor: fillColor??ColorManage.field,
             errorText: errorText,
             suffixIcon: controller.text.isNotEmpty?suffix:null,
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
         );
       },
       //child:
     ),
    ]
  );
}
