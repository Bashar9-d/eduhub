class SectionsModel {
  int? id;
  int? courseId;
  String? title;

  SectionsModel({this.id, this.courseId, this.title});

  SectionsModel.fromJson(Map<String, dynamic> json) {
    id =int.parse(json['id'].toString()) ;
    courseId = int.parse(json['course_id'].toString());
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['course_id'] = this.courseId;
    data['title'] = this.title;
    return data;
  }
}