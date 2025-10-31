import 'dart:io';

import 'package:eduhub/constant/helpers/prefs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingController extends ChangeNotifier {
  String? _thumb;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> pickAndUploadImage() async {
   // final prefs = await SharedPreferences.getInstance();
    final username = PrefsHelper.getString('name') ?? 'user';
    final folderPath = '$username/image_course';

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

      _thumb = publicURL;
      notifyListeners();

      await PrefsHelper.setString("image", _thumb!);
    } catch (e) {
      print(e);
     }
  }

  bool _isDarkMode = false;

  String _userName = 'User';

  void loadUserName() async {
    //final prefs = await SharedPreferences.getInstance();
    _userName = PrefsHelper.getString('name') ?? 'User';
    notifyListeners();
  }


  loadImage() async {
   // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    emailController.text = PrefsHelper.getString('email') ?? '';
    nameController.text = PrefsHelper.getString('name') ?? '';
    _thumb = PrefsHelper.getString("image") ?? 'assets/default person picture.webp';
    notifyListeners();
    //});
  }

  loadImageS() async {
   // final prefs = await SharedPreferences.getInstance();
    _thumb = PrefsHelper.getString('image') ?? 'assets/default person picture.webp';
    notifyListeners();
  }

  bool _showErrorName = false;
  bool _showErrorEmail = false;

  bool get isDarkMood => _isDarkMode;

  bool get showErrorName => _showErrorEmail;

  set showErrorName(bool v) => _showErrorName = v;
  set isDarkMood(bool v) => _isDarkMode = v;

  set showErrorEmail(bool v) => _showErrorEmail = v;

  bool get showErrorEmail => _showErrorName;


  String get userName => _userName;

  String? get thumb => _thumb;
}
