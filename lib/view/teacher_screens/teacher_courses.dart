import 'dart:io';

import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constant/otherwise/color_manage.dart';
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
  String? _thumb;

  @override
  void initState() {
    super.initState();
    _futureCourses = _load();
    _loadUserName();
    _loadImage();
  }

  void _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _thumb = prefs.getString('image') ?? 'assets/default person picture.webp';
  }

  void _openForm({CoursesModel? course}) async {
    final result = await Navigator.push(
      context,
      navigatorFunction(nextScreen: CourseFormScreen(course: course)),
    );
    if (result == true) _load();
  }

  void _openSections(CoursesModel course) {
    Navigator.push(
      context,
      navigatorFunction(
        nextScreen: SectionsScreen(
          courseId: course.id!,
          courseTitle: course.title!,
        ),
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
              title: const Text('Update Course'),
              onTap: () {
                Navigator.pop(context);
                _openForm(course: course);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Course'),
              onTap: () async {
                Navigator.pop(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirm deletion'),
                    content: const Text(
                      'Are you sure you want to delete this course?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
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
      backgroundColor: const Color(0xFFF3E8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      backgroundImage: _thumb == null
                          ? AssetImage('assets/default person picture.webp')
                          : NetworkImage(_thumb!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Courses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("View All", style: TextStyle(color: Colors.purple)),
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
                          Colors.purple,
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
                                    top: Radius.circular(18),
                                  ),
                                  child:
                                      c.thumbnail != null &&
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
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
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

  Future<void> _fetchCategories() async {
    try {
      final cats = await coursesService.getCategories();
      setState(() {
        _categories = cats;
        _selected = {for (var c in _categories) int.parse(c['id']): false};
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('name') ?? 'user';
    final folderPath = '$username/image_course';

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '$folderPath/$fileName';

    try {
      await Supabase.instance.client.storage.from('uploads').upload(path, file);
      final publicURL = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(path);
      setState(() => _thumb.text = publicURL);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The image has been uploaded successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed:$e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt('id');
    if (teacherId == null) return;

    final selectedCats = _selected.entries
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

    bool ok = await coursesService.createCourseWithGroup(course, selectedCats);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save course')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3D1F9),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          isEdit ? 'Edit Course' : 'Create Course',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3D1F9), Color(0xFFDAD4FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(_title, "Title"),
                const SizedBox(height: 12),
                _buildTextField(_desc, "Description", maxLines: 3),
                const SizedBox(height: 12),
                _buildTextField(_thumb, "Image URL", readOnly: true),
                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _pickAndUploadImage,
                    icon: const Icon(Icons.upload, color: Colors.purple),
                    label: const Text(
                      "Upload Image",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                const Divider(thickness: 1.2),
                const SizedBox(height: 10),
                const Text(
                  "Categories:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                _loadingCategories
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final id = int.parse(cat['id']);
                          final selected = _selected[id] ?? false;
                          return ChoiceChip(
                            label: Text(cat['name'] ?? ''),
                            selected: selected,
                            selectedColor: const Color(0xFFB583F0),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.purpleAccent),
                            onSelected: (val) {
                              setState(() => _selected[id] = val);
                            },
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 40),

                // Create Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _save,
                    child: Text(
                      isEdit ? "Update" : "Create",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManage.firstPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ColorManage.secondPrimary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
