abstract class ShipmentDetailsEvents{}

class GetShipmentDetails extends ShipmentDetailsEvents {
  String? id ;
  GetShipmentDetails({this.id});
}

class ShipmentDetailsEventsGenerateError extends ShipmentDetailsEvents{}
