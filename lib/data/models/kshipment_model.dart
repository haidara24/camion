import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';

class KShipment {
  int? id;
  int? merchant;
  Simpletruck? truck;
  String? shipmentType;
  String? shipmentStatus;
  int? totalWeight;
  Null? commodityImage;
  TruckType? truckType;
  DateTime? pickupDate;
  List<PathPoint>? pathPoints;
  List<ShipmentItems>? shipmentItems;

  KShipment(
      {this.id,
      this.merchant,
      this.truck,
      this.shipmentType,
      this.shipmentStatus,
      this.totalWeight,
      this.commodityImage,
      this.truckType,
      this.pickupDate,
      this.pathPoints,
      this.shipmentItems});

  KShipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchant = json['merchant'];
    truck = json['truck'] != null ? Simpletruck.fromJson(json['truck']) : null;
    shipmentType = json['shipment_type'];
    shipmentStatus = json['shipment_status'];
    totalWeight = json['total_weight'];
    commodityImage = json['commodity_image'];
    truckType = json['truck_type'] != null
        ? TruckType.fromJson(json['truck_type'])
        : null;
    pickupDate = json['pickup_date'] != null
        ? DateTime.parse(json['pickup_date'])
        : null;
    if (json['path_points'] != null) {
      pathPoints = <PathPoint>[];
      json['path_points'].forEach((v) {
        pathPoints!.add(PathPoint.fromJson(v));
      });
    }
    if (json['shipment_items'] != null) {
      shipmentItems = <ShipmentItems>[];
      json['shipment_items'].forEach((v) {
        shipmentItems!.add(ShipmentItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['merchant'] = merchant;
    if (truck != null) {
      data['truck'] = truck!.toJson();
    }
    data['shipment_type'] = shipmentType;
    data['shipment_status'] = shipmentStatus;
    data['total_weight'] = totalWeight;
    data['commodity_image'] = commodityImage;
    if (truckType != null) {
      data['truck_type'] = truckType!.toJson();
    }
    data['pickup_date'] = pickupDate;
    if (pathPoints != null) {
      data['path_points'] = pathPoints!.map((v) => v.toJson()).toList();
    }
    if (shipmentItems != null) {
      data['shipment_items'] = shipmentItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ManagmentShipment {
  int? id;
  KMerchant? merchant;
  Simpletruck? truck;
  String? shipmentType;
  String? shipmentStatus;
  int? totalWeight;
  Null? commodityImage;
  KTuckType? truckType;
  DateTime? pickupDate;
  List<PathPoint>? pathPoints;
  List<MShipmentItems>? shipmentItems;
  int? passpermession;
  int? passcharges;

  ManagmentShipment({
    this.id,
    this.merchant,
    this.truck,
    this.shipmentType,
    this.shipmentStatus,
    this.totalWeight,
    this.commodityImage,
    this.truckType,
    this.pickupDate,
    this.pathPoints,
    this.shipmentItems,
    this.passpermession,
    this.passcharges,
  });

  ManagmentShipment.fromJson(Map<String, dynamic> json) {
    print("asd");
    id = json['id'];
    merchant =
        json['merchant'] != null ? KMerchant.fromJson(json['merchant']) : null;
    truck = json['truck'] != null ? Simpletruck.fromJson(json['truck']) : null;
    shipmentType = json['shipment_type'];
    shipmentStatus = json['shipment_status'];
    totalWeight = json['total_weight'];
    commodityImage = json['commodity_image'];
    passpermession = json['passpermession'];
    passcharges = json['passcharges'];
    print(passpermession);
    truckType = json['truck_type'] != null
        ? KTuckType.fromJson(json['truck_type'])
        : null;
    pickupDate = json['pickup_date'] != null
        ? DateTime.parse(json['pickup_date'])
        : null;
    if (json['path_points'] != null) {
      pathPoints = <PathPoint>[];
      json['path_points'].forEach((v) {
        pathPoints!.add(PathPoint.fromJson(v));
      });
    }
    print("asd");
    if (json['shipment_items'] != null) {
      shipmentItems = <MShipmentItems>[];
      json['shipment_items'].forEach((v) {
        shipmentItems!.add(MShipmentItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (merchant != null) {
      data['merchant'] = merchant!.toJson();
    }
    if (truck != null) {
      data['truck'] = truck!.toJson();
    }
    data['shipment_type'] = shipmentType;
    data['shipment_status'] = shipmentStatus;
    data['total_weight'] = totalWeight;
    data['commodity_image'] = commodityImage;
    data['passcharges'] = passcharges;
    data['passpermession'] = passpermession;
    if (truckType != null) {
      data['truck_type'] = truckType!.toJson();
    }
    data['pickup_date'] = pickupDate;
    if (pathPoints != null) {
      data['path_points'] = pathPoints!.map((v) => v.toJson()).toList();
    }
    if (shipmentItems != null) {
      data['shipment_items'] = shipmentItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PathPoint {
  int? id;
  String? name;
  String? pointType;
  int? number;
  String? location;
  int? shipment;
  int? city;

  PathPoint(
      {this.id,
      this.name,
      this.pointType,
      this.number,
      this.location,
      this.shipment,
      this.city});

  PathPoint.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pointType = json['point_type'];
    number = json['number'];
    location = json['location'];
    shipment = json['shipment'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['point_type'] = pointType;
    data['number'] = number;
    data['location'] = location;
    data['shipment'] = shipment;
    data['city'] = city;
    return data;
  }
}

class ShipmentItems {
  int? id;
  int? commodityCategory;
  int? commodityWeight;

  ShipmentItems({this.id, this.commodityCategory, this.commodityWeight});

  ShipmentItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityCategory = json['commodity_category'];
    commodityWeight = json['commodity_weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['commodity_category'] = commodityCategory;
    data['commodity_weight'] = commodityWeight;
    return data;
  }
}

class MShipmentItems {
  int? id;
  MCategory? commodityCategory;
  int? commodityWeight;

  MShipmentItems({this.id, this.commodityCategory, this.commodityWeight});

  MShipmentItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityCategory = json['commodity_category'] != null
        ? MCategory.fromJson(json['commodity_category'])
        : null;
    commodityWeight = json['commodity_weight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['commodity_category'] = commodityCategory;
    data['commodity_weight'] = commodityWeight;
    return data;
  }
}

class MCategory {
  int? id;
  String? name;
  String? name_ar;

  MCategory({this.id, this.name, this.name_ar});

  MCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name_ar = json['name_ar'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['name_ar'] = name_ar;
    return data;
  }
}

class Simpletruck {
  int? id;
  KTuckUser? truckuser;
  int? truck_number;
  Simpletruck({this.id, this.truckuser, this.truck_number});

  Simpletruck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    truck_number = json['truck_number'];
    truckuser = json['truckuser'] != null
        ? KTuckUser.fromJson(json['truckuser'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['truck_number'] = truck_number;
    if (truckuser != null) {
      data['truckuser'] = truckuser!.toJson();
    }
    return data;
  }
}

class KMerchant {
  int? id;
  Usertruck? user;

  KMerchant({this.id, this.user});

  KMerchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? Usertruck.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
