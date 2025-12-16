import 'package:xturbox/data_providers/models/tripModel.dart';

abstract class AddTripEvents {}

class AddNewTrip extends AddTripEvents{
  TripModel? tripModel ;
  AddNewTrip({this.tripModel});
}
class UpdateTripEnd extends AddTripEvents{
  TripModel? tripModel ;
  UpdateTripEnd({this.tripModel});
}

