import 'package:flutter/material.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../constant/widgets/course_search_field.dart';
import '../../controller/otherwise/courses_service.dart';
import '../../model/courses_model.dart';
import '../student_screens/student_sections_screen.dart';

class AllCoursesPage extends StatefulWidget {
  const AllCoursesPage({super.key});

  @override
  State<AllCoursesPage> createState() => _AllCoursesPageState();
}

class _AllCoursesPageState extends State<AllCoursesPage> {
  final CoursesService coursesService = CoursesService();
  late Future<List<CoursesModel>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _futureCourses = coursesService.getAllCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }


  void _openSections(CoursesModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentSectionsScreen(course: course, isPurchased: false),
      ),
    );
  }
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CoursesModel> _filteredCourses = [];
  String searchText = '';
  List<CoursesModel> searchResults = [];

  void _onSearchChanged(String value, List<CoursesModel> courses) {
    setState(() {
      if (value.trim().isEmpty) {
        _filteredCourses.clear();
        return;
      }
      _filteredCourses = courses
          .where(
            (c) => (c.title ?? '').toLowerCase().contains(
          value.trim().toLowerCase(),
        ),
      )
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _filteredCourses.clear();
      _searchController.clear();
      _focusNode.unfocus();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
        backgroundColor: ColorManage.secondPrimary,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CoursesModel>>(
        future: _futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: CircularProgress.circular);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses available.'));
          }

          final courses = snapshot.data!;
          final displayCourses = _filteredCourses.isNotEmpty
              ? _filteredCourses
              : courses;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: CourseSearchField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      courses: courses,
                      onChanged: (value) =>
                          _onSearchChanged(value, courses),
                      onClear: _clearSearch,
                    ),
                  ),
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount:  displayCourses.isEmpty
                        ? courses.length
                        : displayCourses.length,
                    itemBuilder: (context, i) {
                      // final course = courses[i];
                      final course = displayCourses[i];
                      return GestureDetector(
                        onTap: () => _openSections(course),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child:
                                    course.thumbnail != null &&
                                        course.thumbnail!.isNotEmpty
                                    ? Image.network(
                                        course.thumbnail!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(height: 120, color: Colors.grey[300]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  course.title ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  course.description ?? "Unknown",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
