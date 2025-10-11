class CoursesModel {
  int? id;
  String? title;
  String? description;
  String? thumbnail;
  int? teacherId;
  String? createdAt;
  String? teacherName;

  CoursesModel(
      {this.id,
        this.title,
        this.description,
        this.thumbnail,
        this.teacherId,
        this.createdAt,
        this.teacherName});

  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id'].toString());
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    teacherId = int.parse(json['teacher_id'].toString());
    createdAt = json['created_at'];
    teacherName = json['teacher_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['thumbnail'] = this.thumbnail;
    data['teacher_id'] = this.teacherId;
    data['created_at'] = this.createdAt;
    data['teacher_name'] = this.teacherName;
    return data;
  }
}