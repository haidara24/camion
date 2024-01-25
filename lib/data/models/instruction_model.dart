import 'package:camion/data/models/truck_type_model.dart';

class Shipmentinstruction {
  int? id;
  int? shipment;
  String? userType;
  String? chargerName;
  String? chargerAddress;
  String? chargerPhone;
  String? recieverName;
  String? recieverAddress;
  String? recieverPhone;
  int? totalWeight;
  int? netWeight;
  int? truckWeight;
  int? finalWeight;
  List<CommodityItems>? commodityItems;

  Shipmentinstruction(
      {this.id,
      this.shipment,
      this.userType,
      this.chargerName,
      this.chargerAddress,
      this.chargerPhone,
      this.recieverName,
      this.recieverAddress,
      this.recieverPhone,
      this.totalWeight,
      this.netWeight,
      this.truckWeight,
      this.finalWeight,
      this.commodityItems});

  Shipmentinstruction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    userType = json['user_type'];
    chargerName = json['charger_name'];
    chargerAddress = json['charger_address'];
    chargerPhone = json['charger_phone'];
    recieverName = json['reciever_name'];
    recieverAddress = json['reciever_address'];
    recieverPhone = json['reciever_phone'];
    totalWeight = json['total_weight'];
    netWeight = json['net_weight'];
    truckWeight = json['truck_weight'];
    finalWeight = json['final_weight'];
    if (json['commodity_items'] != null) {
      commodityItems = <CommodityItems>[];
      json['commodity_items'].forEach((v) {
        commodityItems!.add(new CommodityItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['shipment'] = this.shipment;
    data['user_type'] = this.userType;
    data['charger_name'] = this.chargerName;
    data['charger_address'] = this.chargerAddress;
    data['charger_phone'] = this.chargerPhone;
    data['reciever_name'] = this.recieverName;
    data['reciever_address'] = this.recieverAddress;
    data['reciever_phone'] = this.recieverPhone;
    data['total_weight'] = this.totalWeight;
    data['net_weight'] = this.netWeight;
    data['truck_weight'] = this.truckWeight;
    data['final_weight'] = this.finalWeight;
    if (this.commodityItems != null) {
      data['commodity_items'] =
          this.commodityItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CommodityItems {
  int? id;
  String? commodityName;
  int? commodityWeight;
  int? commodityQuantity;
  int? packageType;

  CommodityItems({
    this.id,
    this.commodityName,
    this.commodityWeight,
    this.commodityQuantity,
    this.packageType,
  });

  CommodityItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityName = json['commodity_name'];
    commodityWeight = json['commodity_weight'];
    commodityQuantity = json['commodity_quantity'];
    packageType = json['package_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['commodity_name'] = commodityName;
    data['commodity_weight'] = commodityWeight;
    data['commodity_quantity'] = commodityQuantity;
    data['package_type'] = packageType;
    return data;
  }
}

class ShipmentPayment {
  int? id;
  int? shipment;
  int? amount;
  int? fees;
  int? extraFees;
  String? paymentMethod;
  DateTime? created_date;

  ShipmentPayment({
    this.id,
    this.shipment,
    this.amount,
    this.fees,
    this.extraFees,
    this.paymentMethod,
    this.created_date,
  });

  ShipmentPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    amount = json['amount'];
    fees = json['fees'];
    extraFees = json['extra_fees'];
    created_date = DateTime.parse(json['created_date']);
    paymentMethod = json['payment_method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['shipment'] = shipment;
    data['amount'] = amount;
    data['fees'] = fees;
    data['extra_fees'] = extraFees;
    data['created_date'] = created_date;
    data['payment_method'] = paymentMethod;
    return data;
  }
}
