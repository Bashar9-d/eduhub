import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/courses_model.dart';

class EnrollmentService {
  // ضع رابط ملف PHP الخاص بك
  static const String baseUrl = 'http://eduhub44.atwebpages.com/enrollments.php';

  /// ✅ تسجيل طالب في كورس
  Future<bool> enrollStudent(int userId, int courseId) async {
    final uri = Uri.parse('$baseUrl?action=enroll');
    final res = await http.post(uri, body: {
      'user_id': userId.toString(),
      'course_id': courseId.toString(),
    });

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['success'] == true;
    }
    return false;
  }

  /// ✅ جلب جميع الكورسات لطالب معيّن
  Future<List<CoursesModel>> getUserCourses(int userId) async {
    final uri = Uri.parse('$baseUrl?action=get_courses&user_id=$userId');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        // ✅ تحويل البيانات من JSON إلى List<CoursesModel>
        return List<CoursesModel>.from(
          data['data'].map((item) => CoursesModel.fromJson(item)),
        );
      }
    }
    return [];
  }


  /// ✅ جلب جميع الطلاب المسجلين في كورس معيّن
  Future<List<dynamic>> getCourseStudents(int courseId) async {
    final uri = Uri.parse('$baseUrl?action=get_students&course_id=$courseId');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return List.from(data['data']);
      }
    }
    return [];
  }

  /// ✅ إلغاء اشتراك طالب من كورس
  Future<bool> unenroll(int enrollmentId) async {
    final uri = Uri.parse('$baseUrl?action=unenroll');
    final res = await http.post(uri, body: {
      'id': enrollmentId.toString(),
    });

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['success'] == true;
    }
    return false;
  }
}
