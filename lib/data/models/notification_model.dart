class NotificationModel {
  int? id;
  String? title;
  String? description;
  String? image;
  String? dateCreated;
  String? noteficationType;
  bool? isread;
  int? request;
  int? user;
  int? sender;
  int? shipment;

  NotificationModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.dateCreated,
    this.noteficationType,
    this.request,
    this.isread,
    this.user,
    this.sender,
    this.shipment,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'] ?? "";
    dateCreated = json['date_created'];
    noteficationType = json['notefication_type'];
    isread = json['isread'];
    user = json['receiver'];
    sender = json['sender'];
    shipment = json['shipment'];
    request = json['request'];
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
    data['request'] = request;
    return data;
  }
}
