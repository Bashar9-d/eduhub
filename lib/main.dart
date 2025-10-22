import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eduhub/controller/bottom_nav_bar_controller.dart';
import 'package:eduhub/view/begin_screens/splash_screen.dart';
import 'package:eduhub/view/student_screens/bottom_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jynyyuxgdcguecpzxhyr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bnl5dXhnZGNndWVjcHp4aHlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNDExNzIsImV4cCI6MjA3NTcxNzE3Mn0.0ixSenYe04SfEakq9-i2aauAKCLmOJiTTZr9zET3kVE',
  );
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(486.1, 1080.2),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BottomNavBarController(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Edu hub',
            home: BottomNavBar(),
          ),
        );
      },
    );
  }
}
