import 'dart:async';

import 'package:eduhub/constant/helpers/prefs.dart';
import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../constant/widgets/course_search_field.dart';
import '../../controller/screens_controller/student_controller.dart';
import '../../model/courses_model.dart';
import 'course_detail_page.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  late StController stProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    stProvider = Provider.of<StController>(context, listen: false);
  }

  //Future<List<CoursesModel>>? _coursesFuture;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stProvider.loadUserId();

      //_coursesFuture= stProvider.enrollmentService.getUserCourses(PrefsHelper.getInt('id')!);
    });
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
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Learning"),
        backgroundColor: ColorManage.secondPrimary,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Consumer<StController>(
        builder: (context, stController, child) {
          return stController.userId == null
              ? Center(child: CircularProgress.circular)
              : FutureBuilder<List<CoursesModel>>(
                  future: stProvider.enrollmentService.getUserCourses(
                    PrefsHelper.getInt('id')!,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgress.circular);
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error.toString()}"),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("You have no courses yet."),
                      );
                    }

                    final courses = snapshot.data!;
                    final displayCourses = _filteredCourses.isNotEmpty
                        ? _filteredCourses
                        : courses;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: //displayCourses.length >= 4 ?4: displayCourses.length,
                              displayCourses.isEmpty
                                  ? courses.length
                                  : displayCourses.length,
                              itemBuilder: (context, i) {
                                // final course = courses[i];
                                final course = displayCourses[i];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseDetailPage(course: course),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child: Image.network(
                                            course.thumbnail ?? '',
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  height: 100,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Course',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                course.title ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
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
                );
          ;
        },
      ),
    );
  }
}
