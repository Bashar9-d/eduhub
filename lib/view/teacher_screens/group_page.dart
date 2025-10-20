import 'package:eduhub/constant/color_manage.dart';
import 'package:eduhub/view/teacher_screens/setting.dart';
import 'package:flutter/material.dart';

import '../../constant/textstyle_manage.dart';
import '../../controller/group_service.dart';
import '../../model/group_model.dart';
import 'chat_page.dart';

class GroupPage extends StatefulWidget {
  final int teacherId;

  const GroupPage({super.key, required this.teacherId});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late Future<List<GroupModel>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = GroupService.getGroupsByTeacher(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Groups",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        backgroundColor: ColorManage.firstPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<GroupModel>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final groups = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return GestureDetector(
                  onLongPressStart: (details) async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      items: const [
                        PopupMenuItem(
                          value: 'Mark',
                          child: Text('Mark ar read'),
                        ),
                        PopupMenuItem(value: 'Remove', child: Text('Remove')),
                      ],
                    );

                    if (selected == null) {
                      return;
                    }
                    //Future.microtask(() async {
                    switch (selected) {
                      case 'Mark':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingScreen(),
                          ),
                        );
                        break;
                      case 'Remove':
                        //Remove Chat from user  Method**
                        break;
                    }
                    // });
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                    child: Icon(Icons.group),
                    ),
                    title: Text(group.name, style: TextStyle(fontWeight: FontWeight.w500)),

                    
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            groupId: group.id,
                            userId: widget.teacherId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No groups found."));
          }
        },
      ),
    );
  }
}
