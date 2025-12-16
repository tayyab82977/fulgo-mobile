
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

class PickUpDataModel {
  List<OrdersDataModelMix>? toStore;
  List<OrdersDataModelMix>? fromStore;

  PickUpDataModel({this.toStore, this.fromStore});

  PickUpDataModel.fromJson(Map<String, dynamic> json) {
    if (json['toStore'] != null) {
      toStore = [];
      json['toStore'].forEach((v) {
        toStore!.add(new OrdersDataModelMix.fromJson(v));
      });
    }
    if (json['fromStore'] != null) {
      fromStore = [];
      json['fromStore'].forEach((v) {
        fromStore!.add(new OrdersDataModelMix.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.toStore != null) {
      data['toStore'] = this.toStore!.map((v) => v.toJson()).toList();
    }
    if (this.fromStore != null) {
      data['fromStore'] = this.fromStore!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
