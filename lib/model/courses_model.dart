class CoursesModel {
  int? id;
  String? title;
  String? description;
  String? thumbnail;
  int? teacherId;
  String? createdAt;
  String? teacherName;

  CoursesModel({
    this.id,
    this.title,
    this.description,
    this.thumbnail,
    this.teacherId,
    this.createdAt,
    this.teacherName,
  });

  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    title = json['title']?.toString() ?? '';
    description = json['description']?.toString() ?? '';
    thumbnail = json['thumbnail']?.toString() ?? '';
    teacherId = int.tryParse(json['teacher_id']?.toString() ?? '') ?? 0;
    createdAt = json['created_at']?.toString() ?? '';
    teacherName = json['teacher_name']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['teacher_id'] = teacherId;
    data['created_at'] = createdAt;
    data['teacher_name'] = teacherName;
    return data;
  }
}
