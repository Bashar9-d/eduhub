
import 'package:flutter/material.dart';

import '../view/student_screens/courses_store_page.dart';
import '../view/student_screens/mylearning.dart';
import '../view/student_screens/setting.dart';
import '../view/teacher_screens/teacher_courses.dart';
//final List<Widget> _student=[A(),B(),C()];



class BottomNavBarController extends ChangeNotifier{
  final List<Widget> _studentScreens=[CoursesStorePage(),MyLearningScreen(),SettingScreenStudent()];


  int _currentIndex=0;

  List<Widget> get getScreens=>_studentScreens;
  int get getCurrentIndex=>_currentIndex;


  void onPageChanged(int value){
     _currentIndex=value;
     notifyListeners();
   }
}