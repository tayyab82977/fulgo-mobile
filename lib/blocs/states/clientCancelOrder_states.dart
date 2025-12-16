import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class ClientCancelOrderStates {}

class ClientCancelOrderInitial extends ClientCancelOrderStates{}
class ClientCancelOrderLoading extends ClientCancelOrderStates{}
class ClientCancelOrderSuccess extends ClientCancelOrderStates{}
class ClientCancelOrderFailure extends ClientCancelOrderStates{
  String? error;
  List<String?>? errors;

  ClientCancelOrderFailure({this.error,this.errors});
}
class InValidToken extends ClientCancelOrderStates{}
class ApplicationUpdated extends ClientCancelOrderStates{}
class ShipmentDetailsLoading extends ClientCancelOrderStates {}
class ShipmentDetailPop extends ClientCancelOrderStates {}
class ShipmentZeroActionSuccess extends ClientCancelOrderStates {}
class ShipmentDetailsLoaded extends ClientCancelOrderStates {
  OrdersDataModelMix? ordersDataModel ;
  ShipmentDetailsLoaded({this.ordersDataModel});
}
class ShipmentDetailsError extends ClientCancelOrderStates {
  String? error ;
  List<String?>? errorList ;
  ShipmentDetailsError({this.error , this.errorList});
}

