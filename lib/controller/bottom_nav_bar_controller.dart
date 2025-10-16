import 'package:eduhub/view/teacher_screens/chat.dart';
import 'package:eduhub/view/teacher_screens/setting.dart';
import 'package:eduhub/view/teacher_screens/teacher.dart';
import 'package:flutter/material.dart';

import '../view/student_screens/home.dart';
import '../view/student_screens/mylearning.dart';
import '../view/student_screens/setting.dart';
//final List<Widget> _student=[A(),B(),C()];



class BottomNavBarController extends ChangeNotifier{
  final List<Widget> _studentScreens=[HomeStudent(),MyLearningScreen(),SettingScreenStudent()];
  final List<Widget> _teacherScreens=[CourseListScreen(),ChatScreen(),SettingScreen()];

  int _currentIndex=0;

  List<Widget> get getScreens=>_studentScreens;
  int get getCurrentIndex=>_currentIndex;
  List<Widget> get getTeacherScreens=>_teacherScreens;


  void onPageChanged(int value){
     _currentIndex=value;
     notifyListeners();
   }
}