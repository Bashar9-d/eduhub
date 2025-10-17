import 'package:eduhub/view/student_screens/student_sections_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/courses_service.dart';
import '../../model/courses_model.dart';
import '../teacher_screens/sections_screen.dart';


class CoursesStorePage extends StatefulWidget {
  const CoursesStorePage({super.key});

  @override
  State<CoursesStorePage> createState() => _CoursesStorePageState();
}

class _CoursesStorePageState extends State<CoursesStorePage> {
  final CoursesService coursesService = CoursesService();
  late Future<List<CoursesModel>> _futureCourses;
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

  List<Map<String, dynamic>> categoriesWithColors(List<Map<String, dynamic>> categoriesFromApi) {
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < categoriesFromApi.length; i++) {
      result.add({
        "id": categoriesFromApi[i]["id"],
        "name": categoriesFromApi[i]["name"],
        "color": colorPalette[i % colorPalette.length], // إعادة استخدام الألوان إذا انتهت
      });
    }
    return result;
  }

  List<Map<String, dynamic>> _categories = [];

  Future<void> _fetchCategories() async {
    try {
      final catsFromApi = await coursesService.getCategories(); // جلب من السيرفر
      setState(() {
        _categories = categoriesWithColors(catsFromApi);
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureCourses = coursesService.getAllCourses();
    _fetchCategories();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
    });
  }

  void _openSections(CoursesModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage( course: course, isPurchased: false,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // شريط البحث
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Topic here',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // رسالة الترحيب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Hello👋\n', style: TextStyle(fontSize: 18)),
                      TextSpan(
                        text: userName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/images/profile.png'), // صورة البروفايل
                )
              ],
            ),
            const SizedBox(height: 20),

            // التصنيفات
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: cat['color'],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text('Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            FutureBuilder<List<CoursesModel>>(
              future: _futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No courses available.'));
                }

                final courses = snapshot.data!;
                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: courses.length,
                    itemBuilder: (ctx, i) {
                      final course = courses[i];
                      return GestureDetector(
                        onTap: () => _openSections(course),
                        child: Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                                    ? Image.network(course.thumbnail!, height: 120, width: 180, fit: BoxFit.cover)
                                    : Container(height: 120, color: Colors.grey[300]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(course.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Art Course · 18 Min', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
