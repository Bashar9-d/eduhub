import 'package:flutter/material.dart';
import '../../constant/helpers/prefs.dart';
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
  StController() {
    loadCourses();
  }

  Future<void> loadCourses() async {
    allCourses = await coursesService.getAllCourses();
    futureCourses = Future.value(allCourses);
    notifyListeners();
  }


  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories=>_categories;
  String? get thumb => _thumb;

  Future<void> fetchCategories() async {
    try {
      final catsFromApi = await coursesService.getCategories();
        _categories = categoriesWithColors(catsFromApi);
      notifyListeners();
    } catch (e) {
      print("Error fetching categories");
    }
  }

  void loadImage() async {
    //final prefs = await SharedPreferences.getInstance();
      _thumb = PrefsHelper.getString('image') ?? 'assets/default person picture.webp';
    notifyListeners();
  }

  void loadUserName() async {
    //final prefs = await SharedPreferences.getInstance();
      userName = PrefsHelper.getString('name') ?? 'User';
    notifyListeners();
  }

  final EnrollmentService enrollmentService = EnrollmentService();

  int? userId;

  Future<void> loadUserId() async {
    //final prefs = await SharedPreferences.getInstance();
      userId = PrefsHelper.getInt('id');
      if (userId != null) {
        futureCourses = enrollmentService.getUserCourses(userId!);
      }
      notifyListeners();
  }


}