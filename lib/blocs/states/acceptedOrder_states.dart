import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class AcceptedOrderStates {}


class AcceptedOrderInitial extends AcceptedOrderStates {
   List<OrdersDataModelMix>? notAcceptedOrdersList ;
   List<OrdersDataModelMix>? acceptedOrdersList ;
  AcceptedOrderInitial({this.notAcceptedOrdersList , this.acceptedOrdersList});
}

class AcceptedOrderLoaded extends AcceptedOrderStates {
   List<OrdersDataModelMix>? notAcceptedOrdersList ;
   List<OrdersDataModelMix>? acceptedOrdersList ;
  AcceptedOrderLoaded({this.acceptedOrdersList , this.notAcceptedOrdersList});

}
