import 'package:flutter/material.dart';
import '../../controller/screens_controller/student_controller.dart';
import '../../model/courses_model.dart';
import 'package:provider/provider.dart';
import '../../view/student_screens/student_sections_screen.dart';

class CourseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<CoursesModel> courses;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const CourseSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.courses,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(40),
        color: Theme.of(context).colorScheme.background,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 55,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  onChanged: onChanged,
                  onTap: () {
                    if (controller.text.isNotEmpty) {

                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Search courses...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (controller.text.isNotEmpty) {
                    onClear();
                    controller.clear();
                  } else {
                    onClear();
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.0, 0.75],
                    ),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    controller.text.isEmpty ? Icons.search : Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SearchCoursesGridScreen extends StatefulWidget {
  const SearchCoursesGridScreen({super.key});

  @override
  State<SearchCoursesGridScreen> createState() => _SearchCoursesGridScreenState();
}

class _SearchCoursesGridScreenState extends State<SearchCoursesGridScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CoursesModel> _filtered = [];

  void _onSearchChanged(String value, List<CoursesModel> courses) {
    setState(() {
      if (value.trim().isEmpty) {
        _filtered.clear();
        return;
      }
      _filtered = courses
          .where((c) =>
          (c.title ?? '').toLowerCase().contains(value.trim().toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _filtered.clear();
      _controller.clear();
      _focusNode.unfocus();
    });
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
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E9FF),
      body: SafeArea(
        child: Consumer<StController>(
          builder: (context, stController, _) {
            return FutureBuilder<List<CoursesModel>>(
              future: stController.futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C5EF1),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading courses"));
                }

                final courses = snapshot.data ?? [];

                // إذا في بحث استخدمه، إذا لا اعرض كل الكورسات
                final displayCourses = _filtered.isNotEmpty ? _filtered : courses;

                return Column(
                  children: [
                    // ويدجت البحث
                    CourseSearchField(
                      controller: _controller,
                      focusNode: _focusNode,
                      courses: courses,
                      onChanged: (value) => _onSearchChanged(value, courses),
                      onClear: _clearSearch,
                    ),

                    // شبكة الكورسات
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: displayCourses.length,
                        itemBuilder: (context, index) {
                          final course = displayCourses[index];
                          return GestureDetector(
                            onTap: () => _openSections(course),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: course.thumbnail != null
                                          ? Image.network(
                                        course.thumbnail!,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      course.title ?? 'Untitled',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold),
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
            );
          },
        ),
      ),
    );
  }
}

