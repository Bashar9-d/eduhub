import 'dart:io';

import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constant/helpers/prefs.dart';
import '../../model/courses_model.dart';
import '../../model/group_model.dart';
import '../../model/lessons_model.dart';
import '../../model/sections_model.dart';
import '../otherwise/courses_service.dart';
import '../otherwise/lessons_service.dart';
import '../otherwise/sections_service.dart';

class TeacherController extends ChangeNotifier {
  final CoursesService coursesService = CoursesService();
  Future<List<CoursesModel>>? futureCourses;
  String userName = 'User';
  String? _thumb;

  String? get thumb => _thumb;

  String get getUserName => userName;

  final formKey = GlobalKey<FormState>();
  Future<List<GroupModel>> groupsFuture = Future.value([]);
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
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    _thumb = PrefsHelper.getString('image') ?? 'assets/default person picture.webp';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void loadUserName() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = PrefsHelper.getString('name') ?? 'User';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<List<CoursesModel>> load() async {
   // final prefs = await SharedPreferences.getInstance();
    final teacherId = PrefsHelper.getInt('id') ?? 0;

    futureCourses = coursesService.getCoursesByTeacher(teacherId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Widget buildStatItem(
    String title,
    String value,
    IconData icon, {
    Color? color1 = Colors.black54,
    Color? color2 = Colors.black54,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: ColorManage.firstPrimary),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndUploadImage() async {
   // final prefs = await SharedPreferences.getInstance();
    final username = PrefsHelper.getString('name') ?? 'user';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Image upload failed: $e');
    }
  }

  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  final supabase = Supabase.instance.client;

  Future<List<SectionsModel>>? futureSections;
  final Map<int, List<LessonsModel>> _lessonsMap = {};
  final Map<int, bool> _lessonsLoaded = {};

  SectionsService get getSectionsService => sectionsService;

  LessonsService get getLessonsService => lessonsService;

  get getSupabase => supabase;

  Map<int, List<LessonsModel>> get lessonsMap => _lessonsMap;

  Map<int, bool> get lessonsLoaded => _lessonsLoaded;

  void loadSections(int courseId) {
    futureSections = sectionsService.getSectionsByCourse(courseId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadLessons(int sectionId) async {
    _lessonsLoaded[sectionId] = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final lessons = await lessonsService.getLessonsBySection(sectionId);

    _lessonsMap[sectionId] = lessons;
    _lessonsLoaded[sectionId] = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
