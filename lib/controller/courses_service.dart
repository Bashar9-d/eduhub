import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/courses_model.dart';


class CoursesService {
  // تأكد من وضع http:// أو https:// حسب استضافتك
  static const String baseUrl = 'http://eduhub44.atwebpages.com/courses.php';

  // GET all
  Future<List<CoursesModel>> getAllCourses() async {
    final uri = Uri.parse('$baseUrl?action=get_all');
    final res = await http.get(uri);
    if (res.statusCode == 200) {

      final data = json.decode(res.body);
      // assuming response(true, $CoursesModels) -> structure might be { success: true, data: [...] }
      if (data is Map && data['data'] != null) {

        final list = List.from(data['data']);
        return list.map((e) => CoursesModel.fromJson(e)).toList();
      } else if (data is List) {
        return data.map((e) => CoursesModel.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load CoursesModels');
    }
  }

  // GET by id
  Future<CoursesModel> getCourse(int id) async {
    final uri = Uri.parse('$baseUrl?action=get&id=$id');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is Map && data['data'] != null) {
        return CoursesModel.fromJson(data['data']);
      } else if (data is Map && data['title'] != null) {
        // if backend returns CoursesModel object directly
        return CoursesModel.fromJson(data.map((key, value) => MapEntry(key, value)));
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load CoursesModel');
    }
  }

  // CREATE
  Future<bool> createCourse(CoursesModel CoursesModel) async {
    final uri = Uri.parse('$baseUrl?action=create');
    final body = json.encode(CoursesModel.toJson());
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return (data is Map && data['success'] == true) || (res.body.contains('created'));
    } else {
      throw Exception('Failed to create CoursesModel');
    }
  }

  // UPDATE (requires PHP endpoint to support action=update)
  Future<bool> updateCourse(CoursesModel CoursesModel) async {
    final uri = Uri.parse('$baseUrl?action=update');
    final payload = CoursesModel.toJson();
    if (CoursesModel.id != null) payload['id'] = CoursesModel.id.toString();
    final body = json.encode(payload);
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return (data is Map && data['success'] == true) || res.body.contains('updated');
    } else {
      throw Exception('Failed to update CoursesModel');
    }
  }

  // DELETE (requires PHP endpoint to support action=delete)
  Future<bool> deleteCourse(int id) async {
    final uri = Uri.parse('$baseUrl?action=delete');
    final body = json.encode({'id': id});
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return (data is Map && data['success'] == true) || res.body.contains('deleted');
    } else {
      throw Exception('Failed to delete CoursesModel');
    }
  }
}
