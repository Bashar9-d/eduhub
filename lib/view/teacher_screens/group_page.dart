import 'package:eduhub/constant/otherwise/color_manage.dart';
import 'package:eduhub/constant/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/widgets/circular_progress.dart';
import '../../controller/otherwise/group_service.dart';
import '../../controller/screens_controller/teacher_controller.dart';
import '../../model/group_model.dart';
import '../chat_page.dart';

class GroupPage extends StatefulWidget {
  final int teacherId;

  const GroupPage({super.key, required this.teacherId});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late TeacherController teachProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    teachProvider = Provider.of<TeacherController>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      teachProvider.groupsFuture = GroupService().getGroupsByTeacher(
        widget.teacherId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManage.secondPrimary,
        title: const Text(
          "Groups",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<TeacherController>(
        builder: (context, teacherController, child) {
          return FutureBuilder<List<GroupModel>>(
            future: teacherController.groupsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgress.circular);
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final groups = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return GestureDetector(
                      child: ListTile(
                        leading: circleAvatar(
                          context,
                          childSize: 24,
                          radius: 20,
                          icon: Icons.group_outlined,
                        ),
                        title: Text(
                          group.name,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
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
          );
        },
      ),
    );
  }
}
