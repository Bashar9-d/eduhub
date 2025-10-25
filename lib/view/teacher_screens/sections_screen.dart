import 'dart:io';
import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/sections_service.dart';
import '../../controller/lessons_service.dart';
import '../../model/sections_model.dart';
import '../../model/lessons_model.dart';
import 'package:image_picker/image_picker.dart';

class SectionsScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const SectionsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  final supabase = Supabase.instance.client;

  late Future<List<SectionsModel>> _futureSections;
  final Map<int, List<LessonsModel>> _lessonsMap = {};
  final Map<int, bool> _lessonsLoaded = {};

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  void _loadSections() {
    setState(() {
      _futureSections = sectionsService.getSectionsByCourse(widget.courseId);
    });
  }

  void _openAddSectionDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Section Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final newSection = SectionsModel(
                courseId: widget.courseId,
                title: title,
              );
              final ok = await sectionsService.createSection(newSection);
              if (ok) {
                Navigator.pop(context);
                _loadSections();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Section added ')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to add section')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLessons(int sectionId) async {
    setState(() {
      _lessonsLoaded[sectionId] = false;
    });

    final lessons = await lessonsService.getLessonsBySection(sectionId);

    setState(() {
      _lessonsMap[sectionId] = lessons;
      _lessonsLoaded[sectionId] = true;
    });
  }

  void _openAddLessonDialog(int sectionId, String sectionTitle) async {
    final titleController = TextEditingController();
    final lessonsService = LessonsService();
    XFile? pickedVideo;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Lesson Title'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Pick Video'),
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? video = await picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (video != null) {
                  pickedVideo = video;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video selected ')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a lesson title')),
                );
                return;
              }

              if (pickedVideo == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please pick a video')),
                );
                return;
              }

              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final username = prefs.getString('name');
                if (username == null || username.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User name not found!')),
                  );
                  return;
                }

                final file = File(pickedVideo!.path);
                final courseName = Uri.encodeComponent(widget.courseTitle);
                final sectionName = Uri.encodeComponent(sectionTitle);
                final safeFileName = Uri.encodeComponent(
                  file.path.split('/').last,
                );
                final path = '$username/$courseName/$sectionName/$safeFileName';

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                       Center(child: CircularProgress.circular),
                );

                await supabase.storage
                    .from('uploads')
                    .uploadBinary(path, await file.readAsBytes());

                Navigator.pop(context);

                final videoUrl = supabase.storage
                    .from('uploads')
                    .getPublicUrl(path);

                final lesson = LessonsModel(
                  sectionId: sectionId,
                  title: titleController.text.trim(),
                  videoUrl: videoUrl,
                );

                final ok = await lessonsService.createLesson(lesson);

                if (ok) {
                  Navigator.pop(context);
                  await _loadLessons(sectionId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson added ')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add lesson')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to upload video: $e')),
                );
              }
            },
            child: const Text('Add Lesson'),
          ),
        ],
      ),
    );
  }

  void _openEditLessonDialog(LessonsModel lesson) {
    final titleController = TextEditingController(text: lesson.title);
    XFile? pickedVideo;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Lesson Title'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? video = await picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (video != null) {
                  pickedVideo = video;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video selected ')),
                  );
                }
              },
              child: const Text('Pick Video'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a lesson title')),
                );
                return;
              }

              try {
                String? videoUrl = lesson.videoUrl;
                if (pickedVideo != null) {
                  final file = File(pickedVideo!.path);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final username = prefs.getString('name');
                  if (username == null || username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User name not found!')),
                    );
                    return;
                  }

                  final courseName = Uri.encodeComponent(widget.courseTitle);
                  final sectionName = Uri.encodeComponent(
                    lesson.sectionId.toString(),
                  );
                  final safeFileName = Uri.encodeComponent(
                    file.path.split('/').last,
                  );
                  final path =
                      '$username/$courseName/$sectionName/$safeFileName';

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                         Center(child: CircularProgress.circular),
                  );

                  await supabase.storage
                      .from('uploads')
                      .uploadBinary(path, await file.readAsBytes());
                  Navigator.pop(context);
                  videoUrl = supabase.storage
                      .from('uploads')
                      .getPublicUrl(path);
                }

                final updatedLesson = LessonsModel(
                  id: lesson.id,
                  sectionId: lesson.sectionId,
                  title: title,
                  videoUrl: videoUrl,
                );

                final ok = await lessonsService.updateLesson(updatedLesson);

                if (ok) {
                  Navigator.pop(context);
                  await _loadLessons(lesson.sectionId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson updated ')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update lesson')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update video: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteSection(int sectionId) async {
    final ok = await sectionsService.deleteSection(sectionId);
    if (ok) {
      _loadSections();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Section deleted ')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete section')));
    }
  }

  void _editSection(SectionsModel section) {
    final titleController = TextEditingController(text: section.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Section Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final updatedSection = SectionsModel(
                id: section.id,
                courseId: section.courseId,
                title: title,
              );
              final ok = await sectionsService.updateSection(updatedSection);
              if (ok) {
                Navigator.pop(context);
                _loadSections();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Section updated ')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update section')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FB),
      appBar: AppBar(
        backgroundColor:ColorManage.secondPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Sections of ${widget.courseTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor:  ColorManage.secondPrimary,
        onPressed: _openAddSectionDialog,
        tooltip: 'Add Section',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<SectionsModel>>(
        future: _futureSections,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return  Center(child: CircularProgress.circular);
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final sections = snap.data ?? [];
          if (sections.isEmpty) {
            return const Center(child: Text('No sections yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final lessons = _lessonsMap[section.id] ?? [];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  key: ValueKey(section.id),
                  initiallyExpanded: false,
                  onExpansionChanged: (expanded) {
                    if (expanded) _loadLessons(section.id!);
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          section.title ?? 'Section',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        icon:  Icon(Icons.edit, color: ColorManage.secondPrimary),
                        onPressed: () => _editSection(section),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteSection(section.id!),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  children: [
                    if (!_lessonsLoaded.containsKey(section.id))
                       Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: CircularProgress.circular),
                      )
                    else if ((_lessonsMap[section.id] ?? []).isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(child: Text('No lessons yet')),
                      )
                    else
                      ...lessons
                          .map((lesson) => _buildLessonCard(section, lesson))
                          .toList(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _openAddLessonDialog(
                          section.id!,
                          section.title ?? '',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  ColorManage.secondPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Add Lesson",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildLessonCard(SectionsModel section, LessonsModel lesson) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorManage.firstPrimary, ColorManage.secondPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  lesson.videoUrl ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _openEditLessonDialog(lesson),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final ok = await lessonsService.deleteLesson(lesson.id!);
              if (ok) {
                _loadLessons(section.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lesson deleted ')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete lesson')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
