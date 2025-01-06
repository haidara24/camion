// ignore_for_file: non_constant_identifier_names

class Post {
  int? id;
  String? image;
  String? title;
  String? titleAr;
  DateTime? date;
  int? readCount;
  String? source;
  String? sourceAr;
  String? content;
  String? contentAr;
  bool? is_saved;

  Post(
      {this.id,
      this.image,
      this.title,
      this.titleAr,
      this.date,
      this.readCount,
      this.source,
      this.sourceAr,
      this.content,
      this.contentAr,
      this.is_saved});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    title = json['title'];
    titleAr = json['title_ar'];
    date = DateTime.parse(json['date']);
    readCount = json['read_count'];
    source = json['source'];
    sourceAr = json['source_ar'];
    content = json['content'];
    contentAr = json['content_ar'];
    is_saved = json['is_saved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['title'] = title;
    data['title_ar'] = titleAr;
    data['date'] = date;
    data['read_count'] = readCount;
    data['source'] = source;
    data['content'] = content;
    data['content_ar'] = contentAr;
    data['is_saved'] = is_saved;
    return data;
  }
}

class SavedPost {
  int? id;
  int? user;
  int? post;
  List<int>? groups;

  SavedPost({
    this.id,
    this.user,
    this.post,
    this.groups,
  });

  SavedPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    post = json['post'];
    if (json['groups'] != null) {
      groups = <int>[];
      json['groups'].forEach((v) {
        groups!.add(v);
      });
    } else {
      json['groups'] = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user'] = user;
    data['post'] = post;
    if (groups != null) {
      data['groups'] = groups!.map((v) => v).toList();
    }
    return data;
  }
}

class Group {
  int? id;
  int? user;
  String? name;

  Group({
    this.id,
    this.user,
    this.name,
  });

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user'] = user;
    data['name'] = name;
    return data;
  }
}
