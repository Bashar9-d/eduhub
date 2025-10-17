import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/constant/image_manage.dart';
import 'package:eduhub/constant/text_widget_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constant/style_widget_manage.dart';
import '../../constant/textstyle_manage.dart';
import '../../controller/courses_service.dart';
import '../../model/courses_model.dart';

class HomeStudent extends StatefulWidget {
  HomeStudent({super.key});

  @override
  State<HomeStudent> createState() => _HomeStudentState();
}

class _HomeStudentState extends State<HomeStudent> {
  final CoursesService coursesService = CoursesService();

  late Future<List<CoursesModel>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _futureCourses = coursesService.getAllCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    //_futureCourses = coursesService as Future<List<CoursesModel>>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.chat_outlined, color: ColorManage.firstPrimary),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              title: buildText(
                text: 'Hello 👋',
                style: TextStyleManage.listTileHomeStudentHello,
              ),
              subtitle: ShaderMask(
                shaderCallback: (bounds) =>
                    StyleWidgetManage.onBoardingIndicatorTrue.createShader(
                      Rect.fromLTWH(0, 0, bounds.width.w, bounds.height.h),
                    ),
                child: buildText(
                  text: 'Devendra',
                  style: TextStyleManage.listTileHomeStudentName,
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Image.asset(ImageManage.logo),
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(6, (index) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      //width and height from Figma -> 213*155
                      width: MediaQuery.of(context).size.width * 0.6,
                      //435
                      height: MediaQuery.of(context).size.height * 0.2,
                      //14
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: buildText(
                          text: 'Finance',
                          style: TextStyleManage.coursesTypeStyle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 24),
            FutureBuilder<List<CoursesModel>>(
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
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.26, //2
                    child: GridView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // صف واحد فقط
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        //childAspectRatio: 1,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final c = courses[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => ProductPage(product: product),
                            //   ),
                            // );
                          },
                          child: Card(
                            color: Colors.white,
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: c.thumbnail != null
                                          ? Image.network(
                                              c.thumbnail ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/eduhub logo.png',
                                                  ),
                                            )
                                          : Image.asset(
                                              'assets/eduhub logo.png',
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8,
                                    ),
                                    child: buildText(
                                      text: 'Course Type',
                                      style:
                                          TextStyleManage.courseTypeInGridView,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 8,
                                    ),
                                    child: buildText(
                                      text:
                                          "Name Course (No the Description Course)",
                                      style:
                                          TextStyleManage.courseNameInGridView,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
