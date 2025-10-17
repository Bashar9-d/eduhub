import 'dart:convert';
import 'dart:io';
import 'package:eduhub/model/courses_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../controller/courses_service.dart';

import 'sections_screen.dart'; // استيراد شاشة الأقسام

class CourseListScreen extends StatefulWidget {
    const CourseListScreen({super.key});
    @override
    State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
    final CoursesService coursesService = CoursesService();
    late Future<List<CoursesModel>> _futureCourses;

    @override
    void initState() {
        super.initState();
        _futureCourses = _load();
    }

    Future<List<CoursesModel>> _load() async {
        final prefs = await SharedPreferences.getInstance();
        final teacherId = prefs.getInt('id') ?? 0;
        return coursesService.getCoursesByTeacher(teacherId);
    }


    void _openForm({CoursesModel? course}) async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
        );
        if (result == true) _load();
    }

    void _openSections(CoursesModel course) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SectionsScreen(courseId: course.id!, courseTitle: course.title!),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Courses')),
            body: FutureBuilder<List<CoursesModel>>(
                future: _futureCourses,
                builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    } else if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                    } else if (!snap.hasData || snap.data!.isEmpty) {
                        return const Center(child: Text('No courses found.'));
                    } else {
                        final courses = snap.data!;
                        return ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (ctx, i) {
                                final c = courses[i];
                                return ListTile(
                                    onTap: () => _openSections(c), // الانتقال لشاشة الأقسام عند الضغط
                                    leading: c.thumbnail!.isNotEmpty
                                        ? Image.network(c.thumbnail!, width: 56, height: 56, fit: BoxFit.cover)
                                        : null,
                                    title: Text(c.title!),
                                    subtitle: Text(c.teacherName ?? ''),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(course: c)),
                                            IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                    final ok = await showDialog<bool>(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                            title: const Text('Confirm delete'),
                                                            content: const Text('Are you sure?'),
                                                            actions: [
                                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                                                            ],
                                                        ),
                                                    );
                                                    if (ok == true) {
                                                        try {
                                                            await coursesService.deleteCourse(c.id!);
                                                            _load();
                                                        } catch (e) {
                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                                                        }
                                                    }
                                                },
                                            ),
                                        ],
                                    ),
                                );
                            },
                        );
                    }
                },
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () => _openForm(),
                child: const Icon(Icons.add),
            ),
        );
    }
}



class CourseFormScreen extends StatefulWidget {
    final CoursesModel? course;
    const CourseFormScreen({super.key, this.course});

    @override
    State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
    final _formKey = GlobalKey<FormState>();
    final CoursesService coursesService = CoursesService();

    late TextEditingController _title;
    late TextEditingController _desc;
    late TextEditingController _thumb;

    List<Map<String, dynamic>> _categories = [];
    Map<int, bool> _selected = {};
    bool _loadingCategories = true;

    @override
    void initState() {
        super.initState();
        _title = TextEditingController(text: widget.course?.title ?? '');
        _desc = TextEditingController(text: widget.course?.description ?? '');
        _thumb = TextEditingController(text: widget.course?.thumbnail ?? '');
        _fetchCategories();
    }

    @override
    void dispose() {
        _title.dispose();
        _desc.dispose();
        _thumb.dispose();
        super.dispose();
    }

