import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/constant/style_widget_manage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../controller/enrollment_service.dart';
import '../../controller/group_service.dart';
import '../../controller/sections_service.dart';
import '../../controller/lessons_service.dart';
import '../../model/sections_model.dart';
import '../../model/lessons_model.dart';
import '../../model/courses_model.dart';

class StudentSectionsScreen extends StatefulWidget {
  final CoursesModel course;
  final bool isPurchased;

  const StudentSectionsScreen({
    super.key,
    required this.course,
    required this.isPurchased,
  });

  @override
  State<StudentSectionsScreen> createState() => _StudentSectionsScreenState();
}

class _StudentSectionsScreenState extends State<StudentSectionsScreen> {
  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  final EnrollmentService enrollmentService = EnrollmentService();
  late Future<List<SectionsModel>> _futureSections;
  int? _expandedSectionIndex;
  LessonsModel? _selectedLesson;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _futureSections = sectionsService.getSectionsByCourse(widget.course.id!);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _playLesson(LessonsModel lesson) async {
    if (_videoController != null) {
      await _videoController!.dispose();
    }

    // الفيديو قد يكون من السيرفر، لذا نستخدم Network
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        lesson.videoUrl ??
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      ),
    );
    await _videoController!.initialize();
    _videoController!.play();

    setState(() {
      _selectedLesson = lesson;
      _isVideoInitialized = true;
    });
  }

  Future<List<LessonsModel>> _fetchLessons(int sectionId) async {
    return await lessonsService.getLessonsBySection(sectionId);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      // appBar: AppBar(
      //         title: Text(course.title ?? ''),
      //         centerTitle: true,
      //         backgroundColor: Colors.purple,
      //         foregroundColor: Colors.white,
      //       ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // صورة أو فيديو الكورس
          SizedBox(
            height: 270,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: _isVideoInitialized && _videoController != null
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : (course.thumbnail != null && course.thumbnail!.isNotEmpty
                        ? Image.network(course.thumbnail!, fit: BoxFit.cover)
                        : Container(color: Colors.purple.withOpacity(0.2))),
            ),
          ),

          // المحتوى
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان الكورس
                      Center(
                        child: Container(
                          width: 85,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: ColorManage.nonActiveIndicator,
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //back button
                          // IconButton(
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          //   icon: Icon(Icons.arrow_back_outlined),
                          // ),
                          Expanded(
                            child: Text(
                              _selectedLesson?.title ?? course.title ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.purple,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "13 Min",
                                  style: TextStyle(color: Colors.purple),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Art Course",
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Row(
                            children: [
                              Text(
                                "4.8 ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "(2k Reviews)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: ColorManage.subtitleOnBoarding,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        """
${widget.course.description}      
Explore lessons of this course below. The first section is open for all.""",
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      // Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _tabButton("Playlist", true),
                            _tabButton("Review", false),
                            _tabButton("Related", false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // عرض الأقسام
                      FutureBuilder<List<SectionsModel>>(
                        future: _futureSections,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text("No sections available.");
                          }

                          final sections = snapshot.data!;
                          final category = snapshot.data!;
                          return Column(
                            children: sections.asMap().entries.map((entry) {
                              final index = entry.key;
                              final section = entry.value;
                              final locked = index != 0 && !widget.isPurchased;
                              final isExpanded = _expandedSectionIndex == index;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: locked
                                        ? null
                                        : () {
                                            setState(() {
                                              _expandedSectionIndex = isExpanded
                                                  ? null
                                                  : index;
                                            });
                                          },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: locked
                                                  ? Colors.grey[300]
                                                  : Colors.purple[100],
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              locked
                                                  ? Icons.lock
                                                  : Icons.play_arrow,
                                              color: locked
                                                  ? Colors.grey
                                                  : Colors.purple,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  section.title ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Section ${index + 1}",
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!locked)
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.purple,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // عرض الدروس عند الفتح
                                  if (isExpanded)
                                    FutureBuilder<List<LessonsModel>>(
                                      future: _fetchLessons(section.id!),
                                      builder: (context, lessonSnap) {
                                        if (lessonSnap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (lessonSnap.hasError) {
                                          return Text(
                                            "Error: ${lessonSnap.error}",
                                          );
                                        } else if (!lessonSnap.hasData ||
                                            lessonSnap.data!.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              "No lessons available.",
                                            ),
                                          );
                                        }

                                        final lessons = lessonSnap.data!;
                                        return Column(
                                          children: lessons.map((lesson) {
                                            return ListTile(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                    left: 20,
                                                  ),
                                              leading: const Icon(
                                                Icons.play_circle_fill,
                                                color: Colors.purple,
                                              ),
                                              title: Text(lesson.title ?? ''),
                                              subtitle: Text(
                                                lesson.duration ?? '10 min',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              onTap: () {
                                                _playLesson(lesson);
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              );
            },
          ),

          // زر الرجوع
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: StyleWidgetManage.nextButtonDecoration,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                // زر التسجيل
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  int userId = prefs.getInt('id') ?? 0;

                  if (userId == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please login first")),
                    );
                    return;
                  }

                  bool success = await enrollmentService.enrollStudent(
                    userId,
                    widget.course.id!,
                  );
                  if (success) {
                    //  بعد شراء الكورس نضيف الطالب للقروب
                    final group = await GroupService.getGroupByCourse(
                      widget.course.id!,
                    );
                    if (group != null) {
                      await GroupService.addUserToGroup(group.id!, userId);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Course added & Joined Group ✅"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You are already enrolled")),
                    );
                  }
                },

                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.05,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: active
          ? StyleWidgetManage.nextButtonDecoration
          : BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
