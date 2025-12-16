import 'package:xturbox/data_providers/models/tripModel.dart';

abstract class TripsStates {}

class TripsInitial extends TripsStates {}
class TripsLoading extends TripsStates {}
class TripsLoaded extends TripsStates {
  TripModel? tripModel ;
  TripsLoaded({this.tripModel});
}
class TripsAdded extends TripsStates {
  TripModel? tripModel ;
  TripsAdded({this.tripModel});
}

class TripsUpdated extends TripsStates {}
class TripsError extends TripsStates {
  String? error ;
  List<String>? errorList ;
  TripsError({this.errorList,this.error});
}