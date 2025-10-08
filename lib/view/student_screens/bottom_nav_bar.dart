import 'package:eduhub/controller/bottom_nav_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          return BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'a'),
              BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'b'),
              BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'c'),
            ],
            onTap: (value) => bottomNavBarController.onPageChanged(value),
            currentIndex: bottomNavBarController.getCurrentIndex,

          );
        },
      ),
    );
  }
}
