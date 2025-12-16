import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/postOrderData.dart';

abstract class ClientCancelOrderEvents {}


class CancelMyOrder extends ClientCancelOrderEvents {
  String? id ;

  CancelMyOrder({this.id});
}

class ClientEditOrder extends ClientCancelOrderEvents {

    OrdersDataModelMix? ordersDataModelMix ;

  ClientEditOrder({this.ordersDataModelMix});

}

class ClientReversOrder extends ClientCancelOrderEvents {
  OrdersDataModelMix? ordersDataModelMix ;
    String shipmentId ;
    ClientReversOrder({required this.shipmentId , this.ordersDataModelMix});
}

class GetShipmentDetails extends ClientCancelOrderEvents {
  String? id ;
  GetShipmentDetails({this.id});
}


class ZeroCod extends ClientCancelOrderEvents {
  String? shipmentId ;
  ZeroCod({this.shipmentId});
}

class ZeroRC extends ClientCancelOrderEvents {
  String? shipmentId ;
  ZeroRC({this.shipmentId});
}
class ClientCancelOrderEventsGenerateError extends ClientCancelOrderEvents{}
