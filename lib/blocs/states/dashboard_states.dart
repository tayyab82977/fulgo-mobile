import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';

abstract class ProfileStates {}


class DashboardInitial extends ProfileStates {}
class DashboardLoading extends ProfileStates {}
class DashboardError extends ProfileStates {
  String? error ;
  ProfileEvents? failedEvent;
  DashboardError({this.failedEvent, this.error});
}


//client
class DashboardUserLoaded extends ProfileStates {
  ProfileDataModel? dashboardDataModel ;
  DashboardUserLoaded({this.dashboardDataModel});
}
class NoNationalId extends ProfileStates {}



//courier
class NoVehicleAssigned extends ProfileStates {}
class NoLocationPermission extends ProfileStates {}
class DriverUserDashboard extends ProfileStates {}
class EnterODOStart extends ProfileStates {
  ProfileDataModel? dashboardDataModel ;

  EnterODOStart({this.dashboardDataModel});
}
class DashboardCaptainLoaded extends ProfileStates {
  ProfileDataModel? dashboardDataModel ;

  DashboardCaptainLoaded({this.dashboardDataModel});
}
class DashboardCaptainIn extends ProfileStates {
  ProfileDataModel? dashboardDataModel ;

  DashboardCaptainIn({this.dashboardDataModel});
}







