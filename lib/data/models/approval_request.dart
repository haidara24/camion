import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/models/user_model.dart';

class ApprovalRequest {
  int? id;
  int? driver;
  SimpleSubshipment? subshipment;
  String? responseTurn;
  bool? isApproved;
  String? reason;
  String? extratext;
  double? extraFees;

  ApprovalRequest(
      {this.id,
      this.driver,
      this.subshipment,
      this.responseTurn,
      this.isApproved,
      this.extratext,
      this.reason,
      this.extraFees});

  ApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver = json['driver'];
    subshipment = json['subshipment'] != null
        ? SimpleSubshipment.fromJson(json['subshipment'])
        : null;
    responseTurn = json['response_turn'];
    isApproved = json['is_approved'];
    reason = json['reason'];
    extratext = json['extra_fees_text'];
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
    data['extra_fees_text'] = extratext;
    return data;
  }
}

class OwnerApprovalRequest {
  int? id;
  Driver? driver;
  SimpleSubshipment? subshipment;
  String? responseTurn;
  bool? isApproved;
  String? reason;
  String? extratext;
  double? extraFees;

  OwnerApprovalRequest(
      {this.id,
      this.driver,
      this.subshipment,
      this.responseTurn,
      this.isApproved,
      this.extratext,
      this.reason,
      this.extraFees});

  OwnerApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    subshipment = json['subshipment'] != null
        ? SimpleSubshipment.fromJson(json['subshipment'])
        : null;
    responseTurn = json['response_turn'];
    isApproved = json['is_approved'];
    reason = json['reason'];
    extratext = json['extra_fees_text'];
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
    data['extra_fees_text'] = extratext;
    return data;
  }
}

class MerchantApprovalRequest {
  int? id;
  Driver? driver;
  SimpleMerchantSubshipment? subshipment;
  String? responseTurn;
  bool? isApproved;
  String? reason;
  String? extratext;
  double? extraFees;

  MerchantApprovalRequest(
      {this.id,
      this.driver,
      this.subshipment,
      this.responseTurn,
      this.isApproved,
      this.extratext,
      this.reason,
      this.extraFees});

  MerchantApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
    subshipment = json['subshipment'] != null
        ? SimpleMerchantSubshipment.fromJson(json['subshipment'])
        : null;
    responseTurn = json['response_turn'];
    isApproved = json['is_approved'];
    reason = json['reason'];
    extratext = json['extra_fees_text'];
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
    data['extra_fees_text'] = extratext;
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

class SimpleMerchantSubshipment {
  int? id;
  int? shipment;
  List<PathPoint>? pathpoints;
  DateTime? pickupDate;

  SimpleMerchantSubshipment({
    this.id,
    this.shipment,
    this.pathpoints,
    this.pickupDate,
  });

  SimpleMerchantSubshipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];

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
    data['shipment'] = shipment;
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
  UserModel? user;

  RMerchant({this.id, this.user});

  RMerchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
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
