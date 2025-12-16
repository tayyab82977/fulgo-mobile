import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

class ShipmentsListsModel{

  List<OrdersDataModelMix>? newShipments;
  List<OrdersDataModelMix>? inDeliveryShipments;
  List<OrdersDataModelMix>? deliveredShipments;
  List<OrdersDataModelMix>? cancelShipments;

  ShipmentsListsModel({this.newShipments, this.inDeliveryShipments, this.deliveredShipments, this.cancelShipments});

  ShipmentsListsModel.fromJson(Map<String, dynamic> json){
    if (json['new'] != null){
      newShipments = [];
      json['new'].forEach((i){
        newShipments!.add(OrdersDataModelMix.fromJson(i));
      });
    }
    if (json['inDelivery'] != null){
      inDeliveryShipments = [];
      json['inDelivery'].forEach((i){
        inDeliveryShipments!.add(OrdersDataModelMix.fromJson(i));
      });
    }
    if (json['delivered'] != null){
      deliveredShipments = [];
      json['delivered'].forEach((i){
        deliveredShipments!.add(OrdersDataModelMix.fromJson(i));
      });
    }
    if (json['cancel'] != null){
      cancelShipments = [];
      json['cancel'].forEach((i){
        cancelShipments!.add(OrdersDataModelMix.fromJson(i));
      });
    }
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.newShipments != null) {
      data['new'] = this.newShipments!.map((i) => i.toJson()).toList();
    }
    if (this.inDeliveryShipments != null) {
      data['inDelivery'] = this.inDeliveryShipments!.map((i) => i.toJson()).toList();
    }
    if (this.deliveredShipments != null) {
      data['delivered'] = this.deliveredShipments!.map((i) => i.toJson()).toList();
    }
    if (this.cancelShipments != null) {
      data['cancel'] = this.cancelShipments!.map((i) => i.toJson()).toList();
    }
    return data;
  }

}