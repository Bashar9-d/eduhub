import 'package:eduhub/constant/helpers/prefs.dart';
import 'package:eduhub/constant/otherwise/textstyle_manage.dart';
import 'package:eduhub/constant/widgets/text_field_manage.dart';
import 'package:eduhub/controller/screens_controller/student_controller.dart';
import 'package:eduhub/controller/screens_controller/teacher_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/widgets/circle_avatar.dart';
import '../../constant/widgets/style_widget_manage.dart';
import '../../controller/screens_controller/setting_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  late SettingController settingProvider;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    settingProvider = Provider.of<SettingController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SettingController>(context, listen: false);
      // provider.loadUserName();
      // provider.loadImage();
      loadImage();
    });
  }

  loadImage() async {
    //final prefs = await SharedPreferences.getInstance();
    emailController.text = PrefsHelper.getString('email') ?? '';
    nameController.text = PrefsHelper.getString('name') ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), centerTitle: true,backgroundColor: Theme.of(context).colorScheme.background,),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<SettingController>(
        builder: (context, settingController, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: GestureDetector(
                   // onTap: settingController.pickAndUploadImage,
                    child: Stack(
                      children: [
                        circleAvatar(context,radius: 70,childSize:65)

                        // CircleAvatar(
                        //   radius: 70,
                        //   backgroundImage: settingController.thumb == null
                        //       ? AssetImage('assets/default person picture.webp')
                        //       : NetworkImage(settingController.thumb!),
                        // ),
                        // Positioned(
                        //   bottom: 10,
                        //   right: 10,
                        //   child: CircleAvatar(
                        //     radius: 12,
                        //     backgroundColor: Colors.black,
                        //     child: Icon(
                        //       Icons.camera_alt,
                        //       size: 16,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                buildTextField(
                  controller: nameController,
                  label: 'Name',
                  hint: 'Enter Your Name',
                  errorText: settingController.showErrorName
                      ? 'This field cannot be empty'
                      : null,
                  fillColor: Theme.of(context).colorScheme.secondary
                ),
                buildTextField(
                  controller: emailController,
                  label: 'Email Address',
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  errorText: settingController.showErrorEmail
                      ? 'This field cannot be empty'
                      : null,
                  fillColor: Theme.of(context).colorScheme.secondary
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    settingController.showErrorEmail =
                        emailController.text.isEmpty;
                    settingController.showErrorName =
                        nameController.text.isEmpty;

                    if (!settingController.showErrorEmail &&
                        !settingController.showErrorName) {
                      await PrefsHelper.setString('email', emailController.text);
                      await PrefsHelper.setString('name', nameController.text);
                      await PrefsHelper.setString('image', settingController.thumb!);
                      Provider.of<SettingController>(
                        context,
                        listen: false,
                      ).loadUserName();
                      Provider.of<StController>(
                        context,
                        listen: false,
                      ).loadUserName();
                      Provider.of<StController>(
                        context,
                        listen: false,
                      ).loadImage();
                      Provider.of<TeacherController>(
                        context,
                        listen: false,
                      ).loadUserName();
                      Provider.of<TeacherController>(
                        context,
                        listen: false,
                      ).loadImage();
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: StyleWidgetManage.nextButtonDecoration,
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
          );
        },
      ),
    );
  }
}
