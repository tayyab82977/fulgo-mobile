import 'package:xturbox/data_providers/models/trackingDataModel.dart';

abstract class NewTrackingStates {}


class NewTrackingInitial extends NewTrackingStates {}
class NewTrackingLoading extends NewTrackingStates {}
class NewTrackingInvalid extends NewTrackingStates {}
class NewTrackingLoaded extends NewTrackingStates {
  List<TrackingDataModel>? trackingList;
  NewTrackingLoaded({this.trackingList});
}
class NewTrackingError extends NewTrackingStates {
  String? error ;
  NewTrackingError({this.error});
}
