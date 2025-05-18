import 'package:camion/data/models/shipmentv2_model.dart';

class ApprovalRequest {
  int? id;
  String? driver_firstname;
  String? driver_lastname;
  SimpleSubshipment? subshipment;
  String? responseTurn;
  String? requestOwner;
  bool? isApproved;
  String? reason;

  ApprovalRequest({
    this.id,
    this.driver_firstname,
    this.driver_lastname,
    this.subshipment,
    this.responseTurn,
    this.requestOwner,
    this.isApproved,
    this.reason,
  });

  ApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver_firstname = json['driver_firstname'];
    driver_lastname = json['driver_lastname'];
    subshipment = json['subshipment'] != null
        ? SimpleSubshipment.fromJson(json['subshipment'])
        : null;
    responseTurn = json['response_turn'];
    requestOwner = json['request_owner'];
    isApproved = json['is_approved'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['driver_firstname'] = driver_firstname;
    data['driver_lastname'] = driver_lastname;
    if (subshipment != null) {
      data['subshipment'] = subshipment!.toJson();
    }
    data['response_turn'] = responseTurn;
    data['request_owner'] = requestOwner;
    data['is_approved'] = isApproved;
    data['reason'] = reason;
    return data;
  }
}

class ApprovalRequestForShipment {
  int? id;
  String? driver_firstname;
  String? driver_lastname;
  int? subshipment;
  String? responseTurn;
  String? requestOwner;
  bool? isApproved;
  String? reason;

  ApprovalRequestForShipment({
    this.id,
    this.driver_firstname,
    this.driver_lastname,
    this.subshipment,
    this.responseTurn,
    this.requestOwner,
    this.isApproved,
    this.reason,
  });

  ApprovalRequestForShipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver_firstname = json['driver_firstname'] ?? "";
    driver_lastname = json['driver_lastname'] ?? "";
    subshipment = json['subshipment'] ?? 0;
    responseTurn = json['response_turn'];
    requestOwner = json['request_owner'];
    isApproved = json['is_approved'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['driver_firstname'] = driver_firstname;
    data['driver_lastname'] = driver_lastname;
    data['subshipment'] = subshipment;
    data['response_turn'] = responseTurn;
    data['request_owner'] = requestOwner;
    data['is_approved'] = isApproved;
    data['reason'] = reason;
    return data;
  }
}

class SimpleSubshipment {
  int? id;
  int? shipment;
  String? firstname;
  String? lastname;
  List<PathPoint>? pathpoints;
  DateTime? pickupDate;
  double? distance;
  int? weight;

  SimpleSubshipment({
    this.id,
    this.shipment,
    this.firstname,
    this.lastname,
    this.pathpoints,
    this.pickupDate,
    this.distance,
    this.weight,
  });

  SimpleSubshipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    firstname = json['first_name'];
    lastname = json['last_name'];
    distance = json['distance'];
    weight = json['total_weight'];

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
    data['shipment'] = shipment!;
    data['firstname'] = firstname!;
    data['lastname'] = lastname!;

    data['pickup_date'] = pickupDate?.toIso8601String();
    if (pathpoints != null) {
      data['path_points'] = pathpoints!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class SubshipmentForRequest {
  int? id;
  int? shipment;
  String? firstname;
  String? lastname;
  String? driver_firstname;
  String? driver_lastname;
  List<PathPoint>? pathpoints;
  DateTime? pickupDate;
  double? distance;
  int? weight;
  ApprovalRequestForShipment? approvalRequest;

  SubshipmentForRequest({
    this.id,
    this.shipment,
    this.firstname,
    this.lastname,
    this.pathpoints,
    this.pickupDate,
    this.distance,
    this.weight,
    this.approvalRequest,
  });

  SubshipmentForRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    firstname = json['first_name'];
    lastname = json['last_name'];
    distance = json['distance'];
    driver_firstname = json['driver_firstname'] ?? "";
    driver_lastname = json['driver_lastname'] ?? "";
    weight = json['total_weight'];
    approvalRequest = json['approvalrequest'] != null
        ? ApprovalRequestForShipment.fromJson(json['approvalrequest'])
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
    data['shipment'] = shipment!;
    data['firstname'] = firstname!;
    data['lastname'] = lastname!;

    data['pickup_date'] = pickupDate?.toIso8601String();
    if (pathpoints != null) {
      data['path_points'] = pathpoints!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
