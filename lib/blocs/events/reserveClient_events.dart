import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class ReserveClientEvents {}

class ReserveClient extends ReserveClientEvents {
  String? id ;

  ReserveClient({this.id});

}

class CaptainCancelThisClient extends ReserveClientEvents {
  String? id ;

  CaptainCancelThisClient({this.id});

}

class RecordPickupIssue extends ReserveClientEvents {
  List<OrdersDataModelMix>? orderList ;
  String? reasonId ;

  RecordPickupIssue({this.orderList , this.reasonId});

}
class ReserveClientEventsGenerateError extends ReserveClientEvents{}

