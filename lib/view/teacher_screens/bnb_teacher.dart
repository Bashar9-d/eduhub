import 'package:eduhub/view/teacher_screens/home.dart';
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
    Future<bool> willPop() async {
      return await showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text(
            'Exit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: const Text(
            'Do you want to exit the app?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManage.secondPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
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
                backgroundColor: Theme.of(context).colorScheme.background,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                items: [
                  _buildBNBItem(
                    Icons.home_outlined,
                    bottomNavBarController.getCurrentIndex == 0,
                  ),
                  _buildBNBItem(
                    Icons.group_outlined,
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
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBNBItem(IconData icon, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,color: isSelected? Theme.of(context).colorScheme.primary:null,),
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
