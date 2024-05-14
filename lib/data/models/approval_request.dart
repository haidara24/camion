import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/user_model.dart';

class ApprovalRequest {
  int? id;
  int? driver;
  SimpleSubshipment? subshipment;
  String? responseTurn;
  bool? isApproved;
  String? reason;
  double? extraFees;

  ApprovalRequest(
      {this.id,
      this.driver,
      this.subshipment,
      this.responseTurn,
      this.isApproved,
      this.reason,
      this.extraFees});

  ApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver = json['driver'];
    print("k");
    subshipment = json['subshipment'] != null
        ? SimpleSubshipment.fromJson(json['subshipment'])
        : null;
    responseTurn = json['response_turn'];
    isApproved = json['is_approved'];
    reason = json['reason'];
    extraFees = json['extra_fees'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['driver'] = driver;
    if (subshipment != null) {
      data['subshipment'] = subshipment!.toJson();
    }
    data['response_turn'] = responseTurn;
    data['is_approved'] = isApproved;
    data['reason'] = reason;
    data['extra_fees'] = extraFees;
    return data;
  }
}

class SimpleSubshipment {
  int? id;
  SimpleShipment? shipment;
  List<PathPoint>? pathpoints;
  DateTime? pickupDate;

  SimpleSubshipment({
    this.id,
    this.shipment,
    this.pathpoints,
    this.pickupDate,
  });

  SimpleSubshipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'] != null
        ? SimpleShipment.fromJson(json['shipment'])
        : null;

    if (json['path_points'] != null) {
      pathpoints = <PathPoint>[];
      json['path_points'].forEach((v) {
        pathpoints!.add(PathPoint.fromJson(v));
      });
    }

    pickupDate = DateTime.parse(json['pickup_date']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (shipment != null) {
      data['shipment'] = shipment!.toJson();
    }
    data['pickup_date'] = pickupDate?.toIso8601String();
    if (pathpoints != null) {
      data['path_points'] = pathpoints!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class SimpleShipment {
  int? id;
  RMerchant? merchant;

  SimpleShipment({this.id, this.merchant});

  SimpleShipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    merchant =
        json['merchant'] != null ? RMerchant.fromJson(json['merchant']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (merchant != null) {
      data['merchant'] = merchant!.toJson();
    }
    return data;
  }
}

class RMerchant {
  int? id;
  User? user;

  RMerchant({this.id, this.user});

  RMerchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
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
