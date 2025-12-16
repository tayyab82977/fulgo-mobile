
import 'package:xturbox/blocs/events/gerOrders_events.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/shipments_lists_model.dart';

abstract class GetOrdersStates {}


class GetOrdersInitial extends GetOrdersStates {}
class GetOrdersLoading extends GetOrdersStates {}
class GetOrdersEmpty extends GetOrdersStates {}
class ApplicationUpdated extends GetOrdersStates {}
class InValidToken extends GetOrdersStates {}
class GetOrdersLoaded extends GetOrdersStates {
 ShipmentsListsModel? shipmentsListsModel;

  GetOrdersLoaded({this.shipmentsListsModel});
}
class OfdOrdersLoaded extends GetOrdersStates {
 List<OrdersDataModelMix>? ofdOrdersList;

 OfdOrdersLoaded({this.ofdOrdersList});
}
class GetOrdersErrors extends GetOrdersStates {
  GetOrdersEvents? failedEvent ;
  List<String?>? errorList ;
  String? error ;

  GetOrdersErrors({this.errorList , this.failedEvent,this.error});

}