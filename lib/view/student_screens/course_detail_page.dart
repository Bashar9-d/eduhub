import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../controller/sections_service.dart';
import '../../controller/lessons_service.dart';
import '../../controller/group_service.dart';
import '../../model/sections_model.dart';
import '../../model/lessons_model.dart';
import '../../model/courses_model.dart';
import '../chat_page.dart';

class CourseDetailPage extends StatefulWidget {
  final CoursesModel course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  late Future<List<SectionsModel>> _futureSections;
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

  Future<void> _joinGroup() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('id') ?? 0;
    if (userId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final group = await GroupService.getGroupByCourse(widget.course.id!);
    if (group != null) {
      bool success = await GroupService.addUserToGroup(group.id!, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Joined Group Successfully ✅"
                : "Already in Group or Error ❌",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No group found for this course")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: // AppBar داخل CourseDetailPage
      AppBar(
        title: Text(course.title ?? ''),
        actions: [
          IconButton(
            icon: Row(
              children: const [
                Icon(Icons.group, size: 20),
                SizedBox(width: 4),
                Text("Group"),
              ],
            ),
            onPressed: () async {
              // جلب معرف المستخدم
              final prefs = await SharedPreferences.getInstance();
              int userId = prefs.getInt('id') ?? 0;
              if (userId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please login first")),
                );
                return;
              }

              // جلب الـ group الخاص بالكورس
              final group = await GroupService.getGroupByCourse(
                widget.course.id!,
              );
              if (group != null) {
                // فتح شاشة الدردشة وتمرير groupId و userId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatPage(groupId: group.id!, userId: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No group found for this course"),
                  ),
                );
              }
            },
          ),
        ],
      ),

      backgroundColor: Colors.white,
      body: Column(
        children: [
          // فيديو الكورس أو صورة
          SizedBox(
            height: 220,
            width: double.infinity,
            child: ClipRRect(
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
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<SectionsModel>>(
              future: _futureSections,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No sections available."));
                }

                final sections = snapshot.data!;
                return ListView.builder(
                  itemCount: sections.length,
                  itemBuilder: (context, i) {
                    final section = sections[i];
                    return ExpansionTile(
                      title: Text(section.title ?? "Section ${i + 1}"),
                      children: [
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
                              return Text("Error: ${lessonSnap.error}");
                            } else if (!lessonSnap.hasData ||
                                lessonSnap.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("No lessons available."),
                              );
                            }

                            final lessons = lessonSnap.data!;
                            return Column(
                              children: lessons.map((lesson) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.purple,
                                  ),
                                  title: Text(lesson.title ?? ''),
                                  subtitle: Text(
                                    lesson.duration ?? '10 min',
                                    style: const TextStyle(color: Colors.grey),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
