import 'package:xturbox/blocs/events/checkIn_events.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class CheckInStates {}

class CheckInInitial extends CheckInStates{}

class CheckInLoading extends CheckInStates{}
class ApplicationUpdated extends CheckInStates{}

class CheckInActiveSuccess extends CheckInStates{}
class CheckInNotActiveSuccess extends CheckInStates{}
class InValidToken extends CheckInStates{}
class ProfileLoadedForDrawer extends CheckInStates{
  ProfileDataModel? dashboardDataModel ;
  ProfileLoadedForDrawer({this.dashboardDataModel});
}

class CheckInFailure extends CheckInStates{
  CheckInEvents? failedEvent ;
  String? error;
 CheckInFailure({this.failedEvent,this.error});
}
