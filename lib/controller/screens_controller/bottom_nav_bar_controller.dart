import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view/student_screens/home.dart';
import '../../view/student_screens/my_learning.dart';
import '../../view/settings_screens/setting.dart';
import '../../view/teacher_screens/group_page.dart';
import '../../view/teacher_screens/home.dart';

class BottomNavBarController extends ChangeNotifier{
  final List<Widget> _studentScreens=[CoursesStorePage(),MyLearningScreen(),Setting()];

  int? _teacherId;

  final List<Widget> _pages = [];
  List<Widget> get pages=>_pages;
  int? get teacherId=>_teacherId;

  Future<void> loadTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;
      _teacherId = id;
      _pages.clear();


      _pages.add(const CourseListScreen());
      _pages.add(
        _teacherId != null
            ? GroupPage(teacherId: _teacherId!)
            : const Center(child: Text('No teacher ID')),
      );
      _pages.add(Setting());
    notifyListeners();
  }

  int _currentIndex=0;

  List<Widget> get getScreens=>_studentScreens;
  int get getCurrentIndex=>_currentIndex;


  void onPageChanged(int value){
     _currentIndex=value;
     notifyListeners();
   }
}