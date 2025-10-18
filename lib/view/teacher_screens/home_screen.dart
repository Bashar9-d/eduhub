import 'package:eduhub/view/teacher_screens/teacher_courses.dart';
import 'package:flutter/material.dart';
import 'group_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int? _teacherId;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherId();
  }

  Future<void> _loadTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id') ?? 0;
    setState(() {
      _teacherId = id;
      _pages.clear();
      _pages.add(const CourseListScreen());
      _pages.add(_teacherId != null ? GroupPage(teacherId: _teacherId!) : const Center(child: Text('No teacher ID')));
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
      ),    );
  }
}
