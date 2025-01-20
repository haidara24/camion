class Governorate {
  int? id;
  String? name;
  String? nameEn;

  Governorate({
    this.id,
    this.name,
    this.nameEn,
  });

  Governorate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameEn = json['name_en'];
  }
}

class TruckPrice {
  int? id;
  String? point1;
  String? point1En;
  String? point2;
  String? point2En;
  int? value;

  TruckPrice({
    this.id,
    this.point1,
    this.point1En,
    this.point2,
    this.point2En,
    this.value,
  });

  TruckPrice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    point1 = json['point1name'];
    point1En = json['point1nameEn'];
    point2 = json['point2name'];
    point2En = json['point2nameEn'];
  }
}
