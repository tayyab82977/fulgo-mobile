import 'package:xturbox/blocs/states/postOrders_states.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/postOrderData.dart';

abstract class PostOrdersEvent {}

class PostNewOrder extends PostOrdersEvent{
  PostOrderDataModel? postOrderDataModel ;

  PostNewOrder({this.postOrderDataModel});


}

class AddB2cOrder extends PostOrdersEvent{
  List<OrdersDataModelMix> ordersList;
  AddB2cOrder({required this.ordersList});
}
class EditOrder extends PostOrdersEvent{
  OrdersDataModelMix? ordersDataModelMix ;

  EditOrder({this.ordersDataModelMix});


}

class PostOrdersEventGenerateError extends PostOrdersEvent{}
