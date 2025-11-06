import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/courses_model.dart';
import 'group_service.dart';


class CoursesService {

  static const String baseUrl = 'http://eduhub44.atwebpages.com/courses.php';

  Future<List<CoursesModel>> getCoursesByCategory(int categoryId) async {
    final uri = Uri.parse('$baseUrl?action=get_by_category&category_id=$categoryId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        return List<CoursesModel>.from(data['data'].map((x) => CoursesModel.fromJson(x)));
      }
      return [];
    } else {
      throw Exception('Failed to load courses by category');
    }
  }
  Future<List<CoursesModel>> getAllCourses() async {
    final uri = Uri.parse('$baseUrl?action=get_all');
    final res = await http.get(uri);
    if (res.statusCode == 200) {

      final data = json.decode(res.body);
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
  Future<List<CoursesModel>> getCoursesByTeacher(int teacherId) async {
    final uri = Uri.parse('$baseUrl?action=get_by_teacher&teacher_id=$teacherId');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
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
  Future<bool> createCourseWithGroup(CoursesModel courseModel, List<int> categoryIds) async {
    try {

      final courseUri = Uri.parse('$baseUrl?action=create');
      final courseBody = json.encode(courseModel.toJson());
      final courseRes = await http.post(
        courseUri,
        headers: {'Content-Type': 'application/json'},
        body: courseBody,
      );

      print('📩 Course response: ${courseRes.body}');

      if (courseRes.statusCode != 200 || courseRes.body.isEmpty) {
        throw Exception('Failed to create course or empty response');
      }

      final courseData = json.decode(courseRes.body);
      if (!(courseData is Map && courseData['success'] == true)) {
        throw Exception('Course creation failed: ${courseRes.body}');
      }

      final int courseId =
          courseData['data']?['id'] ??
              courseData['data']?['course_id'] ??
              courseData['id'] ??
              courseData['course_id'];

      if (courseId == 0 || courseId == null) {
        throw Exception('Invalid course ID');
      }

      print('✅ Course created with ID: $courseId');

      final groupName = '${courseModel.title}_Group';
      final teacherId = courseModel.teacherId;
      if (teacherId == null) throw Exception('Teacher ID is required to create group');

      final groupId = await GroupService.createGroup(courseId, teacherId, groupName);
      if (groupId == null) throw Exception('Group creation failed');

      print('👥 Group created successfully with ID: $groupId');


      if (categoryIds.isNotEmpty) {
        final assignResponse = await http.post(
          Uri.parse('$baseUrl?action=assign_categories'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'course_id': courseId,
            'category_ids': categoryIds,
          }),
        );

        final assignJson = jsonDecode(assignResponse.body);
        if (assignJson['success'] == true) {
          print('🏷️ Categories assigned successfully');
        } else {
          print('⚠️ Course created but categories assignment failed: ${assignJson['message']}');
        }
      } else {
        print('ℹ️ No categories to assign.');
      }

      return true;
    } catch (e) {
      print('❌ Error in createCourseWithGroup: $e');
      return false;
    }
  }



  Future<bool> updateCourse(CoursesModel course,
      {required List<int> categoryIds}) async {
    try {
      final url = Uri.parse('$baseUrl/courses.php?action=update');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(course.toJson()),
      );

      final body = jsonDecode(res.body);
      if (body['success'] == true) {

        await http.post(
          Uri.parse('$baseUrl/courses.php?action=assign_categories'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'course_id': course.id,
            'category_ids': categoryIds,
          }),
        );
        return true;
      } else {
        print('❌ Update failed: ${res.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error updateCourse: $e');
      return false;
    }
  }
  Future<bool> updateCourseWithGroup(CoursesModel course, List<int> categoryIds) async {
    try {

      bool success = await updateCourse(course, categoryIds: categoryIds);

      if (success) {
        print('✅ Course updated successfully.');

        final updatedGroup = await GroupService.updateGroupName(
          course.id!,
          course.title ?? '',
        );

        if (updatedGroup) {
          print('✅ Group name updated successfully.');
        } else {
          print('⚠️ Failed to update group name.');
        }

        return true;
      } else {
        print('❌ Course update failed.');
        return false;
      }
    } catch (e) {
      print('⚠️ Error in updateCourseWithGroup: $e');
      return false;
    }
  }

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

  Future<List<int>> getCourseCategories(int courseId) async {
    try {
      final uri = Uri.parse('$baseUrl?action=get_categories&course_id=$courseId');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data is Map && data['success'] == true && data['data'] != null) {

          final categories = List.from(data['data']);
          if (categories.isNotEmpty && categories.first is Map) {
            return categories.map<int>((c) => int.tryParse(c['id'].toString()) ?? 0).toList();
          } else {
            return categories.map<int>((c) => int.tryParse(c.toString()) ?? 0).toList();
          }
        } else {
          print('⚠️ Unexpected response format: $data');
          return [];
        }
      } else {
        throw Exception('Failed to load course categories');
      }
    } catch (e) {
      print('❌ Error in getCourseCategories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final uri = Uri.parse("https://eduhub44.atwebpages.com/categories.php?action=get_all");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data is Map && data['data'] != null) {

          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Unexpected categories response format');
        }
      } else {
        throw Exception('Failed to load categories: ${res.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}