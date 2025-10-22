
import 'package:flutter/material.dart';

import '../view/student_screens/home.dart';
import '../view/student_screens/my_learning.dart';
import '../view/settings_screens/setting.dart';
import '../view/teacher_screens/teacher_courses.dart';

class BottomNavBarController extends ChangeNotifier{
  final List<Widget> _studentScreens=[CoursesStorePage(),MyLearningScreen(),Setting()];


  int _currentIndex=0;

  List<Widget> get getScreens=>_studentScreens;
  int get getCurrentIndex=>_currentIndex;


  void onPageChanged(int value){
     _currentIndex=value;
     notifyListeners();
   }
}