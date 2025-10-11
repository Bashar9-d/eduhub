class LessonsModel {
  int? id;
  int? sectionId;
  String? title;
  String? videoUrl;
  String? duration;
  String? createdAt;

  LessonsModel(
      {this.id,
        this.sectionId,
        this.title,
        this.videoUrl,
        this.duration,
        this.createdAt});

  LessonsModel.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    sectionId =int.parse( json['section_id']);
    title = json['title'];
    videoUrl = json['video_url'];
    duration = json['duration'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['section_id'] = this.sectionId;
    data['title'] = this.title;
    data['video_url'] = this.videoUrl;
    data['duration'] = this.duration;
    data['created_at'] = this.createdAt;
    return data;
  }
}


