import 'package:equatable/equatable.dart';
import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';

class ResourcesData {


  List<Cancellation>? paymentType;
  List<Cancellation>? cancellation;
  List<Cancellation>? signatures;
  List<Cancellation>? trackType;
  List<Cancellation>? rowStatus;
  List<Cancellation>? ticketStatus;
  List<Packaging>? packaging;
  List<Cancellation>? banks;
  List<Cancellation>? province;
  List<Cancellation>? postpone;
  List<Cancellation>? ticketCategory;
  List<Cancellation>? service_type;
  List<Cancellation>? fuel_grade;
  List<Cancellation>? spare_parts;
  List<PaymentMethods>? payment_method;
  List<PaymentMethod>? paymentMethods;
  List<ErCity>? city;
  String? appVersion;
  String? whatsappMsg;
  String? customerSupportNumber;
  String? customerSupportWhatsapp;
  var priceInside ;
  var priceOutside ;
  double priceIn = 0 ;
  double priceOut = 0 ;


  ResourcesData(
      {
      this.cancellation,
      this.signatures,
      this.trackType,
      this.rowStatus,
      this.packaging,
      this.province,
      this.city,
      this.banks,
      this.paymentMethods,
      this.appVersion,
      this.postpone,
      this.whatsappMsg,
      this.ticketCategory,
      this.priceInside,
      this.service_type,
      this.fuel_grade,
      this.priceOutside,
      this.customerSupportNumber ,
      this.customerSupportWhatsapp ,
      });

