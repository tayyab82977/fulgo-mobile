import 'package:xturbox/data_providers/models/OrdersDataModel.dart';

abstract class PickupActionsEvents {}

class DeliverShipment extends PickupActionsEvents {
  String? id;
  String? receipt;
  String? amount;
  String? paymentMethodId;
  String? code;

  DeliverShipment({this.id, this.amount, this.receipt,this.paymentMethodId,this.code});
}

class CancelShipment extends PickupActionsEvents {
  OrdersDataModelMix shipment;
  String? cancelId;

  CancelShipment({ required this.shipment, this.cancelId});
}

class RejectShipment extends PickupActionsEvents {
  String? id;
  String? reason;

  RejectShipment({this.id, this.reason});
}

class SendConfirmationMsg extends PickupActionsEvents {
  String? receiverId;
  String? receiverPhone;
  String? msgType ;

  SendConfirmationMsg({this.receiverId, this.receiverPhone , this.msgType});
}

class RescheduleShipment extends PickupActionsEvents {
  String? id;
  String? reason;

  RescheduleShipment({this.id, this.reason});
}

class GetTheReceipt extends PickupActionsEvents {
  String? storeId;
  String? method;

  GetTheReceipt({this.storeId, this.method});
}

class LostShipment extends PickupActionsEvents {
  String? id;

  LostShipment({this.id});
}

class DamagedShipment extends PickupActionsEvents {
  String? id;

  DamagedShipment({this.id});
}

class PostponeShipment extends PickupActionsEvents {
  OrdersDataModelMix shipment;
  String? reason;
  String? date;

  PostponeShipment({required this.shipment, this.reason , this.date});
}
class ReActiveShipment extends PickupActionsEvents {
  OrdersDataModelMix shipment;
  ReActiveShipment({required this.shipment});
}

class StoreOutShipment extends PickupActionsEvents {
  String? id;

  StoreOutShipment({this.id});
}

class DispatchIssueShipment extends PickupActionsEvents {
  String? id;

  DispatchIssueShipment({this.id});
}

class PickupActionsEventsGenerateError extends PickupActionsEvents {}
