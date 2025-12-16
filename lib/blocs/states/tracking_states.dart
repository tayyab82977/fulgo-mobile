import 'package:xturbox/data_providers/models/trackingDataModel.dart';

abstract class TrackingStates {}

class TrackingInitial extends TrackingStates {}
class TrackingLoading extends TrackingStates {}
class TrackingInvalid extends TrackingStates {}
class TrackingLoaded extends TrackingStates {
  TrackingList? trackingList;
  TrackingLoaded({this.trackingList});
}
class TrackingError extends TrackingStates {
  String? error ;
  TrackingError({this.error});
}
