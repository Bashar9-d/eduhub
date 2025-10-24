import 'dart:io';

import 'package:eduhub/constant/otherwise/textstyle_manage.dart';
import 'package:eduhub/constant/widgets/text_field_manage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constant/otherwise/color_manage.dart';
import '../../constant/widgets/style_widget_manage.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _thumb;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> _pickAndUploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('name') ?? 'user';
    final folderPath = '$username/image_course';
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '$folderPath/$fileName';

    try {
      await Supabase.instance.client.storage.from('uploads').upload(path, file);
      final publicURL = Supabase.instance.client.storage
          .from('uploads')
          .getPublicUrl(path);
      setState(() => _thumb = publicURL);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The image has been uploaded successfully'),
        ),
      );
      await prefs.setString("image", _thumb!);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed:$e')));
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? 'll';
      nameController.text = prefs.getString('name') ?? '';
      _thumb = prefs.getString("image") ?? 'assets/default person picture.webp';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _thumb == null
                          ? AssetImage('assets/default person picture.webp')
                          : NetworkImage(_thumb!),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildTextField(
              controller: nameController,
              label: 'Name',
              hint: 'Enter Your Name',
              errorText: nameController.text.isEmpty
                  ? 'This field cannot be empty'
                  : null,
            ),
            buildTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'example@gmail.com',
              keyboardType: TextInputType.emailAddress,
              errorText: emailController.text.isEmpty
                  ? 'This field cannot be empty'
                  : null,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  await prefs.setString('email', emailController.text);
                  await prefs.setString('name', nameController.text);
                  await prefs.setString('image', _thumb!);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration:StyleWidgetManage.nextButtonDecoration,
                child: Center(
                  child: Text(
                    'Save Changes',
                    style: TextStyleManage.nextButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
