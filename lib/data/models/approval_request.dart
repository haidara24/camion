import 'package:camion/data/models/shipmentv2_model.dart';

class ApprovalRequest {
  int? id;
  String? driver_firstname;
  String? driver_lastname;
  SimpleSubshipment? subshipment;
  String? responseTurn;
  bool? isApproved;
  String? reason;
  String? extratext;
  double? extraFees;

  ApprovalRequest(
      {this.id,
      this.driver_firstname,
      this.driver_lastname,
      this.subshipment,
      this.responseTurn,
      this.isApproved,
      this.extratext,
      this.reason,
      this.extraFees});

  ApprovalRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver_firstname = json['driver_firstname'];
    driver_lastname = json['driver_lastname'];
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
    data['driver_firstname'] = driver_firstname;
    data['driver_lastname'] = driver_lastname;
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
  int? shipment;
  String? firstname;
  String? lastname;
  List<PathPoint>? pathpoints;
  DateTime? pickupDate;

  SimpleSubshipment({
    this.id,
    this.shipment,
    this.firstname,
    this.lastname,
    this.pathpoints,
    this.pickupDate,
  });

  SimpleSubshipment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shipment = json['shipment'];
    firstname = json['first_name'];
    lastname = json['last_name'];

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
