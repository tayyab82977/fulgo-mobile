
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class BulkPickupEvents {}


class BulkPickupThisList extends BulkPickupEvents {
  String? memberId ;
  List<OrdersDataModelMix>? list ;
  String? receipt ;
  String? amount ;
  List<Credit>? creditList;
  String? extra;
  String? paymentMethodId;
  String? msgCodee;

  BulkPickupThisList({this.receipt ,this.amount , this.list , this.memberId , this.creditList ,this.extra , this.paymentMethodId , this.msgCodee});


}
class ReturnThisList extends BulkPickupEvents {
  String? memberId ;
  List<OrdersDataModelMix>? list ;
  String? receipt ;
  String? amount ;
  List<Credit>? creditList;
  String? extra;
  String? paymentMethodId;
  String? code;

  ReturnThisList({this.receipt ,this.amount , this.list , this.memberId , this.creditList ,this.extra , this.paymentMethodId , this.code });


}

class GetClientBalances extends BulkPickupEvents {
  String? memberID ;

  GetClientBalances({this.memberID});


}

class GetShipmentData extends BulkPickupEvents {
  String? shipmentId;
  String? type  ;
  GetShipmentData({this.shipmentId , this.type});
}
class GetClientCredit extends BulkPickupEvents {
  String? id ;
  bool returnToClient ;
  List<OrdersDataModelMix>? acceptedList ;
  GetClientCredit({this.id , this.acceptedList , this.returnToClient = false});
}

class GetReceipt extends BulkPickupEvents {
  String? method ;
  String? storeId ;
  GetReceipt({this.method , this.storeId});
}

class SendConfirmationMsg extends BulkPickupEvents {
  String? receiverId;
  String? receiverPhone;
  String? msgType ;

  SendConfirmationMsg({this.receiverId, this.receiverPhone , this.msgType});
}
class BulkPickupEventsGenerateError extends BulkPickupEvents{}