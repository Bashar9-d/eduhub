import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constant/color_manage.dart';
import '../../controller/courses_service.dart';
import '../../model/courses_model.dart';
import 'sections_screen.dart';
import 'dart:math' as math;

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursesService coursesService = CoursesService();
  late Future<List<CoursesModel>> _futureCourses;
  String userName = 'User';


  @override
  void initState() {
    super.initState();
    _futureCourses = _load();
    _loadUserName();
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
        builder: (_) =>
            SectionsScreen(courseId: course.id!, courseTitle: course.title!),
      ),
    );
  }
  void _loadUserName() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
setState(() {
  userName = prefs.getString('name') ?? 'User';
});
  }

  Future<List<CoursesModel>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt('id') ?? 0;
    return coursesService.getCoursesByTeacher(teacherId);
  }



  void _showCourseOptions(CoursesModel course) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.purple),
              title: const Text('تعديل الكورس'),
              onTap: () {
                Navigator.pop(context);
                _openForm(course: course);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف الكورس'),
              onTap: () async {
                Navigator.pop(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل أنت متأكد من حذف هذا الكورس؟'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('نعم')),
                    ],
                  ),
                );
                if (ok == true) {
                  await coursesService.deleteCourse(course.id!);
                  setState(() {
                    _futureCourses = _load();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF), // بنفسجي فاتح
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================== Header ==================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello 👋",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // ================== Stats ==================
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("Students", "150", Icons.people_alt),
                    _buildStatItem("Courses", "7", Icons.menu_book_outlined),
                    _buildStatItem("Evaluation", "4.5", Icons.star_border),
                    _buildStatItem("Messages", "9", Icons.message_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ================== Courses ==================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Courses",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(color: Colors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<List<CoursesModel>>(
                  future: _futureCourses,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    } else if (!snap.hasData || snap.data!.isEmpty) {
                      return const Center(child: Text('No courses found.'));
                    }

                    final courses = snap.data!;
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (ctx, i) {
                        final c = courses[i];
                        final colors = [
                          Colors.orange,
                          Colors.blue,
                          Colors.green,
                          Colors.purple
                        ];
                        final bg = colors[i % colors.length].withOpacity(0.15);

                        return GestureDetector(
                          onTap: () => _openSections(c),
                          onLongPress: () => _showCourseOptions(c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18)),
                                  child: c.thumbnail != null &&
                                      c.thumbnail!.isNotEmpty
                                      ? Image.network(
                                    c.thumbnail!,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    height: 110,
                                    color: bg,
                                    child: const Center(
                                      child: Icon(Icons.image_outlined,
                                          size: 40,
                                          color: Colors.grey),
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
                                        "Art Course",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.title ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ================== Floating Button ==================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
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
        _selected = {for (var c in _categories) int.parse(c['id']): false};
      });

      if (widget.course != null && widget.course!.id != null) {
        _loadCourseCategories(widget.course!.id!);
      } else {
        setState(() => _loadingCategories = false);
      }
    } catch (e) {
      setState(() => _loadingCategories = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب التصنيفات: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب تصنيفات الكورس: $e')));
    }
  }

  Future<List<String>> _listImages(String folderPath) async {
    try {
      final files = await Supabase.instance.client.storage
          .from('uploads')
          .list(path: folderPath);

      return files
          .map(
            (f) => Supabase.instance.client.storage
            .from('uploads')
            .getPublicUrl('$folderPath/${f.name}'),
      )
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على teacher_id')),
      );
      return;
    }

    final selectedCategoryIds = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

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
        ok = await coursesService.createCourseWithGroup(
          course,
          selectedCategoryIds,
        );
      } else {
        ok = await coursesService.updateCourse(
          course,
          categoryIds: selectedCategoryIds,
        );
      }

      if (ok) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل حفظ الكورس')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء الحفظ: $e')));
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
                    validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
                  ),
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'الوصف'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
                  ),
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
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snap.hasError) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Text('فشل تحميل الصور: ${snap.error}'),
                              );
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
                                              final fileName = url
                                                  .split('/')
                                                  .last;

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
                                                      title: const Text(
                                                        'تأكيد الحذف',
                                                      ),
                                                      content: const Text(
                                                        'هل تريد حذف هذه الصورة؟',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            'لا',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            'نعم',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (ok == true) {
                                                    try {
                                                      await Supabase
                                                          .instance
                                                          .client
                                                          .storage
                                                          .from('uploads')
                                                          .remove([
                                                        '$folderPath/$fileName',
                                                      ]);
                                                      setState(
                                                            () =>
                                                            images.removeAt(i),
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'تم حذف الصورة ✅',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'فشل حذف الصورة: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
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
                                          final result = await FilePicker
                                              .platform
                                              .pickFiles(type: FileType.image);
                                          if (result != null) {
                                            final file = File(
                                              result.files.single.path!,
                                            );
                                            final fileName = DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();
                                            final path =
                                                '$folderPath/$fileName';
                                            try {
                                              await Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('uploads')
                                                  .upload(path, file);

                                              final publicURL = Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('uploads')
                                                  .getPublicUrl(path);

                                              setState(
                                                    () => _thumb.text = publicURL,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تم رفع الصورة ✅',
                                                  ),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'فشل رفع الصورة: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'رفع صورة جديدة من الجهاز',
                                        ),
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
                    child: Text(
                      'التصنيفات',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    child: Text(isEdit ? 'تحديث' : 'إنشاء'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*class _CourseListScreenState extends State<CourseListScreen> {
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
        builder: (_) =>
            SectionsScreen(courseId: course.id!, courseTitle: course.title!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Courses",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: ColorManage.firstPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
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
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final c = courses[i];
                return ListTile(
                  onTap: () => _openSections(c),
                  // الانتقال لشاشة الأقسام عند الضغط
                  leading: c.thumbnail!.isNotEmpty//the image is circle
                      ? ClipOval(
                    child: Image.network(
                      c.thumbnail!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                      : null,
                  //   Container(
                  //     decoration: BoxDecoration(shape: BoxShape.circle),
                  //     child: Image.network(
                  //       c.thumbnail!,
                  //       width: 56,
                  //       height: 56,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   )
                  // : null,
                  title: Text(c.title!,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                  subtitle: Text(c.teacherName ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openForm(course: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirm delete'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            try {
                              await coursesService.deleteCourse(c.id!);
                              _load();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Delete failed: $e')),
                              );
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
        _selected = {for (var c in _categories) int.parse(c['id']): false};
      });

      if (widget.course != null && widget.course!.id != null) {
        _loadCourseCategories(widget.course!.id!);
      } else {
        setState(() => _loadingCategories = false);
      }
    } catch (e) {
      setState(() => _loadingCategories = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب التصنيفات: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل جلب تصنيفات الكورس: $e')));
    }
  }

  Future<List<String>> _listImages(String folderPath) async {
    try {
      final files = await Supabase.instance.client.storage
          .from('uploads')
          .list(path: folderPath);

      return files
          .map(
            (f) => Supabase.instance.client.storage
            .from('uploads')
            .getPublicUrl('$folderPath/${f.name}'),
      )
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على teacher_id')),
      );
      return;
    }

    final selectedCategoryIds = _selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

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
        ok = await coursesService.createCourseWithGroup(
          course,
          selectedCategoryIds,
        );
      } else {
        ok = await coursesService.updateCourse(
          course,
          categoryIds: selectedCategoryIds,
        );
      }

      if (ok) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل حفظ الكورس')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء الحفظ: $e')));
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
                    validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
                  ),
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'الوصف'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null,
                  ),
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
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snap.hasError) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content: Text('فشل تحميل الصور: ${snap.error}'),
                              );
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
                                              final fileName = url
                                                  .split('/')
                                                  .last;

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
                                                      title: const Text(
                                                        'تأكيد الحذف',
                                                      ),
                                                      content: const Text(
                                                        'هل تريد حذف هذه الصورة؟',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            'لا',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            'نعم',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (ok == true) {
                                                    try {
                                                      await Supabase
                                                          .instance
                                                          .client
                                                          .storage
                                                          .from('uploads')
                                                          .remove([
                                                        '$folderPath/$fileName',
                                                      ]);
                                                      setState(
                                                            () =>
                                                            images.removeAt(i),
                                                      );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'تم حذف الصورة ✅',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'فشل حذف الصورة: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
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
                                          final result = await FilePicker
                                              .platform
                                              .pickFiles(type: FileType.image);
                                          if (result != null) {
                                            final file = File(
                                              result.files.single.path!,
                                            );
                                            final fileName = DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();
                                            final path =
                                                '$folderPath/$fileName';
                                            try {
                                              await Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('uploads')
                                                  .upload(path, file);

                                              final publicURL = Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('uploads')
                                                  .getPublicUrl(path);

                                              setState(
                                                    () => _thumb.text = publicURL,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'تم رفع الصورة ✅',
                                                  ),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'فشل رفع الصورة: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'رفع صورة جديدة من الجهاز',
                                        ),
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
                    child: Text(
                      'التصنيفات',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    child: Text(isEdit ? 'تحديث' : 'إنشاء'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/