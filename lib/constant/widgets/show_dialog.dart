
import 'package:flutter/material.dart';

import 'circular_progress.dart';

void showDialogWidget({required BuildContext context,required Widget Function(BuildContext) builder,bool barrierDismissible=true}){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: builder
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(); // لإغلاق الـ Dialog
}