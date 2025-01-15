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
  List<Docs>? docs;

  Shipmentinstruction({
    this.id,
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
    this.commodityItems,
    this.docs,
  });

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
    totalWeight = json['total_weight'] ?? 0;
    netWeight = json['net_weight'];
    truckWeight = json['truck_weight'];
    finalWeight = json['final_weight'];
    if (json['commodity_items'] != null) {
      commodityItems = <CommodityItems>[];
      json['commodity_items'].forEach((v) {
        commodityItems!.add(CommodityItems.fromJson(v));
      });
    } else {
      commodityItems = <CommodityItems>[];
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['shipment'] = shipment;
    data['user_type'] = userType;
    data['charger_name'] = chargerName;
    data['charger_address'] = chargerAddress;
    data['charger_phone'] = chargerPhone;
    data['reciever_name'] = recieverName;
    data['reciever_address'] = recieverAddress;
    data['reciever_phone'] = recieverPhone;
    data['total_weight'] = totalWeight;
    data['net_weight'] = netWeight;
    data['truck_weight'] = truckWeight;
    data['final_weight'] = finalWeight;
    if (commodityItems != null) {
      data['commodity_items'] = commodityItems!.map((v) => v.toJson()).toList();
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
  String? packageName;
  String? packageNameAr;

  CommodityItems({
    this.id,
    this.commodityName,
    this.commodityWeight,
    this.commodityQuantity,
    this.packageType,
    this.packageName,
    this.packageNameAr,
  });

  CommodityItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodityName = json['commodity_name'];
    commodityWeight = json['commodity_weight'];
    commodityQuantity = json['commodity_quantity'];
    packageType = json['package_type'];
    packageName = json['package_name'];
    packageNameAr = json['package_name_ar'];
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

class Docs {
  int? id;
  String? file;

  Docs({
    this.id,
    this.file,
  });

  Docs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['file'] = file;
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
  String? file;

  ShipmentPayment({
    this.id,
    this.shipment,
    this.amount,
    this.fees,
    this.extraFees,
    this.paymentMethod,
    this.created_date,
    this.file,
  });

  ShipmentPayment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    amount = json['amount'];
    fees = json['fees'];
    extraFees = json['extra_fees'];
    created_date =
        DateTime.parse(json['created_date']).add(const Duration(hours: 3));
    paymentMethod = json['payment_method'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['shipment'] = shipment;
    data['amount'] = amount;
    data['fees'] = fees;
    data['extra_fees'] = extraFees;
    data['created_date'] = created_date;
    data['payment_method'] = paymentMethod;
    data['file'] = file;
    return data;
  }
}
