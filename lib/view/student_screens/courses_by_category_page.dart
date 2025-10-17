
import 'package:eduhub/view/student_screens/student_sections_screen.dart';
import 'package:flutter/material.dart';
import '../../controller/courses_service.dart';
import '../../model/courses_model.dart';


class CoursesByCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CoursesByCategoryPage({super.key, required this.categoryId, required this.categoryName});

  @override
  State<CoursesByCategoryPage> createState() => _CoursesByCategoryPageState();
}

class _CoursesByCategoryPageState extends State<CoursesByCategoryPage> {
  final CoursesService coursesService = CoursesService();
  late Future<List<CoursesModel>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _futureCourses = coursesService.getCoursesByCategory(widget.categoryId);
  }

  void _openSections(CoursesModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentSectionsScreen(course: course, isPurchased: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<CoursesModel>>(
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
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (ctx, i) {
              final course = courses[i];
              return ListTile(
                leading: course.thumbnail != null && course.thumbnail!.isNotEmpty
                    ? Image.network(course.thumbnail!, width: 50, fit: BoxFit.cover)
                    : const SizedBox(width: 50),
                title: Text(course.title ?? ''),
                subtitle: Text('Art Course · 18 Min'),
                onTap: () => _openSections(course),
              );
            },
          );
        },
      ),
    );
  }
}
