import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text("My Groups")),
      body: FutureBuilder<List<GroupModel>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.name),
                  subtitle: Text("Course ID: ${group.courseId}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(groupId: group.id, userId: widget.teacherId),
                      ),
                    );
                  },
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
