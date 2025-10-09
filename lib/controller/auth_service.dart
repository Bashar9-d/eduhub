import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/users_model.dart';

class AuthService {
  final String baseUrl = "https://eduhub44.atwebpages.com/users.php";

  Future<Map<String, dynamic>> addUser(UsersModel user) async {
    final response = await http.post(
      Uri.parse("$baseUrl?action=create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "create",
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "password": user.password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Failed to add user"};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl?action=login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Login failed"};
    }
  }
}
