import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:eduhub/view/student_screens/student_sections_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/widgets/circle_avatar.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/screens_controller/student_controller.dart';
import '../../model/courses_model.dart';
import 'all_courses_page.dart';
import '../../constant/widgets/course_search_field.dart';
import 'courses_by_category_page.dart';

class CoursesStorePage extends StatefulWidget {
  const CoursesStorePage({super.key});

  @override
  State<CoursesStorePage> createState() => _CoursesStorePageState();
}

class _CoursesStorePageState extends State<CoursesStorePage> {


  late StController stProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    stProvider = Provider.of<StController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      stProvider.futureCourses = stProvider.coursesService.getAllCourses().then((courses) {
        stProvider.allCourses = courses;
        return courses;
      });

      stProvider.fetchCategories();
      stProvider.loadUserName();
      stProvider.loadImage();
    });
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
          .where((c) =>
          (c.title ?? '')
              .toLowerCase()
              .contains(value.trim().toLowerCase()))
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<StController>(
        builder: (context, stController, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<CoursesModel>>(
                future: stController.futureCourses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgress.circular);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No courses available.'),
                    );
                  }

                  final courses = snapshot.data!;
                  final displayCourses =
                  _filteredCourses.isNotEmpty ? _filteredCourses : courses;

                  return ListView(
                    children: [

                      CourseSearchField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        courses: courses,
                        onChanged: (value) => _onSearchChanged(value, courses),
                        onClear: _clearSearch,
                      ),

                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            navigatorFunction(nextScreen: EditProfile()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Hello👋\n',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: stController.userName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            circleAvatar(context),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: stController.categories.length,
                          itemBuilder: (ctx, i) {
                            final category = stController.categories.isNotEmpty
                                ? stController
                                .categories[i % stController.categories.length]
                                : {"name": "General", "color": Colors.grey};

                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CoursesByCategoryPage(
                                        categoryId: int.parse(
                                          category['id'].toString(),
                                        ),
                                        categoryName: category['name'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.4,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: category['color'],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    category['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Text(
                            'Courses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              splashFactory: NoSplash.splashFactory,
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AllCoursesPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  color: ColorManage.firstPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:displayCourses.length >= 4 ?4: displayCourses.length,
                          itemBuilder: (ctx, i) {
                            final course = displayCourses[i];
                            final category = i < stController.categories.length
                                ? stController.categories[i]
                                : {"name": "General", "color": Colors.grey};
                            return GestureDetector(
                              onTap: () => _openSections(course),
                              child: Container(
                                width: 180,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color:Theme.of(context).colorScheme.background,
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
                                      child: course.thumbnail != null &&
                                          course.thumbnail!.isNotEmpty
                                          ? Image.network(
                                        course.thumbnail!,
                                        height: 120,
                                        width: 180,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.title ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${category['name']} · 18 Min',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
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
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
