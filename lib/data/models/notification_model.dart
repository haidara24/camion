class NotificationModel {
  int? id;
  String? title;
  String? titleEn;
  String? description;
  String? descriptionEn;
  String? image;
  String? dateCreated;
  String? noteficationType;
  bool? isread;
  int? objectId;
  String? user;
  String? sender;

  NotificationModel({
    this.id,
    this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    this.image,
    this.dateCreated,
    this.noteficationType,
    this.objectId,
    this.isread,
    this.user,
    this.sender,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    titleEn = json['title_en'];
    description = json['description'];
    descriptionEn = json['description_en'];
    image = json['image'] ?? "";
    dateCreated = json['date_created'];
    noteficationType = json['notefication_type'];
    isread = json['isread'];
    user = json['user'];
    sender = json['sender'];
    objectId = json['object_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['date_created'] = dateCreated;
    data['notefication_type'] = noteficationType;
    data['isread'] = isread;
    data['receiver'] = user;
    data['sender'] = sender;
    return data;
  }
}
