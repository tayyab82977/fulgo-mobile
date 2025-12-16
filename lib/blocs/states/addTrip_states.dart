import 'package:xturbox/data_providers/models/tripModel.dart';

abstract class AddTripStates {}

class AddTripInitial extends AddTripStates {}
class AddTripLoading extends AddTripStates {}
class AddTripLoaded extends AddTripStates {
  TripModel? tripModel ;
  AddTripLoaded({this.tripModel});
}
class AddTripAdded extends AddTripStates {
  TripModel? tripModel ;
  AddTripAdded({this.tripModel});
}

class AddTripUpdated extends AddTripStates {
  TripModel? tripModel ;
  AddTripUpdated({this.tripModel});
}
class AddTripError extends AddTripStates {
  String? error ;
  List<String>? errorList ;
  AddTripError({this.errorList,this.error});
}