import 'package:flutter/material.dart';
import '../../constant/color_manage.dart';
import '../../controller/enrollment_service.dart';
import '../../model/courses_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course_detail_page.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  final EnrollmentService enrollmentService = EnrollmentService();
  late Future<List<CoursesModel>> _futureCourses;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('id');
      if (userId != null) {
        _futureCourses = enrollmentService.getUserCourses(userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Learning")),
      body: userId == null
          ? const Center(child: CircularProgressIndicator(color: ColorManage.firstPrimary,))
          : FutureBuilder<List<CoursesModel>>(
        future: _futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: ColorManage.firstPrimary,));
          } else if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            print("Stack Trace: $snapshot");
            return Center(child: Text("Error: $snapshot"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You have no courses yet."));
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, i) {
              final course = courses[i];
              return  ListTile(
                leading: Image.network(course.thumbnail ?? '', width: 50, height: 50, fit: BoxFit.cover),
                title: Text(course.title ?? ''),
                subtitle: Text(course.description ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailPage(
                          course: course
                      ),
                    ),
                  );
                },
              );

            },
          );
        },
      ),
    );
  }
}