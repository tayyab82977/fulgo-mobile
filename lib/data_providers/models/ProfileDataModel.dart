  import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:xturbox/data_providers/models/memberBalanceModel.dart';

class ProfileDataModel {
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? birthday;
  String? phone;
  List<Addresses>? addresses;
  String? status;
  String? permission;
  String? idType;
  String? idNumber;
  String? joined;
  String? bankName;
  String? bank;
  String? iban;
  String? company;
  String? membership;
  String? bankHolder ;
  String? signature ;
  String? supervisorName ;
  String? supervisorPhone ;
  String? done ;
  String? orders ;
  String? phone2 ;
  String? national_id ;
  String? member_pin ;
  String? vehicle ;
  String? companyName ;
  String? vatNumber ;
  String? cer ;
  String? memberPricing ;
  String? city ;
  String? neighborhood ;
  String? street ;
  String? building ;
  String? postal_code ;
  String? additional_code ;
  String? unit ;
  String? short_address ;
  var amount;
  var available;
  var trips;
  var activeTrip;
  var paidViolations;
  var unPaidViolations;
  var dismissViolations;
  var wallet;
  // Wallet? wallet;
  List<Credit>? credit;
  List<PackageOffer>? packageOffer;
  List<DistanceOffer>? offer;
  Amounts? amounts;
  Meter? meter;
  Meter? meterYesterday;
  bool yesterDayExist = false ;
  LastWithdraw? lastWithdraw;


  ProfileDataModel(
  {this.id,
  this.name,
  this.username,
  this.email,
    this.bankHolder,
    this.signature,
  this.birthday,
  this.phone,
  this.addresses,
  this.status,
  this.permission,
  this.idType,
  this.idNumber,
  this.joined,
  this.bankName,
  this.iban,
  this.company,
  this.membership,
  this.amount,
  this.credit,
  this.supervisorName,
  this.supervisorPhone,
  this.done,
  this.orders,
  this.bank,
  this.national_id,
  this.phone2,
    this.packageOffer,
    this.amounts,
    this.firstName,
    this.lastName,
    this.member_pin,
    this.available,
    this.lastWithdraw,
    this.meter,
    this.meterYesterday,
    this.vehicle,
    this.wallet,
    this.city,
    this.neighborhood,
    this.street,
    this.building,
    this.postal_code,
    this.additional_code,
    this.unit,
    this.short_address,
  });

