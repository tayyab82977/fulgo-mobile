import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class ShipmentDetailsStates{}

class ShipmentDetailsInitial extends ShipmentDetailsStates {}
class ShipmentDetailsLoading extends ShipmentDetailsStates {}
class ShipmentDetailsLoaded extends ShipmentDetailsStates {
  OrdersDataModelMix? ordersDataModel ;
  ShipmentDetailsLoaded({this.ordersDataModel});
}
class ShipmentDetailsError extends ShipmentDetailsStates {
  String? error ;
  List<String>? errorList ;
  ShipmentDetailsError({this.error , this.errorList});
}


