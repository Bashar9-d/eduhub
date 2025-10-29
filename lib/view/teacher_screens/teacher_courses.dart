import 'dart:io';

import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/controller/screens_controller/teacher_controller.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:eduhub/view/teacher_screens/teacher_courses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/otherwise/courses_service.dart';
import '../../controller/otherwise/group_service.dart';
import '../../model/courses_model.dart';
import 'sections_screen.dart';
import 'dart:math' as math;

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late TeacherController teachProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teachProvider = Provider.of<TeacherController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      teachProvider.futureCourses = teachProvider.load();
      teachProvider.loadUserName();
      teachProvider.loadImage();
    });
  }

  void _openForm({CoursesModel? course}) async {
    final result = await Navigator.push(
      context,
      navigatorFunction(nextScreen: CourseFormScreen(course: course)),
    );
    if (result == true) teachProvider.load();
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
                  final prefs = await SharedPreferences.getInstance();
                  await teachProvider.coursesService.deleteCourse(course.id!);
                  teachProvider.groupsFuture = GroupService()
                      .getGroupsByTeacher(prefs.getInt('id')!);
                  setState(() {
                    teachProvider.futureCourses = teachProvider.load();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: Consumer<TeacherController>(
        builder: (context, teacherController, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
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
                              teacherController.getUserName,
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
                          backgroundImage: teacherController.thumb == null
                              ? AssetImage('assets/default person picture.webp')
                              : NetworkImage(teacherController.thumb!),
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
                        teacherController.buildStatItem(
                          "Students",
                          "150",
                          Icons.people_alt,
                        ),
                        teacherController.buildStatItem(
                          "Courses",
                          "7",
                          Icons.menu_book_outlined,
                        ),
                        teacherController.buildStatItem(
                          "Evaluation",
                          "4.5",
                          Icons.star_border,
                        ),
                        teacherController.buildStatItem(
                          "Messages",
                          "9",
                          Icons.message_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Courses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("View All", style: TextStyle(color: Colors.purple)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: FutureBuilder<List<CoursesModel>>(
                      future:
                          teacherController.futureCourses ??
                          teacherController.load(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgress.circular);
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
                            final bg = colors[i % colors.length].withOpacity(
                              0.15,
                            );

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
          );
        },
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
  late TeacherController teachProvider = Provider.of<TeacherController>(
    context,
    listen: false,
  );////

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teachProvider = Provider.of<TeacherController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      teachProvider.futureCourses = teachProvider.load();
      teachProvider.loadUserName();
      teachProvider.loadImage();
      teachProvider.fetchCategories();
    });
  }

  Future<void> _save() async {
    if (!teachProvider.formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final teacherId = prefs.getInt('id');
    if (teacherId == null) return;

    final selectedCats = teachProvider.selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final course = CoursesModel(
      id: widget.course?.id,
      title: teachProvider.title.text.trim(),
      description: teachProvider.desc.text.trim(),
      thumbnail: teachProvider.thumbField.text.trim(),
      teacherId: teacherId,
    );

    bool ok = await teachProvider.coursesService.createCourseWithGroup(
      course,
      selectedCats,
    );

    if (ok) {
      Provider.of<TeacherController>(context, listen: false).futureCourses;
      Provider.of<TeacherController>(context, listen: false).groupsFuture =
          GroupService().getGroupsByTeacher(teacherId);
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
        child: Consumer<TeacherController>(
          builder: (context, teacherController, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: teacherController.formKey,
                child: ListView(
                  children: [
                    _buildTextField(teacherController.title, "Title"),
                    const SizedBox(height: 12),
                    _buildTextField(
                      teacherController.desc,
                      "Description",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      teacherController.thumbField,
                      "Image URL",
                      readOnly: true,
                    ),
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
                        onPressed: teacherController.pickAndUploadImage,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    teacherController.loadingCategories
                        ? Center(child: CircularProgress.circular)
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: teacherController.categories.map((cat) {
                              final id = int.parse(cat['id']);
                              final selected =
                                  teacherController.selected[id] ?? false;
                              return ChoiceChip(
                                label: Text(cat['name'] ?? ''),
                                selected: selected,
                                selectedColor: const Color(0xFFB583F0),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.purple,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.purpleAccent,
                                ),
                                onSelected: (val) {
                                  setState(
                                    () => teacherController.selected[id] = val,
                                  );
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
            );
          },
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
