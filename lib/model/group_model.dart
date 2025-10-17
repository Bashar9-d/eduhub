class GroupModel {
  final int id;
  final String name;
  final int courseId;

  GroupModel({required this.id, required this.name, required this.courseId});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['group_id'] ?? json['id'],
      name: json['group_name'] ?? 'Group',
      courseId: json['course_id'] ?? 0,
    );
  }
}
