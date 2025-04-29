// ignore_for_file: non_constant_identifier_names

import 'package:camion/data/models/instruction_model.dart';

class Shipmentv2 {
  int? id;
  int? merchant;
  String? createdDate;
  String? name;
  String? shipmentStatus;
  String? shipmentType;
  List<SubShipment>? subshipments;
  List<Docs>? docs;

  Shipmentv2({
    this.id,
    this.merchant,
    this.createdDate,
    this.shipmentStatus,
    this.shipmentType,
    this.name,
    this.subshipments,
    this.docs,
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
    if (json['docs'] != null) {
      docs = <Docs>[];
      json['docs'].forEach((v) {
        docs!.add(Docs.fromJson(v));
      });
    } else {
      docs = <Docs>[];
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
  int? shipment;
  String? merchant_image;
  String? merchant_first_name;
  String? merchant_last_name;
  String? driver_image;
  String? driver_first_name;
  String? driver_last_name;
  int? shipmentinstructionv2;
  int? shipmentpaymentv2;
  int? totalWeight;
  DateTime? pickupDate;
  DateTime? deliveryDate;
  List<ShipmentItems>? shipmentItems;
  List<PathPoint>? pathpoints;
  ShipmentTruck? truck;
  double? distance;
  int? price;
  int? approvalrequest;
  String? period;

  SubShipment({
    this.id,
    this.shipmentStatus,
    this.paths,
    this.shipment,
    this.merchant_image,
    this.merchant_first_name,
    this.merchant_last_name,
    this.driver_image,
    this.driver_first_name,
    this.driver_last_name,
    this.shipmentinstructionv2,
    this.shipmentpaymentv2,
    this.totalWeight,
    this.pickupDate,
    this.deliveryDate,
    this.shipmentItems,
    this.pathpoints,
    this.truck,
    this.distance,
    this.price,
    this.approvalrequest,
    this.period,
  });

  SubShipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipmentStatus = json['shipment_status'];
    paths = json['path'];
    distance = json['distance'];
    period = json['period'];
    price = json['price'];
    truck =
        json['truck'] != null ? ShipmentTruck.fromJson(json['truck']) : null;
    shipment = json['shipment'];
    merchant_image = json['merchant_image'];
    merchant_first_name = json['merchant_first_name'];
    merchant_last_name = json['merchant_last_name'];
    driver_image = json['driver_image'];
    driver_first_name = json['driver_first_name'];
    driver_last_name = json['driver_last_name'];
    shipmentinstructionv2 = json['shipmentinstructionv2'];
    shipmentpaymentv2 = json['shipmentpaymentv2'];
    totalWeight = json['total_weight'];
    approvalrequest = json['approvalrequest'];
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
    data['truck'] = truck != null ? truck!.id! : null;
    data['distance'] = distance ?? 0.0;
    data['price'] = price ?? 0.0;
    data['period'] = period ?? "";
    data['approvalrequest'] = approvalrequest;
    data['total_weight'] = totalWeight;
    data['pickup_date'] = pickupDate?.toIso8601String();
    data['delivery_date'] = deliveryDate?.toIso8601String();
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
  String? truck_type;
  String? truck_typeAr;
  String? truck_type_image;
  String? location_lat;
  String? gpsId;

  ShipmentTruck({
    this.id,
    this.truck_type,
    this.truck_typeAr,
    this.truck_type_image,
    this.location_lat,
    this.gpsId,
  });

  ShipmentTruck.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    truck_type = json['truck_type'];
    truck_typeAr = json['truck_typeAr'];
    truck_type_image = json['truck_type_image'];
    location_lat = json['location_lat'];
    gpsId = json['gpsId'];
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

    return data;
  }
}

class PackageType {
  int? id;
  String? name;
  String? nameAr;

  PackageType({
    this.id,
    this.name,
    this.nameAr,
  });

  PackageType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
