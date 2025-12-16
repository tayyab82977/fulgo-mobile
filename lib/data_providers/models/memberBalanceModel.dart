class ClientBalanceModel {
  var balance;
  List<PackageOffer>? packageOffer;
  List<DistanceOffer>? offer;
  List<Pricing>? pricing;
  Wallet? wallet;
  List<PaymentMethods>? paymentMethods;

  ClientBalanceModel(
      {this.balance,
        this.packageOffer,
        this.offer,
        this.pricing,
        this.wallet,
        this.paymentMethods});

  ClientBalanceModel.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    if (json['packageOffer'] != null) {
      packageOffer = <PackageOffer>[];
      json['packageOffer'].forEach((v) {
        packageOffer!.add(new PackageOffer.fromJson(v));
      });
    }
    if (json['offer'] != null) {
      offer = <DistanceOffer>[];
      json['offer'].forEach((v) {
        offer!.add(new DistanceOffer.fromJson(v));
      });
    }
    if (json['pricing'] != null) {
      pricing = <Pricing>[];
      json['pricing'].forEach((v) {
        pricing!.add(new Pricing.fromJson(v));
      });
    }
    wallet =
    json['wallet'] != null ? new Wallet.fromJson(json['wallet']) : null;
    if (json['paymentMethods'] != null) {
      paymentMethods = <PaymentMethods>[];
      json['paymentMethods'].forEach((v) {
        paymentMethods!.add(new PaymentMethods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['balance'] = this.balance;
    if (this.packageOffer != null) {
      data['packageOffer'] = this.packageOffer!.map((v) => v.toJson()).toList();
    }
    if (this.offer != null) {
      data['offer'] = this.offer!.map((v) => v.toJson()).toList();
    }
    if (this.pricing != null) {
      data['pricing'] = this.pricing!.map((v) => v.toJson()).toList();
    }
    if (this.wallet != null) {
      data['wallet'] = this.wallet!.toJson();
    }
    if (this.paymentMethods != null) {
      data['paymentMethods'] =
          this.paymentMethods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageOffer {
  String? count;
  String? weight;
  String? distance;
  String? package;

  PackageOffer({this.count, this.weight, this.distance, this.package});

  PackageOffer.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    weight = json['weight'];
    distance = json['distance'];
    package = json['package'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['weight'] = this.weight;
    data['distance'] = this.distance;
    data['package'] = this.package;
    return data;
  }
}

class DistanceOffer {
  String? count;
  String? distance;

  DistanceOffer({this.count, this.distance});

  DistanceOffer.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['distance'] = this.distance;
    return data;
  }
}

class Pricing {
  String? total;
  String? distance;

  Pricing({this.total, this.distance});

  Pricing.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['distance'] = this.distance;
    return data;
  }
}

class Wallet {
  int? id;
  String? deposit;
  String? createdAt;
  String? updatedAt;
  String? member;

  Wallet({this.id, this.deposit, this.createdAt, this.updatedAt, this.member});

  Wallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deposit = json['deposit'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    member = json['member'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['deposit'] = this.deposit;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['member'] = this.member;
    return data;
  }
}

class PaymentMethods {
  String? id;
  String? name;
  bool? selected = false;

  PaymentMethods({this.id, this.name , this.selected = false});

  PaymentMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}


