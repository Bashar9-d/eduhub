import 'package:eduhub/controller/bottom_nav_bar_controller.dart';
import 'package:eduhub/view/begin_screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomNavBarController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edu hub',
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // ),
        home: SplashScreen(),
      ),
    );
  }
}
