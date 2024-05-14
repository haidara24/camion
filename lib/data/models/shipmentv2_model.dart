// ignore_for_file: non_constant_identifier_names

import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/models/truck_type_model.dart';

class Shipmentv2 {
  int? id;
  int? merchant;
  String? createdDate;
  String? name;
  String? shipmentStatus;
  String? shipmentType;
  List<SubShipment>? subshipments;

  Shipmentv2({
    this.id,
    this.merchant,
    this.createdDate,
    this.shipmentStatus,
    this.shipmentType,
    this.name,
    this.subshipments,
  });

  Shipmentv2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchant = json['merchant'];
    createdDate = json['created_date'];
    shipmentStatus = json['shipment_status'];
    shipmentType = json['shipment_type'];
    name = json['name'];
    if (json['subshipments'] != null) {
      subshipments = <SubShipment>[];
      json['subshipments'].forEach((v) {
        subshipments!.add(SubShipment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['merchant'] = merchant;
    data['created_date'] = createdDate;
    data['shipment_status'] = shipmentStatus;
    data['shipment_type'] = shipmentType;
    data['name'] = name;
    if (subshipments != null) {
      data['subshipments'] = subshipments!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class SubShipment {
  int? id;
  String? shipmentStatus;
  String? paths;
  int? shipmentinstructionv2;
  int? shipmentpaymentv2;
  int? totalWeight;
  DateTime? pickupDate;
  DateTime? deliveryDate;
  List<ShipmentItems>? shipmentItems;
  List<PathPoint>? pathpoints;
  ShipmentTruck? truck;
  double? distance;
  String? period;

  SubShipment({
    this.id,
    this.shipmentStatus,
    this.paths,
    this.shipmentinstructionv2,
    this.shipmentpaymentv2,
    this.totalWeight,
    this.pickupDate,
    this.deliveryDate,
    this.shipmentItems,
    this.pathpoints,
    this.truck,
    this.distance,
    this.period,
  });

  SubShipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipmentStatus = json['shipment_status'];
    paths = json['path'];
    distance = json['distance'];
    period = json['period'];
    truck =
        json['truck'] != null ? ShipmentTruck.fromJson(json['truck']) : null;
    shipmentinstructionv2 = json['shipmentinstructionv2'];
    shipmentpaymentv2 = json['shipmentpaymentv2'];
    totalWeight = json['total_weight'];
    pickupDate = DateTime.parse(json['pickup_date']);
    deliveryDate = DateTime.parse(json['delivery_date']);
    if (json['shipment_items'] != null) {
      shipmentItems = <ShipmentItems>[];
      json['shipment_items'].forEach((v) {
        shipmentItems!.add(ShipmentItems.fromJson(v));
      });
    }

    if (json['path_points'] != null) {
      pathpoints = <PathPoint>[];
      json['path_points'].forEach((v) {
        pathpoints!.add(PathPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['shipment_status'] = shipmentStatus;
    data['path'] = paths;
    data['truck'] = truck!.id!;
    data['distance'] = distance ?? 0.0;
    data['period'] = period ?? "";
    data['total_weight'] = totalWeight;
    data['pickup_date'] = pickupDate?.toIso8601String();
    data['delivery_date'] = deliveryDate?.toIso8601String();
    print("2");
    // data['shipmentinstructionv2'] = shipmentinstructionv2!;
    // data['shipmentpaymentv2'] = shipmentpaymentv2!;
    if (shipmentItems != null) {
      data['shipment_items'] = shipmentItems!.map((v) => v.toJson()).toList();
    }

    if (pathpoints != null) {
      data['path_points'] = pathpoints!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ShipmentTruck {
  int? id;
  int? owner;
  Truckuser? truckuser;
  TruckType? truck_type;
  int? location;
  String? location_lat;
  int? empty_weight;
  int? gross_weight;
  int? fees;
  int? extra_fees;

  ShipmentTruck({
    this.id,
    this.owner,
    this.truckuser,
    this.truck_type,
    this.location,
    this.location_lat,
    this.empty_weight,
    this.gross_weight,
    this.fees,
    this.extra_fees,
  });

  ShipmentTruck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'];
    truckuser = json['truckuser'] != null
        ? Truckuser.fromJson(json['truckuser'])
        : null;
    truck_type = json['truck_type'] != null
        ? TruckType.fromJson(json['truck_type'])
        : null;
    location = json['location'];
    location_lat = json['location_lat'];
    empty_weight = json['empty_weight'];
    gross_weight = json['gross_weight'];
    fees = json['fees'];
    extra_fees = json['extra_fees'];
  }
}

class ShipmentItems {
  int? id;
  String? commodityName;
  int? commodityWeight;
  // int? commodityQuantity;
  // int? packageType;

  ShipmentItems({
    this.id,
    this.commodityName,
    this.commodityWeight,
    // this.packageType,
  });

  ShipmentItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityName = json['commodity_name'];
    commodityWeight = json['commodity_weight'];
    // packageType = json['package_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commodity_name'] = commodityName;
    data['commodity_weight'] = commodityWeight;
    // data['package_type'] = packageType;

    return data;
  }
}

class SelectedTruckType {
  int? id;
  int? truckType;
  bool? is_assigned;

  SelectedTruckType({
    this.id,
    this.truckType,
    this.is_assigned,
  });

  SelectedTruckType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    truckType = json['truck_type'];
    is_assigned = json['is_assigned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['truck_type'] = truckType;
    data['is_assigned'] = is_assigned;

    return data;
  }
}

class PathPoint {
  int? id;
  String? name;
  String? nameEn;
  int? city;
  int? number;
  String? pointType;
  String? location;

  PathPoint({
    this.id,
    this.name,
    this.nameEn,
    this.city,
    this.number,
    this.pointType,
    this.location,
  });

  PathPoint.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameEn = json['nameEn'];
    city = json['city'];
    number = json['number'];
    pointType = json['point_type'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['nameEn'] = nameEn;
    data['city'] = city;
    data['number'] = number;
    data['point_type'] = pointType;
    data['location'] = location;
    print("3");

    return data;
  }
}

class PackageType {
  int? id;
  String? name;

  PackageType({
    this.id,
    this.name,
  });

  PackageType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
