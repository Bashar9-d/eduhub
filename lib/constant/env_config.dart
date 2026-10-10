import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// Initialize dotenv safely
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // If .env is not present, fall back to safe default constants
    }
  }

  /// Supabase project URL
  static String get supabaseUrl =>
      dotenv.maybeGet('SUPABASE_URL') ??
      'https://jynyyuxgdcguecpzxhyr.supabase.co';

  /// Supabase anon public API key
  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5bnl5dXhnZGNndWVjcHp4aHlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNDExNzIsImV4cCI6MjA3NTcxNzE3Mn0.0ixSenYe04SfEakq9-i2aauAKCLmOJiTTZr9zET3kVE';

  /// Backend API base URL
  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'https://eduhub44.atwebpages.com';

  /// Specific API endpoints
  static String get usersUrl => '$apiBaseUrl/users.php';
  static String get coursesUrl => '$apiBaseUrl/courses.php';
  static String get categoriesUrl => '$apiBaseUrl/categories.php';
  static String get sectionsUrl => '$apiBaseUrl/sections.php';
  static String get lessonsUrl => '$apiBaseUrl/lessons.php';
  static String get groupsUrl => '$apiBaseUrl/groups.php';
  static String get messagesUrl => '$apiBaseUrl/messages.php';
  static String get enrollmentsUrl => '$apiBaseUrl/enrollments.php';
}
