
import 'package:eduhub/view/teacher_screens/teacher_courses.dart';
import 'package:flutter/material.dart';
import '../../constant/color_manage.dart';
import '../settings_screens/setting.dart';
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
      _pages.add(
        _teacherId != null
            ? GroupPage(teacherId: _teacherId!)
            : const Center(child: Text('No teacher ID')),
      );
      _pages.add(Setting());
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: [
            _buildBNBItem(Icons.menu_book, _currentIndex == 0),
            _buildBNBItem(Icons.group, _currentIndex == 1),
            _buildBNBItem(Icons.settings_outlined, _currentIndex == 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBNBItem(IconData icon, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: ColorManage.firstPrimary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 6),
        ],
      ),
      label: '',
    );
  }
}
