import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/lessons_model.dart';

class LessonsService {
  final String baseUrl = 'https://eduhub44.atwebpages.com/lessons.php';

  Future<List<LessonsModel>> getLessonsBySection(int sectionId) async {
    final url = Uri.parse(
      '$baseUrl?action=get_by_section&section_id=$sectionId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List lessonsData = data['data'];
        return lessonsData.map((e) => LessonsModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load lessons');
    }
  }

  Future<LessonsModel?> getLesson(int id) async {
    final url = Uri.parse('$baseUrl?action=get&id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return LessonsModel.fromJson(data['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load lesson');
    }
  }

  Future<bool> createLesson(LessonsModel lesson) async {
    final url = Uri.parse('$baseUrl?action=create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(lesson.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  Future<bool> updateLesson(LessonsModel lesson) async {
    final url = Uri.parse('$baseUrl?action=update&id=${lesson.id}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(lesson.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  Future<bool> deleteLesson(int id) async {
    final url = Uri.parse('$baseUrl?action=delete&id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }
}
