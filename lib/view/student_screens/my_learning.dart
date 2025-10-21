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
          ? const Center(
        child: CircularProgressIndicator(
          color: ColorManage.firstPrimary,
        ),
      )
          : FutureBuilder<List<CoursesModel>>(
        future: _futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorManage.firstPrimary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error.toString()}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("You have no courses yet."));
          }

          final courses = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 55,
                        child: Row(

                          children: [
                            Expanded(
                              child: TextField(
                                //focusNode: _focusNode,
                                //controller: _controller,
                                //onChanged: _onSearchChanged,
                                // onTap: () {
                                //   if (_controller.text.isNotEmpty &&
                                //       _filtered.isNotEmpty) {
                                //     _animController.forward();
                                //   }
                                // },//textAlign: TextAlign.start,

                                decoration: const InputDecoration(
                                  hintText: "Search Topic here",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            GestureDetector(
                              // onTap: () {
                              //   if (_controller.text.isNotEmpty) {
                              //     _closeSuggestions();
                              //     _controller.clear();
                              //   } else {
                              //     _closeSuggestions();
                              //   }
                              // },
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient:  LinearGradient(
                                    colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    stops: [0.0, 0.75],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  // _controller.text.isEmpty
                                  //      ?
                                  Icons.search,
                                  //    : Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,

                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, i) {
                      final course = courses[i];
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}
