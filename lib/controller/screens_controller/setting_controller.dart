import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingController extends ChangeNotifier {
  String? _thumb;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> pickAndUploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('name') ?? 'user';
    final folderPath = '$username/image_course';
   // notifyListeners();
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '$folderPath/$fileName';
    notifyListeners();
    try {
      await Supabase.instance.client.storage.from('uploads').upload(path, file);
      final publicURL = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(path);
      //setState(() =>
      _thumb = publicURL;
      notifyListeners();
      //);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('The image has been uploaded successfully'),
      //   ),
      // );
      await prefs.setString("image", _thumb!);
    } catch (e) {
      print(e);
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Image upload failed:$e')));
    }
  }

  // String? _thumb ;
  bool _isDarkMode = false;
 // bool _isPushNotifications = false;
  String _userName = 'User';

  void loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    //setState(() {
    _userName = prefs.getString('name') ?? 'User';
    notifyListeners();
    //});
  }


  loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    // setState(() {
    emailController.text = prefs.getString('email') ?? '';
    nameController.text = prefs.getString('name') ?? '';
    _thumb = prefs.getString("image") ?? 'assets/default person picture.webp';
    notifyListeners();
    //});
  }

  loadImageS() async {
    final prefs = await SharedPreferences.getInstance();
    _thumb = prefs.getString('image') ?? 'assets/default person picture.webp';
    notifyListeners();
  }

  bool _showErrorName = false;
  bool _showErrorEmail = false;

 // get loadImage => _loadImage();

  //get loadImageS => _loadImageS();

  //get loadUserName => _loadUserName();

  //get pickAndUploadImage => _pickAndUploadImage;

  bool get isDarkMood => _isDarkMode;

  bool get showErrorName => _showErrorEmail;

  set showErrorName(bool v) => _showErrorName = v;
  set isDarkMood(bool v) => _isDarkMode = v;

  set showErrorEmail(bool v) => _showErrorEmail = v;

  bool get showErrorEmail => _showErrorName;

  //bool get isPushNotifications => _isPushNotifications;

  String get userName => _userName;

  String? get thumb => _thumb;
}
