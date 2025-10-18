import 'package:eduhub/controller/bottom_nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/color_manage.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BottomNavBarController>(
        builder: (context, bottomNavBarController, child) {
          return bottomNavBarController.getScreens[bottomNavBarController
              .getCurrentIndex];
        },
      ),
      bottomNavigationBar: Consumer<BottomNavBarController>(
        builder: (context, bottomNavBarController, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent, // 🔥 يلغي الموجة (splash)
              highlightColor: Colors.transparent, // 🔥 يلغي اللمعة
              splashFactory: NoSplash.splashFactory, // 🔥 يلغي التأثير كليًا
            ),
            child: BottomNavigationBar(items: [
              _buildBNBItem(Icons.home_outlined, bottomNavBarController.getCurrentIndex == 0),
              _buildBNBItem(Icons.abc_outlined, bottomNavBarController.getCurrentIndex == 1),
              _buildBNBItem(Icons.settings_outlined, bottomNavBarController.getCurrentIndex == 2),
            ],
              currentIndex: bottomNavBarController.getCurrentIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: ColorManage.subtitleOnBoarding,
              showSelectedLabels:false ,showUnselectedLabels: false,
              onTap:(value) => bottomNavBarController.onPageChanged(value),
            ),
          );
        },
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
