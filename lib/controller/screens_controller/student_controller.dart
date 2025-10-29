import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/courses_model.dart';
import '../otherwise/courses_service.dart';
import '../otherwise/enrollment_service.dart';

class StController extends ChangeNotifier{
  String? _thumb;
  List<CoursesModel> allCourses = [];

  final CoursesService coursesService = CoursesService();
  Future<List<CoursesModel>> futureCourses= Future.value([]);
  String userName = 'User';
  List<Color> colorPalette = [
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.amber,
  ];

  List<Map<String, dynamic>> categoriesWithColors(
      List<Map<String, dynamic>> categoriesFromApi,
      ) {
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < categoriesFromApi.length; i++) {
      result.add({
        "id": categoriesFromApi[i]["id"],
        "name": categoriesFromApi[i]["name"],
        "color": colorPalette[i % colorPalette.length],
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories=>_categories;
  String? get thumb => _thumb;

  Future<void> fetchCategories() async {
    try {
      final catsFromApi = await coursesService.getCategories();
      //setState(() {
        _categories = categoriesWithColors(catsFromApi);
      notifyListeners();
        //});
    } catch (e) {
      print("Error fetching categories");
    }
  }

  void loadImage() async {
    final prefs = await SharedPreferences.getInstance();
   // setState(() {
      _thumb = prefs.getString('image') ?? 'assets/default person picture.webp';
    notifyListeners();
      //});
  }

  void loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    //setState(() {
      userName = prefs.getString('name') ?? 'User';
    notifyListeners();
      //});
  }

  final EnrollmentService enrollmentService = EnrollmentService();

  int? userId;

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // setState(() {
      userId = prefs.getInt('id');
      if (userId != null) {
        futureCourses = enrollmentService.getUserCourses(userId!);
      }
      notifyListeners();
    // });
  }


}