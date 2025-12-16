import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';


abstract class PickUpEvents {}


class PickUpThisList extends PickUpEvents {
  String? memberId ;
  List<OrdersDataModelMix>? pickupList ;
  String? receipt ;
  String? amount ;
  List<Credit>? creditList;
  String? extra;
  String? paymentMethodId;
  String? msgCodee;


  PickUpThisList({this.receipt ,this.amount , this.pickupList , this.memberId , this.creditList ,this.extra,this.paymentMethodId ,this.msgCodee});


}
class GetClientBalance extends PickUpEvents {
  String? memberID ;

  GetClientBalance({this.memberID});


}

class GetClientCredit extends PickUpEvents {
  String? id ;
  List<OrdersDataModelMix>? acceptedList ;
  GetClientCredit({this.id , this.acceptedList});
}

class GetReceipt extends PickUpEvents {
  String? method ;
  String? storeId ;
  GetReceipt({this.method , this.storeId});
}
class SendConfirmationMsg extends PickUpEvents {
  String? receiverId;
  String? receiverPhone;
  String? msgType ;

  SendConfirmationMsg({this.receiverId, this.receiverPhone , this.msgType});
}

class PickUpEventsGenerateError extends PickUpEvents{}

