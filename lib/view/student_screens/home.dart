import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/view/student_screens/student_sections_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/courses_service.dart';
import '../../model/courses_model.dart';
import '../teacher_screens/sections_screen.dart';
import 'courses_by_category_page.dart';

class CoursesStorePage extends StatefulWidget {
  const CoursesStorePage({super.key});

  @override
  State<CoursesStorePage> createState() => _CoursesStorePageState();
}

class _CoursesStorePageState extends State<CoursesStorePage> {
  final CoursesService coursesService = CoursesService();
  late Future<List<CoursesModel>> _futureCourses;
  String userName = 'User';
  List<Color> colorPalette = [
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.teal,
    Colors.amber,
  ];

  List<Map<String, dynamic>> categoriesWithColors(
    List<Map<String, dynamic>> categoriesFromApi,
  ) {
    List<Map<String, dynamic>> result = [];
    for (int i = 0; i < categoriesFromApi.length; i++) {
      result.add({
        "id": categoriesFromApi[i]["id"],
        "name": categoriesFromApi[i]["name"],
        "color": colorPalette[i % colorPalette.length],
        // إعادة استخدام الألوان إذا انتهت
      });
    }
    return result;
  }
  List<Map<String, dynamic>> _categories = [];

  Future<void> _fetchCategories() async {
    try {
      final catsFromApi = await coursesService
          .getCategories(); // جلب من السيرفر
      setState(() {
        _categories = categoriesWithColors(catsFromApi);
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureCourses = coursesService.getAllCourses();
    _fetchCategories();
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
    });
  }

  void _openSections(CoursesModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StudentSectionsScreen(course: course, isPurchased: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // شريط البحث     القديم
              // TextField(
              //   decoration: InputDecoration(
              //     prefixIcon: const Icon(Icons.search),
              //     hintText: 'Search Topic here',
              //     filled: true,
              //     fillColor: Colors.grey[200],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              // ),

              // الجديد
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 55,
                    child: Row(

                      children: [
                        Expanded(
                          child: TextField(
                            //focusNode: _focusNode,
                            //controller: _controller,
                            //onChanged: _onSearchChanged,
                           // onTap: () {
                            //   if (_controller.text.isNotEmpty &&
                            //       _filtered.isNotEmpty) {
                            //     _animController.forward();
                            //   }
                            // },//textAlign: TextAlign.start,

                            decoration: const InputDecoration(
                              hintText: "Search Topic here",
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        GestureDetector(
                          // onTap: () {
                          //   if (_controller.text.isNotEmpty) {
                          //     _closeSuggestions();
                          //     _controller.clear();
                          //   } else {
                          //     _closeSuggestions();
                          //   }
                          // },
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient:  LinearGradient(
                                colors: [Color(0xFFE27BF5), Color(0xFF7C5EF1)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.0, 0.75],
                              ),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              // _controller.text.isEmpty
                            //      ?
                            Icons.search,
                              //    : Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // رسالة الترحيب
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Hello👋\n',
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,),
                        ),
                        TextSpan(
                          text: userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
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
              // التصنيفات
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) {
                    final category = _categories.isNotEmpty
                        ? _categories[i % _categories.length]
                        : {"name": "General", "color": Colors.grey};


                    return // داخل ListView.builder للـ categories
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoursesByCategoryPage(
                                categoryId: int.parse(category['id'].toString()),
                                categoryName: category['name'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: category['color'],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Courses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: ColorManage.firstPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,

                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<CoursesModel>>(
                future: _futureCourses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No courses available.'));
                  }

                  final coursesFirst = snapshot.data!.reversed;
                  List  courses=[];
                  for(int x=0; x<coursesFirst.length; x++){
                    if(x==6) {
                      break;
                    }
                    courses.add(coursesFirst.toList()[x]);
                  }
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      itemBuilder: (ctx, i) {
                        final course = courses.toList()[i];
                        final category = i < _categories.length
                            ? _categories[i]
                            : {"name": "General", "color": Colors.grey};
                        return GestureDetector(
                          onTap: () => _openSections(course),
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child:
                                      course.thumbnail != null &&
                                          course.thumbnail!.isNotEmpty
                                      ? Image.network(
                                          course.thumbnail!,
                                          height: 120,
                                          width: 180,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 120,
                                          color: Colors.grey[300],
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.title ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${category['name']} · 18 Min',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
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
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
