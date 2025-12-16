import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';

class PostOrderDataModel {
  String? senderName;
  String? id ;
  String? senderPhone;
  String? pickupTime;
  String? pickupAddress;
  String? pickupNeighborhood;
  String? receiverName;
  String? receiverPhone;
  String? deliverTime;
  String? deliverAddress;
  String? deliverNeighborhood;
  String? pickupMap;
  String? deliverMap;
  int? direction;
  int? packaging;
  List<Packages>? packages;
  String? rc ;
  String? deductFromCod ;
  String? deliverCity ;
  String? pickupCity ;
  String? payment_method ;


  PostOrderDataModel(
      {this.senderName,
        this.senderPhone,
        this.pickupTime,
        this.pickupAddress,
        this.pickupNeighborhood,
        this.receiverName,
        this.receiverPhone,
        this.deliverTime,
        this.deliverAddress,
        this.deliverNeighborhood,
        this.direction,
        this.packaging,
        this.rc,
        this.deductFromCod,
        this.deliverCity,
        this.pickupCity,
        this.payment_method,
        this.packages});

  PostOrderDataModel.fromJson(Map<String, dynamic> json) {
    senderName = json['senderName'];
    id = json['id'];
    senderPhone = json['senderPhone'];
    pickupTime = json['pickupTime'];
    pickupAddress = json['pickupAddress'];
    pickupNeighborhood = json['pickupNeighborhood'];
    receiverName = json['receiverName'];
    receiverPhone = json['receiverPhone'];
    deliverTime = json['deliverTime'];
    deliverAddress = json['deliverAddress'];
    deliverNeighborhood = json['deliverNeighborhood'];
    rc = json['rc'];
    deductFromCod = json['latePayment'];
    direction = json['direction'];
    packaging = json['packaging'];
    deliverCity = json['deliverCity'];
    pickupCity = json['pickupCity'];
    if (json['packages'] != null) {
      packages = [];
      json['packages'].forEach((v) {
        packages!.add(new Packages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['senderName'] = this.senderName;
    data['senderPhone'] = this.senderPhone;
    data['pickupTime'] = this.pickupTime;
    data['pickupAddress'] = this.pickupAddress;
    data['pickupNeighborhood'] = this.pickupNeighborhood;
    data['receiverName'] = this.receiverName;
    data['receiverPhone'] = this.receiverPhone;
    data['deliverTime'] = this.deliverTime;
    data['deliverAddress'] = this.deliverAddress;
    data['deliverNeighborhood'] = this.deliverNeighborhood;
    data['direction'] = this.direction;
    data['packaging'] = this.packaging;
    data['id'] = this.id;
    data['rc'] = this.rc;
    data['deliverCity'] = this.deliverCity;
    data['pickupCity'] = this.pickupCity;
    data['latePayment'] = this.deductFromCod;
    if (this.packages != null) {
      data['packages'] = this.packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

