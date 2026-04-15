// class CapOrdersDataModel {
//   CapOrdersDataModel({
//     this.toStore,
//     this.fromStore,
//   });
//
//   List<List<Store>> toStore;
//   List<List<Store>> fromStore;
//
//   factory CapOrdersDataModel.fromJson(Map<String, dynamic> json) => CapOrdersDataModel(
//     toStore: List<List<Store>>.from(json["toStore"].map((x) => List<Store>.from(x.map((x) => Store.fromJson(x))))),
//     fromStore: List<List<Store>>.from(json["fromStore"].map((x) => List<Store>.from(x.map((x) => Store.fromJson(x))))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "toStore": List<dynamic>.from(toStore.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
//     "fromStore": List<dynamic>.from(fromStore.map((x) => x)),
//   };
// }
//
// class Store {
//   Store({
//     this.id,
//     this.barcode,
//     this.stamp,
//     this.member,
//     this.memberName,
//     this.senderName,
//     this.senderPhone,
//     this.pickupTime,
//     this.pickupAddress,
//     this.pickupCity,
//     this.pickupMap,
//     this.receiverName,
//     this.receiverPhone,
//     this.deliverTime,
//     this.deliverAddress,
//     this.deliverCity,
//     this.deliverMap,
//     this.status,
//     this.cancellation,
//     this.direction,
//     this.followup,
//     this.packages,
//     this.cost,
//     this.comment,
//     this.accepted
//   });
//
//   String id;
//   dynamic barcode;
//   DateTime stamp;
//   String member;
//   String memberName;
//   String senderName;
//   String senderPhone;
//   String pickupTime;
//   String pickupAddress;
//   String pickupCity;
//   String pickupMap;
//   String receiverName;
//   String receiverPhone;
//   String deliverTime;
//   String deliverAddress;
//   String deliverCity;
//   String deliverMap;
//   String status;
//   String cancellation;
//   String direction;
//   String followup;
//   List<Packages> packages;
//   String cost;
//   String comment;
//   bool accepted ;
//
//   factory Store.fromJson(Map<String, dynamic> json) => Store(
//     id: json["id"],
//     barcode: json["barcode"],
//     stamp: DateTime.parse(json["stamp"]),
//     member: json["member"],
//     memberName: json["memberName"],
//     senderName: json["senderName"],
//     senderPhone: json["senderPhone"],
//     pickupTime: json["pickupTime"],
//     pickupAddress: json["pickupAddress"],
//     pickupCity: json["pickupCity"],
//     pickupMap: json["pickupMap"] == null ? null : json["pickupMap"],
//     receiverName: json["receiverName"],
//     receiverPhone: json["receiverPhone"],
//     deliverTime: json["deliverTime"],
//     deliverAddress: json["deliverAddress"],
//     deliverCity: json["deliverCity"],
//     deliverMap: json["deliverMap"] == null ? null : json["deliverMap"],
//     status: json["status"],
//     cancellation: json["cancellation"],
//     direction: json["direction"],
//     followup: json["followup"],
//     packages: (List<dynamic>.from(json["packages"].map((x) => x))).cast<Packages>(),
//     cost: json["cost"],
//     comment: json["comment"] == null ? null : json["comment"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "barcode": barcode,
//     "stamp": stamp.toIso8601String(),
//     "member": member,
//     "memberName": memberName,
//     "senderName": senderName,
//     "senderPhone": senderPhone,
//     "pickupTime": pickupTime,
//     "pickupAddress": pickupAddress,
//     "pickupCity": pickupCity,
//     "pickupMap": pickupMap == null ? null : pickupMap,
//     "receiverName": receiverName,
//     "receiverPhone": receiverPhone,
//     "deliverTime": deliverTime,
//     "deliverAddress": deliverAddress,
//     "deliverCity": deliverCity,
//     "deliverMap": deliverMap == null ? null : deliverMap,
//     "status": status,
//     "cancellation": cancellation,
//     "direction": direction,
//     "followup": followup,
//     "packages": List<Packages>.from(packages.map((x) => x)),
//     "cost": cost,
//     "comment": comment == null ? null : comment,
//   };
// }
//
// class Packages {
//   Packages({
//     this.packaging,
//     this.weight,
//     this.length,
//     this.width,
//     this.height,
//     this.comment,
//   });
//
//   String packaging;
//   String weight;
//   double length;
//   double width;
//   double height;
//   String comment;
//
//   factory Packages.fromJson(Map<String, dynamic> json) => Packages(
//     packaging: json["packaging"],
//     weight: json["weight"],
//     length: json["length"].toDouble(),
//     width: json["width"].toDouble(),
//     height: json["height"].toDouble(),
//     comment: json["comment"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "packaging": packaging,
//     "weight": weight,
//     "length": length,
//     "width": width,
//     "height": height,
//     "comment": comment,
//   };
// }
//
//

import 'package:equatable/equatable.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';

// @override
// List<Object> get props => [id , barcode , stamp , member , memberName , senderName , senderPhone , pickupTime , pickupAddress ,
//   pickupCity , pickupMap , receiverName , receiverPhone , deliverTime, deliverAddress,deliverCity,deliverMap,status,cancellation,direction,followup,
//   packages,cost,comment , accepted];
class CapOrdersDataModel {
  CapOrdersDataModel({
    this.fromClient,
    this.reserves,
  });

  List<List<OrdersDataModelMix>>? fromClient;
  List<List<OrdersDataModelMix>>? reserves;

  factory CapOrdersDataModel.fromJson(Map<String, dynamic> json) =>
      CapOrdersDataModel(
        fromClient: List<List<OrdersDataModelMix>>.from(json["toStore"].map((x) =>
            List<OrdersDataModelMix>.from(
                x.map((x) => OrdersDataModelMix.fromJson(x))))),
        reserves: List<List<OrdersDataModelMix>>.from(json["reserves"].map((x) =>
        List<OrdersDataModelMix>.from(
            x.map((x) => OrdersDataModelMix.fromJson(x))))),

      );
}

class Packages {
  Packages(
      {this.packaging,
      this.weight,
      this.length,
      this.width,
      this.height,
      this.comment,
      this.fragile,
      this.cod,
      this.extra,
      this.price,
      this.quantity,
      this.deductFromCod});

  String? packaging;
  String? quantity;
  String? weight;
  double? length;
  double? width;
  double? height;
  String? comment;
  String? fragile;
  String? cod;
  String? extra;
  double? price;
  String? deductFromCod;

  factory Packages.fromJson(Map<String, dynamic> json) => Packages(
        packaging: json["packaging"],
        weight: json["weight"],
        length: json["length"].toDouble(),
        width: json["width"].toDouble(),
        height: json["height"].toDouble(),
        comment: json["comment"],
        fragile: json["fragile"],
        cod: json["cod"],
        extra: json["extra"],
        quantity: json["quantity"],
        deductFromCod: json["latePayment"],
      );

  Map<String, dynamic> toJson() => {
        "packaging": packaging,
        "weight": weight,
        "length": length,
        "width": width,
        "height": height,
        "comment": comment,
        "fragile": fragile,
        "cod": cod,
        "extra": extra,
        "quantity": quantity,
        "latePayment": deductFromCod
      };
}

//
//
//
//
