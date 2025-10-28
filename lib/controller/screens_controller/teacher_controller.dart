import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/courses_model.dart';
import '../otherwise/courses_service.dart';

class TeacherController extends ChangeNotifier {
  final CoursesService coursesService = CoursesService();
   Future<List<CoursesModel>>? futureCourses;////
  String userName = 'User';
  String? _thumb;

  String? get thumb => _thumb;

  String get getUserName => userName;

  final formKey = GlobalKey<FormState>();

  late TextEditingController title;
  late TextEditingController desc;
  late TextEditingController thumbField;

  List<Map<String, dynamic>> categories = [];
  Map<int, bool> selected = {};
  bool _loadingCategories = true;

  bool get loadingCategories => _loadingCategories;

  TeacherController() {
    title = TextEditingController();
    desc = TextEditingController();
    thumbField = TextEditingController();
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    thumbField.dispose();
    super.dispose();
  }

  void loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _thumb = prefs.getString('image') ?? 'assets/default person picture.webp';
    notifyListeners();
  }

  void loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('name') ?? 'User';
    notifyListeners();
  }

  Future<List<CoursesModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt('id') ?? 0;

    futureCourses= coursesService.getCoursesByTeacher(teacherId);
    notifyListeners();
    return futureCourses!;

  }

  Future<void> fetchCategories() async {
    try {
      final cats = await coursesService.getCategories();
      categories = cats;
      selected = {for (var c in categories) int.parse(c['id']): false};
      _loadingCategories = false;
      notifyListeners();
    } catch (e) {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Widget buildStatItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndUploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('name') ?? 'user';
    final folderPath = '$username/image_course';

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '$folderPath/$fileName';

    try {
      await Supabase.instance.client.storage.from('uploads').upload(path, file);
      final publicURL = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(path);
      thumbField.text = publicURL;
      notifyListeners();
    } catch (e) {
      print('Image upload failed: $e');
    }
  }
}