    Future<void> _fetchCategories() async {
        setState(() => _loadingCategories = true);
        try {
            final cats = await coursesService.getCategories();
            setState(() {
                _categories = cats;
                _selected = {for (var c in _categories) int.parse(c['id']) : false};
            });

            if (widget.course != null && widget.course!.id != null) {
                _loadCourseCategories(widget.course!.id!);
            } else {
                setState(() => _loadingCategories = false);
            }
        } catch (e) {
            setState(() => _loadingCategories = false);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('فشل جلب التصنيفات: $e')));
        }
    }

    Future<void> _loadCourseCategories(int courseId) async {
        try {
            final cats = await coursesService.getCourseCategories(courseId);
            setState(() {
                for (var id in cats) {
                    if (_selected.containsKey(id)) _selected[id] = true;
                }
                _loadingCategories = false;
            });
        } catch (e) {
            setState(() => _loadingCategories = false);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('فشل جلب تصنيفات الكورس: $e')));
        }
    }

    Future<List<String>> _listImages(String folderPath) async {
        try {
            final files =
            await Supabase.instance.client.storage.from('uploads').list(path: folderPath);

            return files
                .map((f) => Supabase.instance.client.storage
                .from('uploads')
                .getPublicUrl('$folderPath/${f.name}'))
                .toList();
        } catch (e) {
            throw Exception('Failed to list images: $e');
        }
    }

    Future<void> _save() async {
        if (!_formKey.currentState!.validate()) return;

        final prefs = await SharedPreferences.getInstance();
        final teacherId = prefs.getInt('id');

        if (teacherId == null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('لم يتم العثور على teacher_id')));
            return;
        }

        final selectedCategoryIds =
        _selected.entries.where((e) => e.value).map((e) => e.key).toList();

        final course = CoursesModel(
            id: widget.course?.id,
            title: _title.text.trim(),
            description: _desc.text.trim(),
            thumbnail: _thumb.text.trim(),
            teacherId: teacherId,
        );

        try {
            bool ok;
            if (widget.course == null) {
                ok = await coursesService.createCourseWithGroup(course,
                    selectedCategoryIds);
            } else {
                ok = await coursesService.updateCourse(course,
                    categoryIds:  selectedCategoryIds );
            }

            if (ok) {
                Navigator.pop(context, true);
            } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('فشل حفظ الكورس')));
            }
        } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('خطأ أثناء الحفظ: $e')));
        }
    }

    @override
    Widget build(BuildContext context) {
        final isEdit = widget.course != null;

        return Scaffold(
            appBar: AppBar(title: Text(isEdit ? 'تعديل كورس' : 'إنشاء كورس')),
            body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(
                    children: [
                        Form(
                            key: _formKey,
                            child: Column(
                                children: [
                                    TextFormField(
                                        controller: _title,
                                        decoration: const InputDecoration(labelText: 'العنوان'),
                                        validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
                                    TextFormField(
                                        controller: _desc,
                                        decoration: const InputDecoration(labelText: 'الوصف'),
                                        maxLines: 3,
                                        validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
                                    TextFormField(
                                        controller: _thumb,
                                        decoration: const InputDecoration(labelText: 'رابط الصورة'),
                                        readOnly: true,
                                    ),
                                    const SizedBox(height: 12),

                                    ElevatedButton(
                                        onPressed: () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            final username = prefs.getString('name') ?? 'user';
                                            final folderPath = '$username/image_course';

                                            showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (context) => FutureBuilder<List<String>>(
                                                    future: _listImages(folderPath),
                                                    builder: (context, snap) {
                                                        if (snap.connectionState == ConnectionState.waiting) {
                                                            return const Center(child: CircularProgressIndicator());
                                                        } else if (snap.hasError) {
                                                            return AlertDialog(
                                                                title: const Text('Error'),
                                                                content:
                                                                Text('فشل تحميل الصور: ${snap.error}'));
                                                        } else {
                                                            final images = snap.data ?? [];
                                                            return AlertDialog(
                                                                title: const Text('اختر صورة أو ارفع جديدة'),
                                                                content: SizedBox(
                                                                    width: double.maxFinite,
                                                                    child: Column(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                            if (images.isNotEmpty)
                                                                                SizedBox(
                                                                                    height: 200,
                                                                                    child: ListView.builder(
                                                                                        scrollDirection: Axis.horizontal,
                                                                                        itemCount: images.length,
                                                                                        itemBuilder: (ctx, i) {
                                                                                            final url = images[i];
                                                                                            final fileName = url.split('/').last;

                                                                                            return GestureDetector(
                                                                                                onTap: () {
                                                                                                    setState(() {
                                                                                                        _thumb.text = url;
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                },
                                                                                                onLongPress: () async {
                                                                                                    final ok = await showDialog<bool>(
                                                                                                        context: context,
                                                                                                        builder: (_) => AlertDialog(
                                                                                                            title: const Text('تأكيد الحذف'),
                                                                                                            content: const Text(
                                                                                                                'هل تريد حذف هذه الصورة؟'),
                                                                                                            actions: [
                                                                                                                TextButton(
                                                                                                                    onPressed: () =>
                                                                                                                        Navigator.pop(context, false),
                                                                                                                    child: const Text('لا')),
                                                                                                                TextButton(
                                                                                                                    onPressed: () =>
                                                                                                                        Navigator.pop(context, true),
                                                                                                                    child: const Text('نعم')),
                                                                                                            ],
                                                                                                        ),
                                                                                                    );

                                                                                                    if (ok == true) {
                                                                                                        try {
                                                                                                            await Supabase.instance.client.storage
                                                                                                                .from('uploads')
                                                                                                                .remove(['$folderPath/$fileName']);
                                                                                                            setState(() => images.removeAt(i));
                                                                                                            ScaffoldMessenger.of(context)
                                                                                                                .showSnackBar(const SnackBar(
                                                                                                                content:
                                                                                                                Text('تم حذف الصورة ✅')));
                                                                                                        } catch (e) {
                                                                                                            ScaffoldMessenger.of(context)
                                                                                                                .showSnackBar(SnackBar(
                                                                                                                content: Text(
                                                                                                                    'فشل حذف الصورة: $e')));
                                                                                                        }
                                                                                                    }
                                                                                                },
                                                                                                child: Padding(
                                                                                                    padding:
                                                                                                    const EdgeInsets.all(4.0),
                                                                                                    child: Image.network(url),
                                                                                                ),
                                                                                            );
                                                                                        },
                                                                                    ),
                                                                                )
                                                                            else
                                                                                const Text('لا توجد صور بعد.'),
                                                                            const SizedBox(height: 16),
                                                                            ElevatedButton(
                                                                                onPressed: () async {
                                                                                    final result = await FilePicker.platform
                                                                                        .pickFiles(type: FileType.image);
                                                                                    if (result != null) {
                                                                                        final file =
                                                                                        File(result.files.single.path!);
                                                                                        final fileName = DateTime.now()
                                                                                            .millisecondsSinceEpoch
                                                                                            .toString();
                                                                                        final path = '$folderPath/$fileName';
                                                                                        try {
                                                                                            await Supabase.instance.client.storage
                                                                                                .from('uploads')
                                                                                                .upload(path, file);

                                                                                            final publicURL = Supabase.instance
                                                                                                .client.storage
                                                                                                .from('uploads')
                                                                                                .getPublicUrl(path);

                                                                                            setState(() => _thumb.text = publicURL);
                                                                                            ScaffoldMessenger.of(context)
                                                                                                .showSnackBar(const SnackBar(
                                                                                                content:
                                                                                                Text('تم رفع الصورة ✅')));
                                                                                            Navigator.pop(context);
                                                                                        } catch (e) {
                                                                                            ScaffoldMessenger.of(context)
                                                                                                .showSnackBar(SnackBar(
                                                                                                content: Text(
                                                                                                    'فشل رفع الصورة: $e')));
                                                                                        }
                                                                                    }
                                                                                },
                                                                                child:
                                                                                const Text('رفع صورة جديدة من الجهاز'),
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            );
                                                        }
                                                    },
                                                ),
                                            );
                                        },
                                        child: const Text('اختر أو ارفع صورة'),
                                    ),

                                    const SizedBox(height: 16),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('التصنيفات',
                                            style: Theme.of(context).textTheme.titleMedium),
                                    ),
                                    const SizedBox(height: 8),

                                    if (_loadingCategories)
                                        const Center(child: CircularProgressIndicator())
                                    else if (_categories.isEmpty)
                                        const Text('لا توجد تصنيفات.')
                                    else
                                        Column(
                                            children: _categories.map((cat) {
                                                final id = int.parse(cat['id']);
                                                final name = cat['name']?.toString() ?? '';
                                                final checked = _selected[id] ?? false;
                                                return CheckboxListTile(
                                                    title: Text(name),
                                                    value: checked,
                                                    onChanged: (val) =>
                                                        setState(() => _selected[id] = val ?? false),
                                                );
                                            }).toList(),
                                        ),

                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                        onPressed: _save,
                                        child: Text(isEdit ? 'تحديث' : 'إنشاء')),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
