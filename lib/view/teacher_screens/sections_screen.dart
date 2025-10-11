import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controller/sections_service.dart';
import '../../controller/lessons_service.dart';
import '../../model/sections_model.dart';
import '../../model/lessons_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
class SectionsScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  const SectionsScreen({super.key, required this.courseId, required this.courseTitle});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  final SectionsService sectionsService = SectionsService();
  final LessonsService lessonsService = LessonsService();
  final supabase = Supabase.instance.client;
  late Future<List<SectionsModel>> _futureSections;
  final Map<int, List<LessonsModel>> _lessonsMap = {};

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
        content: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Section Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final newSection = SectionsModel(courseId: widget.courseId, title: title);
              final ok = await sectionsService.createSection(newSection);
              if (ok) {
                Navigator.pop(context);
                _loadSections();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section added ✅')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add section')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLessons(int sectionId) async {
    final lessons = await lessonsService.getLessonsBySection(sectionId);
    setState(() {
      _lessonsMap[sectionId] = lessons;
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
                final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  pickedVideo = video;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video selected ✅')),
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
                // جلب اسم المستخدم من SharedPreferences
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
                final safeFileName = Uri.encodeComponent(file.path.split('/').last);
                final path = '$username/$courseName/$sectionName/$safeFileName';

                // إظهار Progress Indicator أثناء الرفع
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                // رفع الفيديو
                await supabase.storage.from('uploads').uploadBinary(path, await file.readAsBytes());

                // إغلاق Progress Indicator
                Navigator.pop(context);

                // الحصول على الرابط العام للفيديو
                final videoUrl = supabase.storage.from('uploads').getPublicUrl(path);

                // إنشاء الدرس
                final lesson = LessonsModel(
                  sectionId: sectionId,
                  title: titleController.text.trim(),
                  videoUrl: videoUrl,
                );

                final ok = await lessonsService.createLesson(lesson);

                if (ok) {
                  Navigator.pop(context); // إغلاق AlertDialog
                  await _loadLessons(sectionId); // إعادة تحميل الدروس
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson added ✅')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add lesson')),
                  );
                }
              } catch (e) {
                Navigator.pop(context); // إغلاق أي Progress Indicator مفتوح
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
    final videoController = TextEditingController(text: lesson.videoUrl);

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
                final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  pickedVideo = video;
                  videoController.text = video.path;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video selected ✅')),
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


                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  final username = prefs.getString('name');
                  if (username == null || username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User name not found!')),
                    );
                    return;
                  }

                  final courseName = Uri.encodeComponent(widget.courseTitle);
                  final sectionName = Uri.encodeComponent(lesson.sectionId.toString());
                  final safeFileName = Uri.encodeComponent(file.path.split('/').last);
                  final path = '$username/$courseName/$sectionName/$safeFileName';


                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );


                  await supabase.storage.from('uploads').uploadBinary(path, await file.readAsBytes());


                  Navigator.pop(context);

                  videoUrl = supabase.storage.from('uploads').getPublicUrl(path);
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
                    const SnackBar(content: Text('Lesson updated ✅')),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section deleted ✅')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete section')));
    }
  }

  void _editSection(SectionsModel section) {
    final titleController = TextEditingController(text: section.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Section'),
        content: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Section Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final updatedSection = SectionsModel(id: section.id, courseId: section.courseId, title: title);
              final ok = await sectionsService.updateSection(updatedSection);
              if (ok) {
                Navigator.pop(context);
                _loadSections();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section updated ✅')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update section')));
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
      appBar: AppBar(title: Text('Sections of ${widget.courseTitle}')),
      body: FutureBuilder<List<SectionsModel>>(
        future: _futureSections,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final sections = snap.data ?? [];
          if (sections.isEmpty) return const Center(child: Text('No sections yet.'));

          return ListView(
            children: sections.map((s) {
              final lessons = _lessonsMap[s.id] ?? [];
              return ExpansionTile(
                key: ValueKey(s.id),
                title: Row(
                  children: [
                    Expanded(child: Text(s.title ?? '')),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editSection(s)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteSection(s.id!)),
                  ],
                ),
                onExpansionChanged: (expanded) {
                  if (expanded) _loadLessons(s.id!);
                },
                children: [
                  if (lessons.isEmpty) const ListTile(title: Center(child: CircularProgressIndicator(),)),
                  ...lessons.map((l) => ListTile(
                    title: Text(l.title ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _openEditLessonDialog(l)),
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final ok = await lessonsService.deleteLesson(l.id!);
                              if (ok) {
                                _loadLessons(s.id!);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson deleted ✅')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete lesson')));
                              }
                            }),
                      ],
                    ),
                  )),ElevatedButton(
                    onPressed: () => _openAddLessonDialog(s.id!,s.title.toString()),
                    child: const Text('Add Lesson'),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSectionDialog,
        tooltip: 'Add Section',
        child: const Icon(Icons.add),
      ),
    );
  }
}
