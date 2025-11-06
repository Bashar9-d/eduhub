import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/helpers/prefs.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/otherwise/group_service.dart';
import '../../controller/screens_controller/teacher_controller.dart';
import '../../model/courses_model.dart';

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
  );

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

    //final prefs = await SharedPreferences.getInstance();
    final teacherId = PrefsHelper.getInt('id');
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

    bool ok;

    if (widget.course == null) {
      ok = await teachProvider.coursesService.createCourseWithGroup(
        course,
        selectedCats,
      );
    } else {
      ok = await teachProvider.coursesService.updateCourseWithGroup(
        course,
        selectedCats,
      );
    }


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
      //backgroundColor: const Color(0xFFF9F5FF),
      appBar: AppBar(
        backgroundColor: PrefsHelper.getBool('dark') == true
            ? Theme.of(context).colorScheme.background
            : Color(0xFFF3D1F9),
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        // leading: const BackButton(color: Colors.black),
        title: Text(
          isEdit ? 'Edit Course' : 'Create Course',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            // color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: PrefsHelper.getBool('dark') == true
              ? LinearGradient(
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : LinearGradient(
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
                    _buildTextField(
                      teacherController.title,
                      "Title",
                      fillColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      teacherController.desc,
                      "Description",
                      maxLines: 3,
                      fillColor: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      teacherController.thumbField,
                      "Image URL",
                      readOnly: true,
                      fillColor: Theme.of(context).colorScheme.secondary,
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
                    Divider(thickness: 1.2,color: Theme.of(context).colorScheme.primary,),
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
        Color? fillColor = Colors.white,
      }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: ColorManage.firstPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: ColorManage.secondPrimary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
