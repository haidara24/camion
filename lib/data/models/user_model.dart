import 'package:camion/data/models/truck_model.dart';

class UserModel {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? image;
  int? merchant;
  int? truckowner;
  int? truckuser;

  UserModel(
      {this.id,
      this.username,
      this.firstName,
      this.lastName,
      this.phone,
      this.email,
      this.image,
      this.merchant,
      this.truckowner,
      this.truckuser});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    phone = json['phone'] ?? "";
    email = json['email'] ?? "";
    image = json['image'] ?? "";
    merchant = json['merchant'] ?? 0;
    truckowner = json['truckowner'] ?? 0;
    truckuser = json['truckuser'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone'] = phone;
    data['email'] = email;
    data['image'] = image;
    // if (merchant != null) {
    //   data['merchant'] = merchant!.toJson();
    // }
    // if (truckowner != null) {
    //   data['truckowner'] = truckowner!.toJson();
    // }
    // if (truckuser != null) {
    //   data['truckuser'] = truckuser!.toJson();
    // }
    return data;
  }
}

class Merchant {
  int? id;
  List<Stores>? stores;
  bool? verified;
  String? address;
  String? companyName;
  String? imageId;
  String? imageTradeLicense;
  UserModel? user;

  Merchant({
    this.id,
    this.stores,
    this.verified,
    this.address,
    this.companyName,
    this.imageId,
    this.imageTradeLicense,
    this.user,
  });

  Merchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['stores'] != null) {
      stores = <Stores>[];
      json['stores'].forEach((v) {
        stores!.add(Stores.fromJson(v));
      });
    }
    verified = json['verified'];
    address = json['address'] ?? "";
    companyName = json['company_name'] ?? "";
    imageId = json['imageId'] ?? "";
    imageTradeLicense = json['imageTradeLicense'] ?? "";
    user = json['user'] != null ? UserModel.fromJson(json["user"]) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    data['verified'] = verified;
    data['address'] = address;
    data['company_name'] = companyName;
    data['imageId'] = imageId;
    data['imageTradeLicense'] = imageTradeLicense;
    data['user'] = user;
    return data;
  }
}

class Stores {
  int? id;
  String? address;
  String? location;
  int? merchant;

  Stores({this.id, this.address, this.location, this.merchant});

  Stores.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    location = json['location'];
    merchant = json['merchant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['location'] = location;
    data['merchant'] = merchant;
    return data;
  }
}

class TruckOwner {
  int? id;
  UserModel? user;
  List<KTruck>? trucks;

  TruckOwner({
    this.id,
    this.user,
    this.trucks,
  });

  TruckOwner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    if (json['trucks'] != null) {
      trucks = <KTruck>[];
      json['trucks'].forEach((v) {
        trucks!.add(KTruck.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (trucks != null) {
      data['trucks'] = trucks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Truckuser {
  int? id;
  bool? isTruckowner;

  Truckuser({this.id, this.isTruckowner});

  Truckuser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isTruckowner = json['is_truckowner'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_truckowner'] = isTruckowner;
    return data;
  }
}

class Driver {
  int? id;
  UserModel? user;
  KTruck? truck;

  Driver({
    this.id,
    this.user,
    this.truck,
  });

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    truck = json['truck2'] != null ? KTruck.fromJson(json['truck2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (truck != null) {
      data['truck'] = truck!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
