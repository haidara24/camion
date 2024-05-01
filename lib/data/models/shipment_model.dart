import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/models/user_model.dart';

class Shipment {
  int? id;
  int? merchant;
  String? shipmentStatus;
  Shipmentinstruction? shipmentinstruction;
  ShipmentPayment? shipmentpayment;
  Driver? driver;
  int? totalWeight;
  // int? totalWeightWithTruck;
  // String? commodityImage;
  TruckType? truckType;
  String? pickupCityLocation;
  double? pickupCityLat;
  double? pickupCityLang;
  String? deliveryCityLocation;
  double? deliveryCityLat;
  double? deliveryCityLang;
  DateTime? pickupDate;
  List<ShipmentItems>? shipmentItems;

  Shipment(
      {this.id,
      this.merchant,
      this.shipmentinstruction,
      this.shipmentpayment,
      this.driver,
      this.shipmentStatus,
      this.totalWeight,
      // this.totalWeightWithTruck,
      // this.commodityImage,
      this.truckType,
      this.pickupCityLocation,
      this.pickupCityLat,
      this.pickupCityLang,
      this.deliveryCityLocation,
      this.deliveryCityLat,
      this.deliveryCityLang,
      this.pickupDate,
      this.shipmentItems});

  Shipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchant = json['merchant'];
    print('shipmentinstruction');
    print(json['shipmentinstruction']);
    shipmentinstruction = json['shipmentinstruction'] != null
        ? Shipmentinstruction.fromJson(json['shipmentinstruction'])
        : null;
    shipmentpayment = json['shipmentpayment'] != null
        ? ShipmentPayment.fromJson(json['shipmentpayment'])
        : null;
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    shipmentStatus = json['shipment_status'];
    totalWeight = json['total_weight'];
    // totalWeightWithTruck = json['total_weight_with_truck'];
    // commodityImage = json['commodity_image'];
    truckType = json['truck_type'] != null
        ? TruckType.fromJson(json['truck_type'])
        : null;
    pickupCityLocation = json['pickup_city_location'];
    pickupCityLat = json['pickup_city_lat'];
    pickupCityLang = json['pickup_city_lang'];
    deliveryCityLocation = json['delivery_city_location'];
    deliveryCityLat = json['delivery_city_lat'];
    deliveryCityLang = json['delivery_city_lang'];
    pickupDate = DateTime.parse(json['pickup_date']);
    if (json['shipment_items'] != null) {
      shipmentItems = <ShipmentItems>[];
      json['shipment_items'].forEach((v) {
        shipmentItems!.add(ShipmentItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['shipmentinstruction'] = this.shipmentinstruction;
    data['shipmentpayment'] = this.shipmentpayment;
    data['merchant'] = this.merchant;
    data['driver'] = driver!.id;
    data['shipment_status'] = this.shipmentStatus;
    data['total_weight'] = totalWeight;
    // data['total_weight_with_truck'] = this.totalWeightWithTruck;
    // data['commodity_image'] = this.commodityImage;
    data['truck_type'] = truckType!.id;
    data['pickup_city_location'] = pickupCityLocation;
    data['pickup_city_lat'] = pickupCityLat;
    data['pickup_city_lang'] = pickupCityLang;
    data['delivery_city_location'] = deliveryCityLocation;
    data['delivery_city_lat'] = deliveryCityLat;
    data['delivery_city_lang'] = deliveryCityLang;
    data['pickup_date'] = pickupDate;
    if (shipmentItems != null) {
      data['shipment_items'] = shipmentItems!.map((v) => v.toJson()).toList();
    }
    return data;
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
    // this.commodityQuantity,
    // this.packageType,
  });

  ShipmentItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityName = json['commodity_name'];
    commodityWeight = json['commodity_weight'];
    // commodityQuantity = json['commodity_quantity'];
    // packageType = json['package_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['commodity_name'] = commodityName;
    data['commodity_weight'] = commodityWeight;
    // data['commodity_quantity'] = this.commodityQuantity;
    // data['package_type'] = this.packageType;
    return data;
  }
}