  ProfileDataModel.fromJson(Map<String, dynamic> json) {
  id = json['id'].toString();
  name = json['name'];
  firstName = json['first_name'];
  lastName = json['second_name'];
  username = json['username'];
  email = json['email'];
  birthday = json['birthday'];
  phone = json['phone'];
  if (json['addresses'] != null && json['addresses'] != false) {
  addresses = [];
  json['addresses'].forEach((v) {
  addresses!.add(new Addresses.fromJson(v));
  });
  }
  if (json['offer'] != null) {
    offer = <DistanceOffer>[];
    json['offer'].forEach((v) {
      offer!.add(new DistanceOffer.fromJson(v));
    });
  }
  status = json['status'];
  permission = json['permission'];
  idType = json['idType'];
  idNumber = json['idNumber'];
  signature = json['signature'];
  joined = json['joined'];
  bankName = json['bankName'];
  iban = json['iban'];
  bank = json['bank'];
  company = json['company'];
  orders = json['orders'].toString();
  done = json['done'].toString();
  supervisorPhone = json['supervisorPhone'];
  supervisorName = json['supervisorName'];
  membership = json['membership'];
  amount = double.tryParse(json['amount'].toString()) ?? 0;
  phone2 = json['phone2'];
  member_pin = json['member_pin'];
  bankHolder = json['bankHolder'];
  national_id = json['national_id'];
  available = json['available'];
  companyName = json['company'];
  wallet = json['wallet'];
  vatNumber = json['vat'];
  trips = json['trips'];
  memberPricing = json['memberPricing'];
  paidViolations = json['paidViolations'];
  unPaidViolations = json['unPaidViolations'];
  dismissViolations = json['dismissViolations'];

  city = json['city'];
  neighborhood = json['neighborhood'];
  street = json['street'];
  building = json['building'];
  postal_code = json['postal_code'];
  additional_code = json['additional_code'];
  unit = json['unit'];
  short_address = json['short_address'];


  activeTrip = json['activeTrip'];
  cer = json['cr'];
  // wallet = json['wallet'] != null ? new Wallet.fromJson(json['wallet']) : null;
  if (json['credit'] != null && json['credit'] != false ) {
    credit = [];
    json['credit'].forEach((v) {
      credit!.add(new Credit.fromJson(v));
    });
  }
  amounts = json['amounts'] != null ? new Amounts.fromJson(json['amounts']) : null;
  meter = json['meter'] != null ? new Meter.fromJson(json['meter']) : null;
  yesterDayExist = json['meterYesterday'].toString() == '1'? false : true ;
  meterYesterday = json['meterYesterday'] != null && json['meterYesterday'].toString() != '1'? new Meter.fromJson(json['meterYesterday']) : null;
  if (json['packageOffer'] != null) {
    packageOffer = [];
    json['packageOffer'].forEach((v) {
      packageOffer!.add(new PackageOffer.fromJson(v));
    });
  }
  // if (this.packageOffer != null) {
  //   json['offers'] = this.packageOffer!.map((v) => v.toJson()).toList();
  // }
  lastWithdraw = json['lastWithdraw'] != null
      ? new LastWithdraw.fromJson(json['lastWithdraw'])
      : null;
  // credit = json['credit'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['name'] = this.name;
  data['first_name'] = this.firstName;
  data['second_name'] = this.lastName;
  data['username'] = this.username;
  data['email'] = this.email;
  data['birthday'] = this.birthday;
  data['phone'] = this.phone;
  if (this.addresses != null) {
  data['addresses'] = this.addresses!.map((v) => v.toJson()).toList();
  }
  data['status'] = this.status;
  data['permission'] = this.permission;
  data['idType'] = this.idType;
  data['bankHolder'] = this.bankHolder;
  data['idNumber'] = this.idNumber;
  data['joined'] = this.joined;
  data['bankName'] = this.bankName;
  data['bank'] = this.bank;
  data['iban'] = this.iban;
  data['company'] = this.company;
  data['membership'] = this.membership;
  data['supervisorName'] = this.supervisorName;
  data['supervisorPhone'] = this.supervisorPhone;
  data['done'] = this.done;
  data['orders'] = this.orders;
  data['amount'] = this.amount;
  data['credit'] = this.credit;
  data['phone2'] = this.phone2;
  data['national_id'] = this.national_id;
  data['member_pin'] = this.member_pin;
  if (this.amounts != null) {
    data['amounts'] = this.amounts!.toJson();
  }
  if (this.packageOffer != null) {
    data['offers'] = this.packageOffer!.map((v) => v.toJson()).toList();
  }
  if (this.lastWithdraw != null) {
    data['lastWithdraw'] = this.lastWithdraw!.toJson();
  }
  return data;
  }
  }

  class Addresses  {
  String? title;
  String? description;
  String? city;
  String? map;
  String? comment;
  Icon? icon ;
  String? key ;

  Addresses({this.title, this.description, this.city, this.map, this.comment , this.icon,this.key});

  Addresses.fromJson(Map<String, dynamic> json) {
  title = json['title'];
  description = json['description'];
  city = json['neighborhood'];
  map = json['map'];
  comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['title'] = this.title;
  data['description'] = this.description;
  data['neighborhood'] = this.city;
  data['map'] = this.map;
  data['comment'] = this.comment;
  return data;
  }

  // @override
  // List<Object> get props => [title, description , city , map , comment , icon ];
  }


  class Credit  {
    String? id;
    String? name;
    List<Distance>? distance;

    Credit({this.id, this.name, this.distance});

    Credit.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      name = json['name'];
      if (json['distance'] != null) {
        distance = [];
        json['distance'].forEach((v) {
          distance!.add(new Distance.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      data['name'] = this.name;
      if (this.distance != null) {
        data['distance'] = this.distance!.map((v) => v.toJson()).toList();
      }
      return data;
    }
  }
  class LastWithdraw {
    var stamp;
    var amount;

    LastWithdraw({this.stamp, this.amount});

    LastWithdraw.fromJson(Map<String, dynamic> json) {
      stamp = json['stamp'];
      amount = json['amount'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['stamp'] = this.stamp;
      data['amount'] = this.amount;
      return data;
    }
  }
  class Offers {
    String? weight;
    String? distance;
    String? count;

    Offers({this.weight, this.distance, this.count});

    Offers.fromJson(Map<String, dynamic> json) {
      weight = json['weight'];
      distance = json['distance'];
      count = json['count'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['weight'] = this.weight;
      data['distance'] = this.distance;
      data['count'] = this.count;
      return data;
    }
  }

  class Amounts {
    var total;
    var available;

    Amounts({this.total, this.available});

    Amounts.fromJson(Map<String, dynamic> json) {
      total = json['total'];
      available = json['available'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['total'] = this.total;
      data['available'] = this.available;
      return data;
    }
  }
  class Meter {
    var start;
    var end;
    String? id ;
    String? vehicle ;
    String? courier ;
    var created_at ;
    var updated_at ;
    Meter({this.id ,this.courier, this.vehicle ,this.start, this.end});

    Meter.fromJson(Map<String, dynamic> json) {
      id = json['id'].toString();
      vehicle = json['vehicle'].toString();
      courier = json['courier'].toString();
      start = json['start'];
      end = json['end'];
      created_at = DateTime.tryParse(json['created_at']);
      updated_at = DateTime.tryParse(json['updated_at']);
    }

  }

  class Distance {
    String? id;
    String? name;
    var credit;

    Distance({this.id, this.name, this.credit});

    Distance.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      name = json['name'];
      credit = json['credit'];
    }

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['id'] = this.id;
      data['name'] = this.name;
      data['credit'] = this.credit;
      return data;
    }
  }