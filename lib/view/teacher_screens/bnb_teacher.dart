import 'package:eduhub/view/teacher_screens/teacher_courses.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/screens_controller/bottom_nav_bar_controller.dart';
import '../settings_screens/setting.dart';
import 'group_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BottomNavBarController bnbProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bnbProvider = Provider.of<BottomNavBarController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bnbProvider.loadTeacherId();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<BottomNavBarController>(
      context,
      listen: true,
    ).pages.isEmpty) {
      return Scaffold(body: Center(child: CircularProgress.circular));
    }

    return Scaffold(
      body: Consumer<BottomNavBarController>(
        builder: (context, bottomNavBarController, child) {
          return IndexedStack(
            index: bottomNavBarController.getCurrentIndex,
            children: bottomNavBarController.pages,
          );
        },
      ),
      bottomNavigationBar: Consumer<BottomNavBarController>(
        builder: (context, bottomNavBarController, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
              currentIndex: bottomNavBarController.getCurrentIndex,
              onTap: (value) => bottomNavBarController.onPageChanged(value),
              //????
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              items: [
                _buildBNBItem(
                  Icons.menu_book,
                  bottomNavBarController.getCurrentIndex == 0,
                ),
                _buildBNBItem(
                  Icons.group,
                  bottomNavBarController.getCurrentIndex == 1,
                ),
                _buildBNBItem(
                  Icons.settings_outlined,
                  bottomNavBarController.getCurrentIndex == 2,
                ),
              ],
            ),
          );
        },
        // child: Theme(
        //   data: Theme.of(context).copyWith(
        //     splashColor: Colors.transparent,
        //     highlightColor: Colors.transparent,
        //     splashFactory: NoSplash.splashFactory,
        //   ),
        //   child: BottomNavigationBar(
        //     currentIndex: _currentIndex,
        //     onTap: _onTabTapped,
        //     selectedItemColor: Colors.black,
        //     unselectedItemColor: Colors.grey,
        //     items: [
        //       _buildBNBItem(Icons.menu_book, _currentIndex == 0),
        //       _buildBNBItem(Icons.group, _currentIndex == 1),
        //       _buildBNBItem(Icons.settings_outlined, _currentIndex == 2),
        //     ],
        //   ),
        // ),
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
