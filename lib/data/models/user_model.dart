import 'package:camion/data/models/truck_model.dart';

class UserModel {
  String? id;
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
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? image;
  String? user;

  Merchant({
    this.id,
    this.stores,
    this.verified,
    this.address,
    this.companyName,
    this.imageId,
    this.imageTradeLicense,
    this.image,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
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
    verified = json['verified'] ?? false;
    image = json['image'];
    firstname = json['first_name'];
    lastname = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    companyName = json['company_name'];
    imageId = json['imageId'] ?? "";
    imageTradeLicense = json['imageTradeLicense'] ?? "";
    user = json['user'];
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
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? image;
  String? user;
  List<KTruck>? trucks;

  TruckOwner({
    this.id,
    this.image,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.user,
    this.trucks,
  });

  TruckOwner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    image = json['image'];
    firstname = json['first_name'] ?? "";
    lastname = json['last_name'] ?? "";
    email = json['email'] ?? "";
    phone = json['phone'] ?? "";
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
    data['user'] = user!;
    if (trucks != null) {
      data['trucks'] = trucks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Driver {
  int? id;
  String? firstname;
  String? lastname;
  String? email;
  String? phone;
  String? image;
  String? truck_type;
  String? truck_type_ar;
  int? truck;
  String? user;

  Driver({
    this.id,
    this.image,
    this.firstname,
    this.lastname,
    this.email,
    this.phone,
    this.truck_type_ar,
    this.truck_type,
    this.truck,
    this.user,
  });

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    truck = json['truck2'];
    image = json['image'];
    firstname = json['first_name'];
    lastname = json['last_name'];
    email = json['email'] ?? "";
    phone = json['phone'] ?? "";
    truck_type_ar = json['truck_type_ar'];
    truck_type = json['truck_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['truck'] = truck;
    data['user'] = user!;
    return data;
  }
}