  ResourcesData.fromJson(Map<String, dynamic> json) {
    whatsappMsg = json['whatsappMsg'];
    appVersion = json['appVersion'];
    priceInside = json['priceInside'];
    priceOutside = json['priceOutside'];
    customerSupportNumber = json['customerSupportNumber'] ?? "8001111757";
    customerSupportWhatsapp = json['customerSupportWhatsapp'] ?? "0580000451";
    priceIn = double.tryParse(json['priceInside'].toString()) ?? 0;
    priceOut = double.tryParse(json['priceOutside'].toString()) ?? 0;

    if (json['ticket_cat'] != null) {
      ticketCategory = [];
      json['ticket_cat'].forEach((v) {
        ticketCategory!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['paymentMethod'] != null) {
      paymentMethods = [];
      json['paymentMethod'].forEach((v) {
        paymentMethods!.add(new PaymentMethod.fromJson(v));
      });
    }
    if (json['ticketStatus'] != null) {
      ticketStatus = [];
      json['ticketStatus'].forEach((v) {
        ticketStatus!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['payment_method'] != null) {
      payment_method = [];
      json['payment_method'].forEach((v) {
        payment_method!.add(new PaymentMethods.fromJson(v));
      });
    }
    if (json['bank'] != null) {
      banks = [];
      json['bank'].forEach((v) {
        banks!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['spare_parts'] != null) {
      spare_parts = [];
      json['spare_parts'].forEach((v) {
        spare_parts!.add(new Cancellation.fromJson(v));
      });
    }

    if (json['cancellation'] != null) {
      cancellation = [];
      json['cancellation'].forEach((v) {
        cancellation!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['fuel_grade'] != null) {
      fuel_grade = [];
      json['fuel_grade'].forEach((v) {
        fuel_grade!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['service_type'] != null) {
      service_type = [];
      json['service_type'].forEach((v) {
        service_type!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['postpone'] != null) {
      postpone = [];
      json['postpone'].forEach((v) {
        postpone!.add(new Cancellation.fromJson(v));
      });
    }

    if (json['signatures'] != null) {
      signatures = [];
      json['signatures'].forEach((v) {
        signatures!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['paymentType'] != null) {
      paymentType = [];
      json['paymentType'].forEach((v) {
        paymentType!.add(new Cancellation.fromJson(v));
      });
    }

    if (json['trackType'] != null) {
      trackType = [];
      json['trackType'].forEach((v) {
        trackType!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['rowStatus'] != null) {
      rowStatus = [];
      json['rowStatus'].forEach((v) {
        rowStatus!.add(new Cancellation.fromJson(v));
      });
    }
    if (json['packaging'] != null) {
      packaging = [];
      json['packaging'].forEach((v) {
        packaging!.add(new Packaging.fromJson(v));
      });
    }
    if (json['city'] != null) {
      city = [];
      json['city'].forEach((v) {
        city!.add(new ErCity.fromJson(v));
      });
    }
;
    }
  }

class Countries {
  String? id;
  String? name;

  Countries({this.id, this.name});

  Countries.fromJson(Map<String, dynamic> json) {
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

class Packaging extends Equatable {
  String? id;
  String? name;
  String? extra;
  String? icon;

  Packaging({this.id, this.name, this.extra, this.icon});

  @override
  List<Object?> get props => [id, name, extra, icon];

  Packaging.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    extra = json['extra'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['extra'] = this.extra;
    data['icon'] = this.icon;
    return data;
  }
}

class Offer {
  String? id;
  String? name;
  String? weight;
  String? distance;
  String? count;
  String? price;

  Offer(
      {this.id, this.name, this.weight, this.distance, this.count, this.price});

  Offer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    weight = json['weight'];
    distance = json['distance'];
    count = json['count'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['weight'] = this.weight;
    data['distance'] = this.distance;
    data['count'] = this.count;
    data['price'] = this.price;
    return data;
  }
}

class ErCity extends Equatable {
  String? id;
  String? name;
  String? province;
  String? provinceName;
  String? country;
  String? countryName;
  String? send;
  String? receive;
  String? cod;
  List<Neighborhoods>? neighborhoods;

  ErCity(
      {this.id,
      this.name,
      this.province,
      this.provinceName,
      this.country,
      this.countryName,
      this.send,
      this.receive,
      this.cod,
      this.neighborhoods});

  @override
  List<Object?> get props => [
        id,
        name,
        province,
        provinceName,
        country,
        countryName,
        send,
        receive,
        cod,
        neighborhoods,
      ];

  ErCity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    province = json['province'];
    provinceName = json['provinceName'];
    country = json['country'];
    countryName = json['countryName'];
    send = json['send'];
    receive = json['receive'];
    cod = json['cod'];
    if (json['neighborhoods'] != null) {
      neighborhoods = [];
      json['neighborhoods'].forEach((v) {
        neighborhoods!.add(new Neighborhoods.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['province'] = this.province;
    data['provinceName'] = this.provinceName;
    data['country'] = this.country;
    data['countryName'] = this.countryName;
    data['send'] = this.send;
    data['receive'] = this.receive;
    data['cod'] = this.cod;
    if (this.neighborhoods != null) {
      data['neighborhoods'] =
          this.neighborhoods!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return "$name   ";
    // return name!;
  }
}

class Neighborhoods extends Equatable {
  String? id;
  String? name;
  String? ne;
  String? sw;

  Neighborhoods({this.id, this.name, this.ne, this.sw});

  @override
  List<Object?> get props => [id, name, ne, sw];

  Neighborhoods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    ne = json['ne'];
    sw = json['sw'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['ne'] = this.ne;
    data['sw'] = this.sw;
    return data;
  }

  @override
  String toString() {
    return "$name  ";
  }
}

class Zone {
  String? id;
  String? name;
  String? store;
  String? comment;

  Zone({this.id, this.name, this.store, this.comment});

  Zone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    store = json['store'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['store'] = this.store;
    data['comment'] = this.comment;
    return data;
  }
}

class Weight {
  String? id;
  String? name;
  String? min;
  String? max;
  List<Prices>? prices;

  Weight({this.id, this.name, this.min, this.max, this.prices});

  Weight.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    min = json['min'];
    max = json['max'];
    if (json['prices'] != null) {
      prices = [];
      json['prices'].forEach((v) {
        prices!.add(new Prices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['min'] = this.min;
    data['max'] = this.max;
    if (this.prices != null) {
      data['prices'] = this.prices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Prices {
  String? id;
  String? name;
  var price;

  Prices({this.id, this.name, this.price});

  Prices.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
class PaymentMethod {
  String? id;
  String? name;
  String? val2;
  bool isSelected = false ;

  PaymentMethod({this.id, this.name, this.val2 , this.isSelected = false});

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    val2 = json['val2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['val2'] = this.val2;
    return data;
  }
}


class Cancellation extends Equatable {
  Cancellation({
    this.id,
    this.name,
    this.nameAr,
    this.nameEn,
    this.amount,
    this.checked = false ,
    this.quantity
  });

  String? id;
  String? name;
  String? nameAr;
  String? nameEn;
  String? amount;
  bool checked = false ;
  String? quantity  ;

  @override
  List<Object?> get props => [id, name , amount ,checked , quantity ];

  factory Cancellation.fromJson(Map<String, dynamic> json) => Cancellation(
        id: json["id"],
        name: json["name"],
        nameAr: json["name_ar"],
        nameEn: json["name_en"],
        amount: json["amount"],
      quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
        "quantity": quantity,
      };
}
//
// class Packaging extends Equatable {
//   Packaging({
//     this.id,
//     this.name,
//     this.extra,
//   });
//
//   String id;
//   String name;
//   String extra;
//
//   @override
//   List<Object> get props => [id, name , extra ];
//
//   factory Packaging.fromJson(Map<String, dynamic> json) => Packaging(
//     id: json["id"],
//     name: json["name"],
//     extra: json["extra"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "extra": extra,
//   };
// }
//
// class ErCity extends Equatable {
//
//   String id;
//   String name;
//   String nameEn;
//   ErCity({this.id, this.name , this.nameEn});
//
//
//
//   @override
//   List<Object> get props => [id, name , nameEn ];
//
//   factory ErCity.fromJson(Map<String, dynamic> json) => ErCity(
//     id: json["id"],
//     name: json["name"],
//     nameEn: json["name"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name_ar": name,
//     "name_en": nameEn,
//   };
// }
//
// class Weight extends Equatable{
//   Weight({
//     this.id,
//     this.name,
//     this.min,
//     this.max,
//     this.prices,
//   });
//
//   String id;
//   String name;
//   String min;
//   String max;
//   List<Price> prices;
//
//   @override
//   List<Object> get props => [id, name , min , max ,prices ];
//
//   factory Weight.fromJson(Map<String, dynamic> json) => Weight(
//     id: json["id"],
//     name: json["name"],
//     min: json["min"],
//     max: json["max"],
//     prices: List<Price>.from(json["prices"].map((x) => Price.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "min": min,
//     "max": max,
//     "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
//   };
// }
//
// class Price extends Equatable{
//   Price({
//     this.id,
//     this.name,
//     this.price,
//     this.express,
//   });
//
//   String id;
//   String name;
//   String price;
//   String express;
//
//   @override
//   List<Object> get props => [id, name , price , express ];
//
//   factory Price.fromJson(Map<String, dynamic> json) => Price(
//     id: json["id"],
//     name: json["name"],
//     price: json["price"],
//     express: json["express"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "price": price,
//     "express": express,
//   };
// }
