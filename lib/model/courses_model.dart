class CoursesModel {
  int? id;
  String? title;
  String? description;
  String? thumbnail;
  int? teacherId;
  String? teacherName;

  CoursesModel(
      {this.id,
        this.title,
        this.description,
        this.thumbnail,
        this.teacherId,
        this.teacherName});

  CoursesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    teacherId = json['teacher_id'];
    teacherName = json['teacher_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['thumbnail'] = this.thumbnail;
    data['teacher_id'] = this.teacherId;
    data['teacher_name'] = this.teacherName;
    return data;
  }
}