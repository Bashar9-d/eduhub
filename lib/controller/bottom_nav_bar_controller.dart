import 'package:flutter/material.dart';

import '../view/student_screens/a.dart';
import '../view/student_screens/b.dart';
import '../view/student_screens/c.dart';



class BottomNavBarController extends ChangeNotifier{
  final List<Widget> _screens=[A(),B(),C()];
  int _currentIndex=0;

  List<Widget> get getScreens=>_screens;
  int get getCurrentIndex=>_currentIndex;

   void onPageChanged(int value){
     _currentIndex=value;
     notifyListeners();
   }
}