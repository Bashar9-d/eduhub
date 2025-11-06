import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/group_model.dart';
import '../../model/message_model.dart';

const String baseUrl = 'https://eduhub44.atwebpages.com/groups.php';

class GroupService {
  static Future<bool> addUserToGroup(int groupId, int userId) async {
    final uri = Uri.parse('$baseUrl?action=join_group');
    final body = json.encode({'group_id': groupId, 'user_id': userId});

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<GroupModel?> getGroupByCourse(int courseId) async {
    final uri = Uri.parse(
      '$baseUrl?action=get_group_by_course&course_id=$courseId',
    );
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return GroupModel.fromJson(data['data']);
      }
    }
    return null;
  }

   Future<List<GroupModel>> getGroupsByTeacher(int teacherId) async {
    final uri = Uri.parse('$baseUrl?action=my_groups&teacher_id=$teacherId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        List groups = data['data'] ?? [];
        return groups.map((e) => GroupModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<List<MessageModel>> getMessages(int groupId) async {
    final uri = Uri.parse(
      'https://eduhub44.atwebpages.com/messages.php?action=get&group_id=$groupId',
    );
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        List messages = data['data'] ?? [];
        print('Messages: $messages');
        return messages
            .map(
              (e) => MessageModel.fromJson({
                'message_id': int.tryParse(e['message_id'].toString()) ?? 0,
                'group_id': int.tryParse(e['group_id'].toString()) ?? 0,
                'sender_id': int.tryParse(e['sender_id'].toString()) ?? 0,
                'message': e['message'] ?? '',
                'sent_at': e['sent_at'] ?? '',
                'sender_name': e['sender_name'] ?? '',
              }),
            )
            .toList();
      }
    }
    return [];
  }

  static Future<bool> sendMessage(
    int groupId,
    int senderId,
    String message,
  ) async {
    final uri = Uri.parse(
      'https://eduhub44.atwebpages.com/messages.php?action=send',
    );
    final body = json.encode({
      'group_id': groupId,
      'sender_id': senderId,
      'message': message,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<bool> createGroup(
    int courseId,
    int teacherId,
    String groupName,
  ) async {
    try {
      final groupUri = Uri.parse('$baseUrl?action=create_group');
      final groupBody = json.encode({
        'course_id': courseId,
        'teacher_id': teacherId,
        'group_name': groupName,
      });

      final groupRes = await http.post(
        groupUri,
        headers: {'Content-Type': 'application/json'},
        body: groupBody,
      );

      print('Group response: ${groupRes.body}');

      if (groupRes.statusCode != 200 || groupRes.body.isEmpty) {
        throw Exception('Failed to create group or empty response');
      }

      final groupData = json.decode(groupRes.body);

      if ((groupData is Map && groupData['success'] == true) ||
          groupRes.body.contains('created')) {
        return true;
      } else {
        throw Exception('Group creation failed: ${groupRes.body}');
      }
    } catch (e) {
      print('Error in createGroup: $e');
      return false;
    }
  }
  static Future<bool> updateGroupName(int courseId, String newName) async {
    try {
      final uri = Uri.parse('$baseUrl?action=update_name');
      final body = json.encode({
        'course_id': courseId,
        'new_name': newName,
      });

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          print('✅ Group name updated successfully.');
          return true;
        } else {
          print('⚠️ Failed to update group name: ${res.body}');
        }
      } else {
        print('❌ HTTP error while updating group name: ${res.statusCode}');
      }
      return false;
    } catch (e) {
      print('⚠️ Error in updateGroupName: $e');
      return false;
    }
  }

}
