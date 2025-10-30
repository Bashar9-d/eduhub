import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/otherwise/color_manage.dart';
import '../../controller/screens_controller/bottom_nav_bar_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    Future<bool> willPop() async {
      return await showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: const Text(
            'Exit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Do you want to exit the app?',
            style: TextStyle(
              fontSize: 16,
            ),
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
                backgroundColor: Colors.blue.shade100,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blue,
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
              children: bottomNavBarController.getScreens,
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
                items: [
                  _buildBNBItem(
                    Icons.home_outlined,
                    bottomNavBarController.getCurrentIndex == 0,
                  ),
                  _buildBNBItem(
                    Icons.local_mall_outlined,
                    bottomNavBarController.getCurrentIndex == 1,
                  ),
                  _buildBNBItem(
                    Icons.settings_outlined,
                    bottomNavBarController.getCurrentIndex == 2,
                  ),
                ],
                backgroundColor: Colors.white,
                currentIndex: bottomNavBarController.getCurrentIndex,
                selectedItemColor: Colors.black,
                unselectedItemColor: ColorManage.subtitleOnBoarding,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: (value) => bottomNavBarController.onPageChanged(value),
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
          Icon(icon),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 8,
              height: 8,
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
