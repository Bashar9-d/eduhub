import 'package:eduhub/constant/setting_constants/gesture_and_row.dart';
import 'package:eduhub/constant/widgets/circle_avatar.dart';
import 'package:eduhub/controller/screens_controller/teacher_controller.dart';
import 'package:eduhub/view/settings_screens/edit_profile.dart';
import 'package:eduhub/view/teacher_screens/course_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/helpers/prefs.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/otherwise/textstyle_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/otherwise/group_service.dart';
import '../../model/courses_model.dart';
import 'sections_screen.dart';

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
                  await teachProvider.coursesService.deleteCourse(course.id!);
                  teachProvider.groupsFuture = GroupService()
                      .getGroupsByTeacher(PrefsHelper.getInt('id')!);
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                        circleAvatar(context),
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
                      color: Theme.of(context).colorScheme.background,
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
                          Icons.people_alt_outlined,
                          color1: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                          color2: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                        ),
                        teacherController.buildStatItem(
                          "Courses",
                          "7",
                          Icons.menu_book_outlined,
                          color1: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                          color2: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                        ),
                        teacherController.buildStatItem(
                          "Evaluation",
                          "4.5",
                          Icons.star_border_outlined,
                          color1: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                          color2: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                        ),
                        teacherController.buildStatItem(
                          "Messages",
                          "9",
                          Icons.message_outlined,
                          color1: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                          color2: PrefsHelper.getBool('dark')==true
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Courses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("View All", style: TextStyleManage.viewAllStyle),
                    ],
                  ),
                  const SizedBox(height: 15),

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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.background,
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
        backgroundColor: ColorManage.secondPrimary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}