import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../../constant/helpers/prefs.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../constant/widgets/style_widget_manage.dart';
import '../../controller/otherwise/group_service.dart';
import '../../controller/otherwise/lessons_service.dart';
import '../../controller/otherwise/sections_service.dart';
import '../../model/sections_model.dart';
import '../../model/lessons_model.dart';
import '../../model/courses_model.dart';
import '../chat_page.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../controller/downloads_db.dart';

class CourseDetailPage extends StatefulWidget {
  final CoursesModel course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  int? _expandedSectionIndex;
  late Future<List<SectionsModel>> _futureSections;
  LessonsModel? _selectedLesson;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
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
      _videoController?.dispose();
      _chewieController?.dispose();
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        lesson.videoUrl ??
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      ),
    );

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      allowPlaybackSpeedChanging: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.purple,
        handleColor: Colors.purpleAccent,
        bufferedColor: Colors.purple[200]!,
        backgroundColor: Colors.grey[300]!,
      ),
    );

    setState(() {
      _isVideoInitialized = true;
      _selectedLesson = lesson;
    });
  }

  Future<List<LessonsModel>> _fetchLessons(int sectionId) async {
    return await lessonsService.getLessonsBySection(sectionId);
  }

  Future<void> _joinGroup() async {
   // final prefs = await SharedPreferences.getInstance();
    int userId = PrefsHelper.getInt('id') ?? 0;
    if (userId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final group = await GroupService.getGroupByCourse(widget.course.id!);
    if (group != null) {
      bool success = await GroupService.addUserToGroup(group.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Joined Group Successfully "
                : "Already in Group or Error ",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No group found for this course")),
      );
    }
  }
  Future<void> _downloadLesson(LessonsModel lesson) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = path.join(appDir.path, '${lesson.id}.mp4');

      Dio dio = Dio();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Loading ${lesson.title} ...")),
      );

      await dio.download(lesson.videoUrl!, filePath);

      await DownloadsDB.insertDownload(lesson.id!, lesson.title ?? '', filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Loaded ${lesson.title} Successfully ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during loading: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar:
      AppBar(
        title: Text(course.title ?? ''),
        centerTitle: true,
        backgroundColor: ColorManage.secondPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Row(
              children: const [Icon(Icons.group, size: 20), SizedBox(width: 4)],
            ),
            onPressed: () async {
              //final prefs = await SharedPreferences.getInstance();
              int userId = PrefsHelper.getInt('id') ?? 0;
              if (userId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please login first")),
                );
                return;
              }

              final group = await GroupService.getGroupByCourse(
                widget.course.id!,
              );
              if (group != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatPage(groupId: group.id, userId: userId),
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

      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: _isVideoInitialized && _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : (course.thumbnail != null && course.thumbnail!.isNotEmpty
                        ? Image.network(course.thumbnail!, fit: BoxFit.cover)
                        : Container(color: Colors.purple.withOpacity(0.2))),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration:  BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          Text(
                            "4.8 (2k Reviews)",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "${widget.course.description}",
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                      const SizedBox(height: 20),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _tabButton("Playlist", true),
                            _tabButton("Review", false),
                            _tabButton("Related", false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      FutureBuilder<List<SectionsModel>>(
                        future: _futureSections,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return  Center(
                              child: CircularProgress.circular,
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text("No sections available.");
                          }

                          final sections = snapshot.data!;
                          return Column(
                            children: sections.asMap().entries.map((entry) {
                              final index = entry.key;
                              final section = entry.value;
                              final isExpanded = _expandedSectionIndex == index;

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
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
                                        color: Theme.of(context).colorScheme.background,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.purple[100],
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow,
                                              color: Colors.purple,
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

                                  if (isExpanded)
                                    FutureBuilder<List<LessonsModel>>(
                                      future: _fetchLessons(section.id!),
                                      builder: (context, lessonSnap) {
                                        if (lessonSnap.connectionState ==
                                            ConnectionState.waiting) {
                                          return  Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgress.circular,
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
                                              leading: const Icon(Icons.play_circle_fill, color: Colors.purple),
                                              title: Text(lesson.title ?? ''),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.download, color: Colors.purple),
                                                onPressed: () {
                                                  _downloadLesson(lesson);
                                                },
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
        color:Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
