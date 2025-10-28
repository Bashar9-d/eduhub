import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/sections_model.dart';

class SectionsService {
  final String baseUrl = 'https://eduhub44.atwebpages.com/sections.php';

  Future<List<SectionsModel>> getSectionsByCourse(int courseId) async {
    final url = Uri.parse('$baseUrl?action=get_by_course&course_id=$courseId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List sectionsData = data['data'];
        return sectionsData.map((e) => SectionsModel.fromJson(e)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load sections');
    }
  }

  Future<SectionsModel?> getSection(int id) async {
    final url = Uri.parse('$baseUrl?action=get&id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return SectionsModel.fromJson(data['data']);
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load section');
    }
  }

  Future<bool> createSection(SectionsModel section) async {
    final url = Uri.parse('$baseUrl?action=create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(section.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }
  Future<bool> updateSection(SectionsModel section) async {
    final url = Uri.parse('$baseUrl?action=update');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(section.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  Future<bool> deleteSection(int id) async {
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
