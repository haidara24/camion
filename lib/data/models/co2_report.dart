class ShippmentDetail {
  List<Load>? load;
  List<Legs>? legs;

  ShippmentDetail({this.load, this.legs});

  ShippmentDetail.fromJson(Map<String, dynamic> json) {
    if (json['load'] != null) {
      load = <Load>[];
      json['load'].forEach((v) {
        load!.add(Load.fromJson(v));
      });
    }
    if (json['legs'] != null) {
      legs = <Legs>[];
      json['legs'].forEach((v) {
        legs!.add(Legs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (load != null) {
      data['load'] = load!.map((v) => v.toJson()).toList();
    }
    if (legs != null) {
      data['legs'] = legs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Load {
  double? unitWeightKg;
  String? unitType;

  Load({this.unitWeightKg, this.unitType});

  Load.fromJson(Map<String, dynamic> json) {
    unitWeightKg = json['unitWeightKg'];
    unitType = json['unitType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unitWeightKg'] = unitWeightKg;
    data['unitType'] = unitType;
    return data;
  }
}

class Legs {
  String? mode;
  Origin? origin;
  Origin? destination;

  Legs({this.mode, this.origin, this.destination});

  Legs.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    origin = json['origin'] != null ? Origin.fromJson(json['origin']) : null;
    destination = json['destination'] != null
        ? Origin.fromJson(json['destination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mode'] = mode;
    if (origin != null) {
      data['origin'] = origin!.toJson();
    }
    if (destination != null) {
      data['destination'] = destination!.toJson();
    }
    return data;
  }
}

class Origin {
  double? longitude;
  double? latitude;

  Origin({this.longitude, this.latitude});

  Origin.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}

class Co2Report {
  String? title;
  double? ew;
  double? gw;
  double? et;
  double? gt;
  String? duration;
  String? distance;
  List<LegsData>? legsData;
  String? shortDeclaration;
  String? report;

  Co2Report(
      {this.title,
      this.ew,
      this.gw,
      this.et,
      this.gt,
      this.legsData,
      this.shortDeclaration,
      this.report});

  Co2Report.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    ew = json['Ew'];
    gw = json['Gw'];
    et = json['Et'];
    gt = json['Gt'];
    if (json['legsData'] != null) {
      legsData = <LegsData>[];
      json['legsData'].forEach((v) {
        legsData!.add(LegsData.fromJson(v));
      });
    }
    shortDeclaration = json['shortDeclaration'];
    report = json['report'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['Ew'] = ew;
    data['Gw'] = gw;
    data['Et'] = et;
    data['Gt'] = gt;
    if (legsData != null) {
      data['legsData'] = legsData!.map((v) => v.toJson()).toList();
    }
    data['shortDeclaration'] = shortDeclaration;
    data['report'] = report;
    return data;
  }
}

class Co2Report2 {
  String? title;
  double? et;
  double? gt;
  String? duration;
  String? distance;

  Co2Report2({
    this.title,
    this.et,
    this.gt,
    this.duration,
    this.distance,
  });

  Co2Report2.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    et = json['Et'];
    gt = json['Gt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['Et'] = et;
    data['Gt'] = gt;
    return data;
  }
}

class LegsData {
  String? title;
  double? ew;
  double? gw;
  double? et;
  double? gt;

  LegsData({this.title, this.ew, this.gw, this.et, this.gt});

  LegsData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    ew = json['Ew'];
    gw = json['Gw'];
    et = json['Et'];
    gt = json['Gt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['Ew'] = ew;
    data['Gw'] = gw;
    data['Et'] = et;
    data['Gt'] = gt;
    return data;
  }
}

class DistanceReport {
  List<Rows>? rows;

  DistanceReport({
    this.rows,
  });

  DistanceReport.fromJson(Map<String, dynamic> json) {
    if (json['rows'] != null) {
      rows = <Rows>[];
      json['rows'].forEach((v) {
        rows!.add(Rows.fromJson(v));
      });
    }
  }
}

class Rows {
  List<Elements>? elements;

  Rows({this.elements});

  Rows.fromJson(Map<String, dynamic> json) {
    if (json['elements'] != null) {
      elements = <Elements>[];
      json['elements'].forEach((v) {
        elements!.add(Elements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (elements != null) {
      data['elements'] = elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Elements {
  Distance? distance;
  Distance? duration;
  String? status;

  Elements({this.distance, this.duration, this.status});

  Elements.fromJson(Map<String, dynamic> json) {
    distance =
        json['distance'] != null ? Distance.fromJson(json['distance']) : null;
    duration =
        json['duration'] != null ? Distance.fromJson(json['duration']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (distance != null) {
      data['distance'] = distance!.toJson();
    }
    if (duration != null) {
      data['duration'] = duration!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class Distance {
  String? text;
  int? value;

  Distance({this.text, this.value});

  Distance.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['value'] = value;
    return data;
  }
}
