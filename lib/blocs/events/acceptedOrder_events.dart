import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class AcceptedOrderEvents {}


class AcceptThisOrder extends AcceptedOrderEvents {
 final List<OrdersDataModelMix>? notAcceptedOrdersList ;
 final List<OrdersDataModelMix>? acceptedOrdersList ;

 AcceptThisOrder({this.acceptedOrdersList , this.notAcceptedOrdersList});

}
class NotAcceptThisOrder extends AcceptedOrderEvents {
  final List<OrdersDataModelMix>? notAcceptedOrdersList ;
  final List<OrdersDataModelMix>? acceptedOrdersList ;

  NotAcceptThisOrder({this.acceptedOrdersList , this.notAcceptedOrdersList});

}